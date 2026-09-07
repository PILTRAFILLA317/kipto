-- Private bucket creation via the officially documented SQL mechanism.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('kipto-sources','kipto-sources',false,20971520,
 array['image/jpeg','image/png','image/webp','image/heic','image/heif','application/pdf','text/plain']);
create table public.source_backups (
 user_id uuid not null references auth.users(id) on delete cascade,
 source_id uuid not null,
 revision integer not null check(revision>0),
 content_hash text not null check(content_hash ~ '^[a-f0-9]{64}$'),
 byte_size bigint not null check(byte_size between 1 and 20971520),
 object_path text not null unique,
 state text not null check(state in ('reserved','ready','deleting')),
 updated_at timestamptz not null default now(),
 primary key(user_id,source_id,revision),
 foreign key(source_id,user_id) references public.sources(id,user_id)
);
alter table public.source_backups enable row level security;
revoke all on public.source_backups from anon,authenticated;
grant select on public.source_backups to authenticated;
grant all on public.source_backups to service_role;
create policy source_backups_read on public.source_backups for select to authenticated
 using(user_id=(select auth.uid()));
-- No INSERT/UPDATE policy: every upload goes through the bounded backend.
create policy kipto_originals_read on storage.objects for select to authenticated
 using(bucket_id='kipto-sources' and exists(select 1 from public.source_backups b
 where b.user_id=(select auth.uid()) and b.object_path=name and b.state='ready'));
create or replace function public.kipto_reserve_backup(p_user_id uuid,p_source_id uuid,p_revision integer)
returns jsonb language plpgsql security definer set search_path='' as $$
declare s public.sources%rowtype; b public.source_backups%rowtype; used bigint;
begin
 perform pg_advisory_xact_lock(hashtextextended('kipto-backup-'||p_user_id::text,0));
 select * into s from public.sources where id=p_source_id and user_id=p_user_id and deleted_at is null;
 if not found or s.revision<>p_revision then return jsonb_build_object('error','sourceUnavailable'); end if;
 select * into b from public.source_backups where user_id=p_user_id and source_id=p_source_id and revision=p_revision;
 if found and b.state='ready' and b.content_hash=s.content_hash then return to_jsonb(b); end if;
 if found and (b.state='deleting' or b.content_hash<>s.content_hash or b.byte_size<>s.byte_size) then return jsonb_build_object('error','sourceChanged'); end if;
 if not exists(select 1 from public.billing_entitlements e join public.analysis_limits l on l.id=true
 where e.user_id=p_user_id and e.environment=l.billing_environment and e.entitlement='kipto_pro' and e.active and e.expires_at>now()) then
 return jsonb_build_object('error','proRequired'); end if;
 if b.source_id is not null then return to_jsonb(b); end if;
 select coalesce(sum(byte_size),0) into used from public.source_backups where user_id=p_user_id;
 if used+s.byte_size>1073741824 then return jsonb_build_object('error','storageQuota'); end if;
 insert into public.source_backups(user_id,source_id,revision,content_hash,byte_size,object_path,state)
 values(p_user_id,p_source_id,p_revision,s.content_hash,s.byte_size,
 p_user_id::text||'/'||p_source_id::text||'/'||p_revision::text||'/original.'||case s.mime_type when 'application/pdf' then 'pdf' when 'text/plain' then 'txt' when 'image/jpeg' then 'jpg' when 'image/png' then 'png' when 'image/webp' then 'webp' else 'heic' end,'reserved') returning * into b;
 return to_jsonb(b);
end; $$;
create or replace function public.kipto_finish_backup(p_user_id uuid,p_source_id uuid,p_revision integer,p_hash text)
returns boolean language plpgsql security definer set search_path='' as $$
begin
 update public.source_backups b set state='ready',updated_at=now()
 where b.user_id=p_user_id and b.source_id=p_source_id and b.revision=p_revision and b.content_hash=p_hash and b.state in ('reserved','ready')
 and exists(select 1 from public.sources s where s.id=b.source_id and s.user_id=b.user_id and s.revision=b.revision and s.content_hash=b.content_hash and s.deleted_at is null);
 return found;
end; $$;
revoke all on function public.kipto_reserve_backup(uuid,uuid,integer) from public,anon,authenticated;
revoke all on function public.kipto_finish_backup(uuid,uuid,integer,text) from public,anon,authenticated;
grant execute on function public.kipto_reserve_backup(uuid,uuid,integer) to service_role;
grant execute on function public.kipto_finish_backup(uuid,uuid,integer,text) to service_role;
-- Rollback: disable new upload endpoints; retain bucket, reservations and read
-- access so paid expiry or application rollback cannot strand originals.
