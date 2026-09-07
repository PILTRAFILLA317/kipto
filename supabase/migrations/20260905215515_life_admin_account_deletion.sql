create table public.account_deletions (
 user_id uuid primary key,
 request_id uuid not null unique,
 state text not null default 'pending' check(state in ('pending','complete')),
 created_at timestamptz not null default now(), completed_at timestamptz
);
alter table public.account_deletions enable row level security;
revoke all on public.account_deletions from anon,authenticated;
grant all on public.account_deletions to service_role;
create or replace function public.kipto_account_writable() returns boolean
language sql stable security definer set search_path='' as $$
 select not exists(select 1 from public.account_deletions where user_id=(select auth.uid()));
$$;
revoke all on function public.kipto_account_writable() from public,anon;
grant execute on function public.kipto_account_writable() to authenticated;
do $$ declare t text; definition text; begin
 foreach t in array array['items','sources','facts','item_actions','reminders'] loop
  execute format('create policy account_not_deleting on public.%I as restrictive for all to authenticated using (public.kipto_account_writable()) with check (public.kipto_account_writable())',t);
 end loop;
 -- Preserve the tested quota implementation, inserting only a deletion gate.
 select pg_get_functiondef('public.kipto_reserve_analysis(uuid,uuid,uuid,integer,text)'::regprocedure) into definition;
 definition:=replace(definition,' if p_source_revision < 1',E' if exists(select 1 from public.account_deletions where user_id=p_user_id) then return jsonb_build_object(\'decision\',\'failed\'); end if;\n if p_source_revision < 1');
 execute definition;
 select pg_get_functiondef('public.kipto_reserve_backup(uuid,uuid,integer)'::regprocedure) into definition;
 definition:=replace(definition,' perform pg_advisory_xact_lock',E' if exists(select 1 from public.account_deletions where user_id=p_user_id) then return jsonb_build_object(\'error\',\'sourceUnavailable\'); end if;\n perform pg_advisory_xact_lock');
 execute definition;
end; $$;
create or replace function public.kipto_backup_upload_lease(p_user_id uuid,p_source_id uuid,p_revision integer)
returns boolean language plpgsql security definer set search_path='' as $$
begin
 update public.source_backups b set active_until=now()+interval '5 minutes'
 where b.user_id=p_user_id and b.source_id=p_source_id and b.revision=p_revision and b.state='reserved'
 and not exists(select 1 from public.account_deletions where user_id=p_user_id)
 and exists(select 1 from public.sources s join public.items i on i.id=s.item_id and i.user_id=s.user_id where s.id=b.source_id and s.user_id=b.user_id and s.deleted_at is null and i.deleted_at is null);
 return found;
end; $$;
create or replace function public.kipto_finish_backup(p_user_id uuid,p_source_id uuid,p_revision integer,p_hash text)
returns boolean language plpgsql security definer set search_path='' as $$
begin
 update public.source_backups b set state='ready',updated_at=now(),active_until='-infinity'
 where b.user_id=p_user_id and b.source_id=p_source_id and b.revision=p_revision and b.content_hash=p_hash and b.state in ('reserved','ready')
 and not exists(select 1 from public.account_deletions where user_id=p_user_id)
 and exists(select 1 from public.sources s where s.id=b.source_id and s.user_id=b.user_id and s.revision=b.revision and s.content_hash=b.content_hash and s.deleted_at is null);
 return found;
end; $$;
create or replace function public.kipto_begin_account_delete(p_user_id uuid,p_request_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare actual uuid; deadline timestamptz;
begin
 perform pg_advisory_xact_lock(hashtextextended('kipto-backup-'||p_user_id::text,0));
 insert into public.account_deletions(user_id,request_id) values(p_user_id,p_request_id) on conflict(user_id) do nothing;
 select request_id into actual from public.account_deletions where user_id=p_user_id;
 update public.source_backups set state='deleting' where user_id=p_user_id;
 select max(active_until) into deadline from public.source_backups where user_id=p_user_id;
 return jsonb_build_object('requestId',actual,'pending',coalesce(deadline>now(),false));
end; $$;
revoke all on function public.kipto_begin_account_delete(uuid,uuid) from public,anon,authenticated;
grant execute on function public.kipto_begin_account_delete(uuid,uuid) to service_role;
select cron.schedule('kipto-purge-deletion-receipts','30 3 * * *',$job$delete from public.account_deletions where state='complete' and completed_at<now()-interval '90 days';$job$);
-- Rollback retains pending deletion locks and receipts; do not re-enable writes
-- for accounts whose owner has already confirmed deletion.
