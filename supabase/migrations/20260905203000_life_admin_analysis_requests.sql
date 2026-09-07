-- Backend-only quota ledger; clients never choose plans, limits or user IDs.
create extension if not exists pg_cron with schema pg_catalog;
create table public.analysis_limits (
 id boolean primary key default true check(id), free_monthly integer not null default 5 check(free_monthly>=0),
 pro_monthly integer not null default 100 check(pro_monthly>=0), global_daily integer not null default 1000 check(global_daily>=0),
 user_per_minute integer not null default 6 check(user_per_minute between 1 and 100),
 billing_environment text not null default 'production' check(billing_environment in ('production','sandbox'))
);
insert into public.analysis_limits(id) values(true);
-- Populated only by the authenticated RevenueCat webhook in FASE 11.
create table public.billing_entitlements (
 user_id uuid not null references auth.users(id) on delete cascade,
 environment text not null check(environment in ('production','sandbox')),
 entitlement text not null check(entitlement='kipto_pro'), active boolean not null default false,
 expires_at timestamptz, verified_at timestamptz not null, event_at timestamptz not null,
 primary key(user_id,environment)
);
create table public.analysis_usage_monthly (
 user_id uuid not null references auth.users(id) on delete cascade, usage_month date not null,
 reserved_count integer not null default 0 check(reserved_count>=0), primary key(user_id,usage_month)
);
create table public.analysis_global_daily (
 usage_date date primary key, reserved_count integer not null default 0 check(reserved_count>=0)
);
create table public.analysis_requests (
 user_id uuid not null references auth.users(id) on delete cascade, request_id uuid not null,
 source_id uuid not null, source_revision integer not null check(source_revision>0),
 payload_hash text not null check(payload_hash ~ '^[a-f0-9]{64}$'),
 state text not null check(state in ('reserved','succeeded','retryable','failed','indeterminate')),
 lease_token uuid not null, lease_expires_at timestamptz not null,
 retry_at timestamptz, attempts integer not null default 1 check(attempts between 1 and 3),
 error_code text check(char_length(error_code)<=100), created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(), primary key(user_id,request_id)
);
create index analysis_requests_rate_idx on public.analysis_requests(user_id,created_at);
create index analysis_requests_retention_idx on public.analysis_requests(created_at);
create table public.analysis_request_results (
 user_id uuid not null, request_id uuid not null, envelope jsonb not null check(octet_length(envelope::text)<=262144),
 expires_at timestamptz not null, primary key(user_id,request_id),
 foreign key(user_id,request_id) references public.analysis_requests(user_id,request_id) on delete cascade
);
create index analysis_results_expiry_idx on public.analysis_request_results(expires_at);

