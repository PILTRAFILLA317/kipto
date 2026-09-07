alter table public.source_backups add column active_until timestamptz not null default '-infinity';
-- Reserve a bounded lease before network work. A delete waits for any old
-- request to finish before removing Storage; no SQL deletes of object metadata.
create or replace function public.kipto_backup_upload_lease(p_user_id uuid,p_source_id uuid,p_revision integer)
returns boolean language plpgsql security definer set search_path='' as $$
begin
 update public.source_backups b set active_until=now()+interval '5 minutes'
 where b.user_id=p_user_id and b.source_id=p_source_id and b.revision=p_revision and b.state='reserved'
 and exists(select 1 from public.sources s where s.id=b.source_id and s.user_id=b.user_id and s.deleted_at is null);
 return found;
end; $$;
create or replace function public.kipto_begin_source_delete(p_user_id uuid,p_source_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare wait_until timestamptz; paths jsonb;
begin
 update public.sources set deleted_at=coalesce(deleted_at,now()),client_updated_at=greatest(client_updated_at,now()) where id=p_source_id and user_id=p_user_id;
 update public.source_backups set state='deleting',updated_at=now() where source_id=p_source_id and user_id=p_user_id;
 select max(active_until),coalesce(jsonb_agg(object_path),'[]') into wait_until,paths from public.source_backups where source_id=p_source_id and user_id=p_user_id;
 return jsonb_build_object('pending',coalesce(wait_until>now(),false),'paths',paths);
end; $$;
create or replace function public.kipto_deleted_rows_stay_deleted() returns trigger
language plpgsql set search_path='' as $$
begin
 if old.deleted_at is not null then return old; end if;
 return new;
end; $$;
do $$ declare t text; begin
 foreach t in array array['items','sources','facts','item_actions','reminders'] loop
  execute format('create trigger keep_tombstone before update on public.%I for each row execute function public.kipto_deleted_rows_stay_deleted()',t);
  execute format('revoke delete on public.%I from authenticated',t);
 end loop;
end; $$;
revoke all on function public.kipto_backup_upload_lease(uuid,uuid,integer) from public,anon,authenticated;
revoke all on function public.kipto_begin_source_delete(uuid,uuid) from public,anon,authenticated;
grant execute on function public.kipto_backup_upload_lease(uuid,uuid,integer) to service_role;
grant execute on function public.kipto_begin_source_delete(uuid,uuid) to service_role;
-- Rollback preserves tombstones. Do not regrant hard deletes while stored
-- originals depend on backend cleanup and durable ownership metadata.
