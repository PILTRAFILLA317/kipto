create or replace function public.kipto_try_timestamptz(value text)
returns timestamptz
language plpgsql
immutable
security invoker
set search_path = ''
as $$
begin
  return value::timestamptz;
exception when others then
  return null;
end;
$$;

create or replace function public.kipto_merge_completed_actions()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  action_key text;
  old_value text;
  new_value text;
  old_completed timestamptz;
  new_completed timestamptz;
  incoming_entities jsonb := coalesce(new.entities_json, '{}'::jsonb);
  old_actions jsonb := coalesce(
    old.entities_json -> '__kiptoCompletedActions',
    '{}'::jsonb
  );
  new_actions jsonb := coalesce(
    new.entities_json -> '__kiptoCompletedActions',
    '{}'::jsonb
  );
  merged_actions jsonb := '{}'::jsonb;
begin
  if jsonb_typeof(old_actions) <> 'object' then
    old_actions := '{}'::jsonb;
  end if;
  if jsonb_typeof(new_actions) <> 'object' then
    new_actions := '{}'::jsonb;
  end if;

  for action_key, new_value in
    select key, value from jsonb_each_text(new_actions)
  loop
    new_completed := public.kipto_try_timestamptz(new_value);
    if action_key in ('addCalendar', 'createReminder', 'save') and
       new_completed is not null then
      merged_actions := jsonb_set(
        merged_actions,
        array[action_key],
        to_jsonb(new_value),
        true
      );
    end if;
  end loop;

  for action_key, old_value in
    select key, value from jsonb_each_text(old_actions)
  loop
    if action_key not in ('addCalendar', 'createReminder', 'save') then
      continue;
    end if;
    new_value := merged_actions ->> action_key;
    old_completed := public.kipto_try_timestamptz(old_value);
    new_completed := public.kipto_try_timestamptz(new_value);
    if old_completed is not null and (
      new_completed is null or old_completed > new_completed
    ) then
      merged_actions := jsonb_set(
        merged_actions,
        array[action_key],
        to_jsonb(old_value),
        true
      );
    end if;
  end loop;

  if new.client_updated_at < old.client_updated_at then
    -- Preserve row-level LWW while allowing a stale offline writer to add a
    -- completion that did not exist in the newer row.
    new := old;
    incoming_entities := coalesce(old.entities_json, '{}'::jsonb);
  end if;

  if merged_actions <> '{}'::jsonb then
    new.entities_json := jsonb_set(
      incoming_entities,
      '{__kiptoCompletedActions}',
      merged_actions,
      true
    );
  end if;
  if new.entities_json is distinct from old.entities_json or
     new.client_updated_at >= old.client_updated_at then
    new.server_updated_at := now();
  end if;
  return new;
end;
$$;

-- Phase 3 used one generic LWW trigger for SavedItems and Reminders. SavedItems
-- now need key-wise action merging in the same decision, otherwise a stale
-- writer would be reduced to OLD before its new completion could be retained.
drop trigger if exists saved_items_set_server_updated_at
on public.saved_items;
drop trigger if exists saved_items_merge_completed_actions
on public.saved_items;
create trigger saved_items_merge_completed_actions
before update on public.saved_items
for each row execute function public.kipto_merge_completed_actions();

revoke all on function public.kipto_try_timestamptz(text)
  from public, anon, authenticated;
revoke all on function public.kipto_merge_completed_actions()
  from public, anon, authenticated;
