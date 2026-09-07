-- Additive Life Admin domain. Preserve all existing Items, Sources and Reminders.
-- pg_jsonschema is a supported Supabase extension; it owns JSON shape checks.
create extension if not exists pg_jsonschema with schema extensions;
create or replace function public.kipto_valid_temporal_json(v jsonb)
returns boolean language plpgsql stable set search_path = '' as $$
declare field text; raw text; parsed date;
begin
  foreach field in array array['date', 'startDate', 'endDateExclusive'] loop
    raw := v->>field;
    if raw is not null then
      if raw !~ '^\d{4}-\d{2}-\d{2}$' then return false; end if;
      parsed := raw::date;
      if to_char(parsed, 'YYYY-MM-DD') <> raw then return false; end if;
    end if;
  end loop;
  raw := v->>'time';
  if raw is not null and raw !~ '^([01][0-9]|2[0-3]):[0-5][0-9]$' then return false; end if;
  raw := v->>'zone';
  if raw is not null and not exists(select 1 from pg_catalog.pg_timezone_names where name = raw) then return false; end if;
  foreach field in array array['instant', 'start', 'end'] loop
    raw := v->>field;
    if raw is not null then
      perform raw::timestamptz;
      if not public.kipto_valid_temporal_json(jsonb_build_object('date', left(raw,10))) then return false; end if;
      if substring(raw from 12 for 8) !~ '^([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$' then return false; end if;
    end if;
  end loop;
  return true;