create or replace function public.kipto_reserve_analysis(p_user_id uuid,p_request_id uuid,p_source_id uuid,p_source_revision integer,p_payload_hash text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare r public.analysis_requests%rowtype; limits public.analysis_limits%rowtype;
 result jsonb; current_month date := date_trunc('month',now() at time zone 'UTC')::date;
 today date := (now() at time zone 'UTC')::date; quota integer; used integer; token uuid;
begin
 if p_source_revision < 1 or p_payload_hash !~ '^[a-f0-9]{64}$' then raise exception 'Invalid reservation'; end if;
 -- One short ledger lock keeps request, user and global reservations atomic.
 perform pg_advisory_xact_lock(hashtextextended('kipto-analysis-ledger',0));
 select * into r from public.analysis_requests where user_id=p_user_id and request_id=p_request_id for update;
 if found then
   if r.payload_hash<>p_payload_hash or r.source_id<>p_source_id or r.source_revision<>p_source_revision then return jsonb_build_object('decision','mismatch'); end if;
   if r.state='succeeded' then
     select envelope into result from public.analysis_request_results where user_id=p_user_id and request_id=p_request_id and expires_at>now();
     if found then return jsonb_build_object('decision','cached','envelope',result); end if;
     return jsonb_build_object('decision','expired');
   end if;
   if r.state='reserved' and r.lease_expires_at>now() then return jsonb_build_object('decision','busy','retryAfter',5); end if;
   if r.state='reserved' or r.state='indeterminate' then
     update public.analysis_requests set state='indeterminate',updated_at=now() where user_id=p_user_id and request_id=p_request_id;
     return jsonb_build_object('decision','indeterminate');
   end if;
   if r.state='failed' or r.attempts>=3 then return jsonb_build_object('decision','failed'); end if;
   if r.retry_at>now() then return jsonb_build_object('decision','busy','retryAfter',greatest(1,ceil(extract(epoch from r.retry_at-now()))::integer)); end if;
   token:=gen_random_uuid();
   update public.analysis_requests set state='reserved',attempts=attempts+1,lease_token=token,lease_expires_at=now()+interval '90 seconds',updated_at=now(),error_code=null where user_id=p_user_id and request_id=p_request_id;
   return jsonb_build_object('decision','reserved','leaseToken',token);
 end if;
 select * into strict limits from public.analysis_limits where id=true;
 if (select count(*) from public.analysis_requests where user_id=p_user_id and created_at>now()-interval '1 minute')>=limits.user_per_minute then return jsonb_build_object('decision','busy','retryAfter',60); end if;
 quota:=limits.free_monthly;
 if exists(select 1 from public.billing_entitlements e where e.user_id=p_user_id and e.environment=limits.billing_environment and e.entitlement='kipto_pro' and e.active and e.expires_at>now()) then quota:=limits.pro_monthly; end if;
 insert into public.analysis_usage_monthly(user_id,usage_month) values(p_user_id,current_month) on conflict do nothing;
 select reserved_count into used from public.analysis_usage_monthly where user_id=p_user_id and usage_month=current_month;
 if used>=quota then return jsonb_build_object('decision','quotaBlocked'); end if;
 insert into public.analysis_global_daily(usage_date) values(today) on conflict do nothing;
 select reserved_count into used from public.analysis_global_daily where usage_date=today;
 if used>=limits.global_daily then return jsonb_build_object('decision','globalLimit','retryAfter',300); end if;
 token:=gen_random_uuid();
 insert into public.analysis_requests(user_id,request_id,source_id,source_revision,payload_hash,state,lease_token,lease_expires_at) values(p_user_id,p_request_id,p_source_id,p_source_revision,p_payload_hash,'reserved',token,now()+interval '90 seconds');
 update public.analysis_usage_monthly set reserved_count=reserved_count+1 where user_id=p_user_id and usage_month=current_month;
 update public.analysis_global_daily set reserved_count=reserved_count+1 where usage_date=today;
 insert into public.analysis_usage_daily(user_id,usage_date,request_count) values(p_user_id,today,1)
 on conflict(user_id,usage_date) do update set request_count=public.analysis_usage_daily.request_count+1,updated_at=now();
 return jsonb_build_object('decision','reserved','leaseToken',token);
end; $$;

create or replace function public.kipto_complete_analysis(p_user_id uuid,p_request_id uuid,p_lease_token uuid,p_envelope jsonb)
returns void language plpgsql security definer set search_path = '' as $$
declare r public.analysis_requests%rowtype;
begin
 select * into r from public.analysis_requests where user_id=p_user_id and request_id=p_request_id for update;
 if not found or r.lease_token<>p_lease_token or r.state<>'reserved' then raise exception 'Inactive lease'; end if;
 if p_envelope->>'requestId'<>p_request_id::text or (p_envelope->'output'->>'sourceRevision')::integer<>r.source_revision then raise exception 'Envelope mismatch'; end if;
 insert into public.analysis_request_results(user_id,request_id,envelope,expires_at) values(p_user_id,p_request_id,p_envelope,now()+interval '1 hour');
 update public.analysis_requests set state='succeeded',updated_at=now() where user_id=p_user_id and request_id=p_request_id;
 update public.analysis_usage_daily set success_count=success_count+1,input_tokens=input_tokens+(p_envelope->'usage'->>'inputTokens')::bigint,output_tokens=output_tokens+(p_envelope->'usage'->>'outputTokens')::bigint,updated_at=now() where user_id=p_user_id and usage_date=(r.created_at at time zone 'UTC')::date;
end; $$;
create or replace function public.kipto_fail_analysis(p_user_id uuid,p_request_id uuid,p_lease_token uuid,p_error_code text,p_retry_after integer default null)
returns void language plpgsql security definer set search_path = '' as $$
declare r public.analysis_requests%rowtype;
begin
 select * into r from public.analysis_requests where user_id=p_user_id and request_id=p_request_id for update;
 if not found or r.lease_token<>p_lease_token or r.state<>'reserved' then return; end if;
 update public.analysis_requests set state=case when p_error_code='providerRateLimited' and attempts<3 then 'retryable'
 when p_error_code in ('providerIndeterminate','serviceUnavailable') then 'indeterminate' else 'failed' end,
 error_code=left(p_error_code,100),retry_at=now()+make_interval(secs=>greatest(1,least(300,coalesce(p_retry_after,30)))),updated_at=now()
 where user_id=p_user_id and request_id=p_request_id;
 if p_error_code<>'providerRateLimited' or r.attempts>=3 then
 update public.analysis_usage_daily set error_count=error_count+1,updated_at=now() where user_id=p_user_id and usage_date=(r.created_at at time zone 'UTC')::date;
 end if;
end; $$;

-- No client-visible policies or grants on accounting, receipts or entitlements.
do $$ declare t text; begin
 foreach t in array array['analysis_limits','billing_entitlements','analysis_usage_monthly','analysis_global_daily','analysis_requests','analysis_request_results'] loop
   execute format('alter table public.%I enable row level security',t);
   execute format('revoke all on public.%I from anon,authenticated',t);
   execute format('grant all on public.%I to service_role',t);
 end loop;
end; $$;
revoke all on function public.kipto_reserve_analysis(uuid,uuid,uuid,integer,text) from public,anon,authenticated;
revoke all on function public.kipto_complete_analysis(uuid,uuid,uuid,jsonb) from public,anon,authenticated;
revoke all on function public.kipto_fail_analysis(uuid,uuid,uuid,text,integer) from public,anon,authenticated;
grant execute on function public.kipto_reserve_analysis(uuid,uuid,uuid,integer,text) to service_role;
grant execute on function public.kipto_complete_analysis(uuid,uuid,uuid,jsonb) to service_role;
grant execute on function public.kipto_fail_analysis(uuid,uuid,uuid,text,integer) to service_role;
select cron.schedule('kipto-purge-analysis-results','*/10 * * * *',
  $job$delete from public.analysis_request_results where expires_at<=now(); delete from public.analysis_requests where created_at<now()-interval '90 days';$job$);
-- Application rollback: stop analyze-source; preserve quota receipts and keep
-- the result purge active. Never make sensitive results accessible to clients.
