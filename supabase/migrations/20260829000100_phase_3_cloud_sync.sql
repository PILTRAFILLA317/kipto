create table public.saved_items (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  summary text not null default '',
  category text not null,
  subtype text,
  intent text,
  status text not null,
  favorite boolean not null default false,
  captured_at timestamptz not null,
  event_at timestamptz,
  expires_at timestamptz,
  snoozed_until timestamptz,
  location_json jsonb,
  entities_json jsonb not null default '{}'::jsonb,
  available_actions_json jsonb not null default '[]'::jsonb,
  cloud_preview_path text,
  image_hash text,
  analysis_status text not null,
  analysis_version integer,
  confidence double precision,
  client_updated_at timestamptz not null,
  server_updated_at timestamptz not null default now(),
  source_device_id uuid,
  created_at timestamptz not null,
  deleted_at timestamptz,
  constraint saved_items_category_check check (
    category in (
      'event', 'place', 'product', 'order', 'recipe', 'coupon',
      'conversation', 'media', 'meme', 'information', 'other'
    )
  ),
  constraint saved_items_status_check check (
    status in ('new', 'needsAction', 'snoozed', 'done', 'archived')
  ),
  constraint saved_items_analysis_status_check check (
    analysis_status in (
      'unprocessed', 'processing', 'processed', 'needsReview', 'failed'
    )
  ),
  constraint saved_items_confidence_check check (
    confidence is null or (confidence >= 0 and confidence <= 1)
  ),
  constraint saved_items_id_user_unique unique (id, user_id)
);

create table public.reminders (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  saved_item_id uuid not null,
  remind_at timestamptz not null,
  kind text not null,
  completed_at timestamptz,
  client_updated_at timestamptz not null,
  server_updated_at timestamptz not null default now(),
  source_device_id uuid,
  created_at timestamptz not null,
  deleted_at timestamptz,
  constraint reminders_kind_check check (
    kind in ('followUp', 'event', 'expiration', 'custom')
  ),
  constraint reminders_saved_item_owner_fk
    foreign key (saved_item_id, user_id)
    references public.saved_items(id, user_id)
    on delete cascade
);

create table public.devices (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  platform text not null,
  app_version text,
  created_at timestamptz not null default now(),
  last_seen_at timestamptz not null,
  updated_at timestamptz not null default now(),
  constraint devices_platform_check check (
    platform in ('android', 'iOS', 'macOS', 'windows', 'linux', 'fuchsia')
  ),
  constraint devices_id_user_unique unique (id, user_id)
);

create index saved_items_user_id_idx on public.saved_items (user_id);
create index saved_items_user_server_updated_idx
  on public.saved_items (user_id, server_updated_at);
create index reminders_user_id_idx on public.reminders (user_id);
create index reminders_saved_item_id_idx on public.reminders (saved_item_id);
create index reminders_user_server_updated_idx
  on public.reminders (user_id, server_updated_at);
create index devices_user_id_idx on public.devices (user_id);

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

create trigger saved_items_set_server_updated_at
before update on public.saved_items
for each row execute function public.kipto_set_server_updated_at();

create trigger reminders_set_server_updated_at
before update on public.reminders
for each row execute function public.kipto_set_server_updated_at();

create or replace function public.kipto_set_device_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger devices_set_updated_at
before update on public.devices
for each row execute function public.kipto_set_device_updated_at();

alter table public.saved_items enable row level security;
alter table public.reminders enable row level security;
alter table public.devices enable row level security;

revoke all on table public.saved_items from anon, authenticated;
revoke all on table public.reminders from anon, authenticated;
revoke all on table public.devices from anon, authenticated;
grant select, insert, update, delete on table public.saved_items to authenticated;
grant select, insert, update, delete on table public.reminders to authenticated;
grant select, insert, update, delete on table public.devices to authenticated;

create policy "saved_items_select_own"
on public.saved_items for select to authenticated
using ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy "saved_items_insert_own"
on public.saved_items for insert to authenticated
with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy "saved_items_update_own"
on public.saved_items for update to authenticated
using ((select auth.uid()) is not null and (select auth.uid()) = user_id)
with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy "saved_items_delete_own"
on public.saved_items for delete to authenticated
using ((select auth.uid()) is not null and (select auth.uid()) = user_id);

create policy "reminders_select_own"
on public.reminders for select to authenticated
using ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy "reminders_insert_own"
on public.reminders for insert to authenticated
with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy "reminders_update_own"
on public.reminders for update to authenticated
using ((select auth.uid()) is not null and (select auth.uid()) = user_id)
with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy "reminders_delete_own"
on public.reminders for delete to authenticated
using ((select auth.uid()) is not null and (select auth.uid()) = user_id);

create policy "devices_select_own"
on public.devices for select to authenticated
using ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy "devices_insert_own"
on public.devices for insert to authenticated
with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy "devices_update_own"
on public.devices for update to authenticated
using ((select auth.uid()) is not null and (select auth.uid()) = user_id)
with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);
create policy "devices_delete_own"
on public.devices for delete to authenticated
using ((select auth.uid()) is not null and (select auth.uid()) = user_id);

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

create trigger saved_items_broadcast_sync
after insert or update or delete on public.saved_items
for each row execute function public.kipto_broadcast_sync_change();

create trigger reminders_broadcast_sync
after insert or update or delete on public.reminders
for each row execute function public.kipto_broadcast_sync_change();

drop policy if exists "kipto_users_receive_own_sync_broadcasts"
on realtime.messages;
create policy "kipto_users_receive_own_sync_broadcasts"
on realtime.messages for select to authenticated
using (
  realtime.messages.extension = 'broadcast'
  and (select realtime.topic()) =
    'user:' || (select auth.uid())::text || ':sync'
);
