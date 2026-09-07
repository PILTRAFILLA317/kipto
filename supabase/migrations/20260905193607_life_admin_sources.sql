-- Additive expansion. Existing Items/Reminders and identities are preserved.
create table public.sources (
  id uuid primary key,
  item_id uuid not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (kind in ('image', 'pdf', 'text', 'url')),
  origin text not null check (origin in ('systemPicker', 'shareSheet', 'manual')),
  original_name text not null check (char_length(original_name) between 1 and 512),
  mime_type text not null check (mime_type in ('image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf', 'text/plain')),
  byte_size bigint not null check (byte_size between 1 and 20971520),
  content_hash text not null check (content_hash ~ '^[a-f0-9]{64}$'),
  revision integer not null default 1 check (revision > 0),
  text_content text check (char_length(text_content) <= 60000),
  page_count integer check (page_count > 0),
  created_at timestamptz not null,
  client_updated_at timestamptz not null,
  server_updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint sources_item_owner_fk foreign key (item_id, user_id) references public.items(id, user_id) on delete cascade,
  constraint sources_id_item_owner_unique unique (id, item_id, user_id),
  constraint sources_id_owner_unique unique (id, user_id)
);
create index sources_item_owner_idx on public.sources(item_id, user_id);
create index sources_owner_cursor_idx on public.sources(user_id, server_updated_at, id);
create trigger sources_set_server_updated_at before update on public.sources
for each row execute function public.kipto_set_server_updated_at();
create trigger sources_broadcast_sync after insert or update or delete on public.sources
for each row execute function public.kipto_broadcast_sync_change();
alter table public.sources enable row level security;
revoke all on table public.sources from anon, authenticated;
grant select, insert, update, delete on table public.sources to authenticated;
create policy sources_select_own on public.sources for select to authenticated using ((select auth.uid()) = user_id);
create policy sources_insert_own on public.sources for insert to authenticated with check ((select auth.uid()) = user_id);
create policy sources_update_own on public.sources for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy sources_delete_own on public.sources for delete to authenticated using ((select auth.uid()) = user_id);
-- Rollback: deploy the preceding client and disable source sync; retain this
-- additive table and its data. Do not DROP it as part of an application rollback.