exception when others then return false;
end; $$;
create or replace function public.kipto_valid_fact_value(kind text, v jsonb) returns boolean
language sql stable set search_path = '' as $$
select public.kipto_valid_temporal_json(v) and coalesce(case kind
when 'text' then extensions.jsonb_matches_schema('{"type":"object","properties":{"text":{"type":"string","maxLength":2000}},"required":["text"],"additionalProperties":false}'::json, v)
when 'date' then extensions.jsonb_matches_schema('{"type":"object","properties":{"date":{"type":["string","null"],"pattern":"^\\d{4}-\\d{2}-\\d{2}$"},"raw":{"type":"string","maxLength":300}},"required":["date","raw"],"additionalProperties":false}'::json, v)
when 'datetime' then extensions.jsonb_matches_schema('{"type":"object","properties":{"date":{"type":["string","null"],"pattern":"^\\d{4}-\\d{2}-\\d{2}$"},"time":{"type":["string","null"],"pattern":"^\\d{2}:\\d{2}$"},"zone":{"type":["string","null"],"maxLength":100},"raw":{"type":"string","maxLength":300}},"required":["date","time","zone","raw"],"additionalProperties":false}'::json, v)
when 'duration' then extensions.jsonb_matches_schema('{"type":"object","properties":{"count":{"type":"integer","minimum":1,"maximum":36600},"unit":{"type":"string","enum":["calendarDay","calendarMonth"]}},"required":["count","unit"],"additionalProperties":false}'::json, v)
when 'money' then extensions.jsonb_matches_schema('{"type":"object","properties":{"amount":{"type":"string","pattern":"^-?\\d{1,12}(\\.\\d{1,4})?$"},"currency":{"type":["string","null"],"pattern":"^[A-Z]{3}$"}},"required":["amount","currency"],"additionalProperties":false}'::json, v)
else false end, false) $$;
create or replace function public.kipto_valid_action_payload(kind text, v jsonb) returns boolean
language sql stable set search_path = '' as $$
select public.kipto_valid_temporal_json(v) and coalesce(case kind
when 'keep' then extensions.jsonb_matches_schema('{"type":"object","properties":{},"required":[],"additionalProperties":false}'::json, v)
when 'remind' then extensions.jsonb_matches_schema('{"type":"object","properties":{"instant":{"type":["string","null"],"pattern":"^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,6})?Z$"},"zone":{"type":["string","null"],"minLength":1,"maxLength":100}},"required":["instant","zone"],"additionalProperties":false}'::json, v)
when 'event' then extensions.jsonb_matches_schema('{"type":"object","properties":{"allDay":{"type":"boolean"},"start":{"type":["string","null"],"pattern":"^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,6})?Z$"},"end":{"type":["string","null"],"pattern":"^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d{1,6})?Z$"},"startDate":{"type":["string","null"],"pattern":"^\\d{4}-\\d{2}-\\d{2}$"},"endDateExclusive":{"type":["string","null"],"pattern":"^\\d{4}-\\d{2}-\\d{2}$"},"zone":{"type":["string","null"],"minLength":1,"maxLength":100},"location":{"type":["string","null"],"maxLength":500}},"required":["allDay","start","end","startDate","endDateExclusive","zone","location"],"additionalProperties":false}'::json, v)
else false end, false) $$;
create table public.facts (
 id uuid primary key, item_id uuid not null, user_id uuid not null references auth.users(id) on delete cascade,
 source_id uuid, source_revision integer check(source_revision > 0),
 key text not null check(char_length(key) between 1 and 100),
 value_type text not null, value jsonb not null, user_value jsonb,
 provenance text not null check(provenance in ('extracted','derived','user')),
 evidence jsonb not null,
 created_at timestamptz not null, client_updated_at timestamptz not null,
 server_updated_at timestamptz not null default now(), deleted_at timestamptz,
 unique(id,item_id,user_id), unique(id,user_id),
 foreign key(item_id,user_id) references public.items(id,user_id) on delete cascade,
 foreign key(source_id,item_id,user_id) references public.sources(id,item_id,user_id),
 check((source_id is null) = (source_revision is null)),
 check(provenance <> 'extracted' or source_id is not null),
 check(public.kipto_valid_fact_value(value_type,value)),
 check(user_value is null or public.kipto_valid_fact_value(value_type,user_value)),
 check(octet_length(evidence::text) <= 12000)
);
create table public.item_actions (
 id uuid primary key, item_id uuid not null, user_id uuid not null references auth.users(id) on delete cascade,
 source_id uuid, analysis_revision integer check(analysis_revision > 0),
 kind text not null check(kind in ('remind','event','keep')), title text not null check(char_length(title) between 1 and 100),
 payload_version integer not null default 1 check(payload_version=1), payload jsonb not null,
 origin text not null check(origin in ('analysis','user')),
 evidence_fact_ids uuid[] not null default '{}',
 state text not null default 'proposed' check(state in ('proposed','accepted','dismissed')),
 execution_state text not null default 'notRequested' check(execution_state in ('notRequested','pending','applied','launchedUnconfirmed','failed')),
 accepted_at timestamptz, created_at timestamptz not null, client_updated_at timestamptz not null,
 server_updated_at timestamptz not null default now(), deleted_at timestamptz,
 unique(id,item_id,user_id), unique(id,user_id),
 foreign key(item_id,user_id) references public.items(id,user_id) on delete cascade,
 foreign key(source_id,item_id,user_id) references public.sources(id,item_id,user_id),
 check((source_id is null) = (analysis_revision is null)),
 check(cardinality(evidence_fact_ids) <= 12),
 check(state='accepted' or execution_state='notRequested'),
 check(state <> 'accepted' or accepted_at is not null),
 check(public.kipto_valid_action_payload(kind,payload))
);
alter table public.reminders add column action_id uuid, add column title text check(char_length(title) <= 100), add column time_zone text;
alter table public.reminders add constraint reminders_action_owner_fk foreign key(action_id,item_id,user_id) references public.item_actions(id,item_id,user_id);
create unique index reminders_action_unique on public.reminders(action_id) where action_id is not null;
create or replace function public.kipto_validate_action_relations() returns trigger
language plpgsql set search_path = '' as $$
begin
 if exists(select 1 from unnest(new.evidence_fact_ids) f(id) where not exists(
   select 1 from public.facts x where x.id=f.id and x.item_id=new.item_id and x.user_id=new.user_id)) then
   raise exception 'Invalid action evidence relationship';
 end if;
 if cardinality(new.evidence_fact_ids) <> (select count(distinct x) from unnest(new.evidence_fact_ids) x) then
   raise exception 'Duplicate action evidence';
 end if;
 if new.kind='event' then
   if (new.payload->>'allDay')::boolean then
     if new.payload->>'start' is not null or new.payload->>'end' is not null then raise exception 'Mixed event types'; end if;
     if new.payload->>'startDate' is not null and new.payload->>'endDateExclusive' is not null and
       (new.payload->>'endDateExclusive')::date <= (new.payload->>'startDate')::date then raise exception 'Invalid event dates'; end if;
   else
     if new.payload->>'startDate' is not null or new.payload->>'endDateExclusive' is not null then raise exception 'Mixed event types'; end if;
     if new.payload->>'start' is not null and new.payload->>'end' is not null and
       (new.payload->>'end')::timestamptz <= (new.payload->>'start')::timestamptz then raise exception 'Invalid event interval'; end if;
   end if;
 end if;
 if new.state='accepted' then
   if new.kind='remind' and (new.payload->>'instant' is null or new.payload->>'zone' is null) then raise exception 'Incomplete reminder'; end if;
   if new.kind='event' and (case when (new.payload->>'allDay')::boolean then
     new.payload->>'startDate' is null or new.payload->>'endDateExclusive' is null
     else new.payload->>'start' is null or new.payload->>'end' is null or new.payload->>'zone' is null end) then
     raise exception 'Incomplete event';
   end if;
 end if;
 return new;
