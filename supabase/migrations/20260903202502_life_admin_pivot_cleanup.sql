-- Kipto Life Admin foundation. Legacy pre-release rows are intentionally
-- discarded; Auth users, devices, and aggregate quota accounting are retained.

drop trigger if exists saved_items_broadcast_sync on public.saved_items;
drop trigger if exists saved_items_merge_completed_actions on public.saved_items;
drop trigger if exists saved_items_set_server_updated_at on public.saved_items;
drop trigger if exists reminders_broadcast_sync on public.reminders;
drop trigger if exists reminders_set_server_updated_at on public.reminders;

drop function if exists public.kipto_merge_completed_actions();
drop function if exists public.kipto_try_timestamptz(text);

drop table if exists public.reminders;
drop table if exists public.saved_items;

create table public.items (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  summary text not null default '',
  status text not null,
  created_at timestamptz not null,
  client_updated_at timestamptz not null,
  server_updated_at timestamptz not null default now(),
  resolved_at timestamptz,
  deleted_at timestamptz,
  source_device_id uuid,
  constraint items_status_check check (status in ('active', 'resolved', 'archived')),
  constraint items_id_user_unique unique (id, user_id)
);

create table public.reminders (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  item_id uuid not null,
  remind_at timestamptz not null,
  completed_at timestamptz,
  created_at timestamptz not null,
  client_updated_at timestamptz not null,
  server_updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  source_device_id uuid,
  constraint reminders_item_owner_fk
    foreign key (item_id, user_id)
    references public.items(id, user_id)
    on delete cascade
);

create index items_user_server_updated_idx
  on public.items (user_id, server_updated_at);
create index reminders_item_user_id_idx on public.reminders (item_id, user_id);
create index reminders_user_server_updated_idx
  on public.reminders (user_id, server_updated_at);

create or replace function public.kipto_set_server_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if new.client_updated_at < old.client_updated_at then
    return old;
  end if;
  new.server_updated_at = now();
  return new;
end;
$$;

create trigger items_set_server_updated_at
before update on public.items
for each row execute function public.kipto_set_server_updated_at();

create trigger reminders_set_server_updated_at
before update on public.reminders
for each row execute function public.kipto_set_server_updated_at();

create or replace function public.kipto_broadcast_sync_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  owner_id uuid := coalesce(new.user_id, old.user_id);
begin
  perform realtime.broadcast_changes(
    'user:' || owner_id::text || ':sync',
    'sync',
    tg_op,
    tg_table_name,
    tg_table_schema,
    new,
    old
  );
  return null;
end;
$$;

revoke all on function public.kipto_broadcast_sync_change()
  from public, anon, authenticated;
revoke all on function public.kipto_set_server_updated_at()
  from public, anon, authenticated;
revoke all on function public.kipto_set_device_updated_at()
  from public, anon, authenticated;
revoke all on function public.kipto_consume_analysis_quota(uuid, integer)
  from public, anon, authenticated;
revoke all on function public.kipto_record_analysis_usage(uuid, boolean, bigint, bigint)
  from public, anon, authenticated;
grant execute on function public.kipto_consume_analysis_quota(uuid, integer)
  to service_role;
grant execute on function public.kipto_record_analysis_usage(uuid, boolean, bigint, bigint)
  to service_role;

create trigger items_broadcast_sync
after insert or update or delete on public.items
for each row execute function public.kipto_broadcast_sync_change();

create trigger reminders_broadcast_sync
after insert or update or delete on public.reminders
for each row execute function public.kipto_broadcast_sync_change();

alter table public.items enable row level security;
alter table public.reminders enable row level security;

revoke all on table public.items from anon, authenticated;
revoke all on table public.reminders from anon, authenticated;
grant select, insert, update, delete on table public.items to authenticated;
grant select, insert, update, delete on table public.reminders to authenticated;

create policy "items_select_own"
on public.items for select to authenticated
using ((select auth.uid()) = user_id);
create policy "items_insert_own"
on public.items for insert to authenticated
with check ((select auth.uid()) = user_id);
create policy "items_update_own"
on public.items for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);
create policy "items_delete_own"
on public.items for delete to authenticated
using ((select auth.uid()) = user_id);

create policy "reminders_select_own"
on public.reminders for select to authenticated
using ((select auth.uid()) = user_id);
create policy "reminders_insert_own"
on public.reminders for insert to authenticated
with check ((select auth.uid()) = user_id);
create policy "reminders_update_own"
on public.reminders for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);
create policy "reminders_delete_own"
on public.reminders for delete to authenticated
using ((select auth.uid()) = user_id);