end; $$;
create trigger item_actions_validate before insert or update on public.item_actions for each row execute function public.kipto_validate_action_relations();
create or replace function public.kipto_validate_reminder_action() returns trigger
language plpgsql set search_path = '' as $$
begin
 if new.action_id is not null and not exists(select 1 from public.item_actions a where a.id=new.action_id and a.item_id=new.item_id and a.user_id=new.user_id and a.kind='remind') then
   raise exception 'Invalid reminder action';
 end if;
 if new.time_zone is not null and not exists(select 1 from pg_catalog.pg_timezone_names where name=new.time_zone) then raise exception 'Invalid reminder timezone'; end if;
 return new;
end; $$;
create trigger reminders_validate_action before insert or update on public.reminders for each row execute function public.kipto_validate_reminder_action();
alter table public.facts add constraint facts_evidence_shape check(extensions.jsonb_matches_schema('{"type":"object","properties":{"page":{"type":["integer","null"],"minimum":1},"quote":{"type":["string","null"],"minLength":1,"maxLength":2000},"verification":{"type":"string","enum":["textMatched","visualReference","userConfirmed","unverified"]}},"required":["page","quote","verification"],"additionalProperties":false}'::json,evidence));
create index facts_owner_cursor_idx on public.facts(user_id,server_updated_at,id);
create index facts_source_idx on public.facts(source_id,item_id,user_id);
create index facts_item_idx on public.facts(item_id,user_id);
create trigger facts_set_server_updated_at before update on public.facts for each row execute function public.kipto_set_server_updated_at();
create trigger facts_broadcast_sync after insert or update or delete on public.facts for each row execute function public.kipto_broadcast_sync_change();
alter table public.facts enable row level security;
revoke all on public.facts from anon, authenticated;
grant select,insert,update,delete on public.facts to authenticated;
create policy facts_select_own on public.facts for select to authenticated using ((select auth.uid())=user_id);
create policy facts_insert_own on public.facts for insert to authenticated with check ((select auth.uid())=user_id);
create policy facts_update_own on public.facts for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy facts_delete_own on public.facts for delete to authenticated using ((select auth.uid())=user_id);
create index item_actions_owner_cursor_idx on public.item_actions(user_id,server_updated_at,id);
create index item_actions_source_idx on public.item_actions(source_id,item_id,user_id);
create index item_actions_item_idx on public.item_actions(item_id,user_id);
create trigger item_actions_set_server_updated_at before update on public.item_actions for each row execute function public.kipto_set_server_updated_at();
create trigger item_actions_broadcast_sync after insert or update or delete on public.item_actions for each row execute function public.kipto_broadcast_sync_change();
alter table public.item_actions enable row level security;
revoke all on public.item_actions from anon, authenticated;
grant select,insert,update,delete on public.item_actions to authenticated;
create policy item_actions_select_own on public.item_actions for select to authenticated using ((select auth.uid())=user_id);
create policy item_actions_insert_own on public.item_actions for insert to authenticated with check ((select auth.uid())=user_id);
create policy item_actions_update_own on public.item_actions for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy item_actions_delete_own on public.item_actions for delete to authenticated using ((select auth.uid())=user_id);
-- Rollback is a previous client with these additive tables retained. Never drop
-- user facts, accepted actions or reminder links to roll back an app release.
