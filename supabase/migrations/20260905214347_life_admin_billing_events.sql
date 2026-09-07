create table public.billing_events (
 event_id text not null check(char_length(event_id) between 1 and 200),
 user_id uuid not null references auth.users(id) on delete cascade,
 environment text not null check(environment in ('production','sandbox')),
 event_at timestamptz not null, verified_at timestamptz not null default now(),
 primary key(event_id,user_id)
);
create index billing_events_retention_idx on public.billing_events(verified_at);
alter table public.billing_events enable row level security;
revoke all on public.billing_events from anon,authenticated;
grant all on public.billing_events to service_role;
create or replace function public.kipto_apply_billing_event(p_event_id text,p_user_id uuid,p_environment text,p_event_at timestamptz,p_active boolean,p_expires_at timestamptz)
returns text language plpgsql security definer set search_path='' as $$
begin
 perform pg_advisory_xact_lock(hashtextextended('kipto-billing-'||p_user_id::text,0));
 if not exists(select 1 from auth.users where id=p_user_id) then return 'unknownUser'; end if;
 if exists(select 1 from public.billing_events where event_id=p_event_id and user_id=p_user_id) then return 'duplicate'; end if;
 insert into public.billing_events(event_id,user_id,environment,event_at) values(p_event_id,p_user_id,p_environment,p_event_at);
 insert into public.billing_entitlements(user_id,environment,entitlement,active,expires_at,verified_at,event_at)
 values(p_user_id,p_environment,'kipto_pro',p_active,p_expires_at,now(),p_event_at)
 on conflict(user_id,environment) do update set active=excluded.active,expires_at=excluded.expires_at,verified_at=excluded.verified_at,event_at=excluded.event_at
 where billing_entitlements.event_at<excluded.event_at;
 return 'applied';
end; $$;
create or replace function public.kipto_billing_status()
returns jsonb language sql stable security definer set search_path='' as $$
 select jsonb_build_object('pro',exists(select 1 from public.billing_entitlements e
 join public.analysis_limits l on l.id=true and l.billing_environment=e.environment
 where e.user_id=(select auth.uid()) and e.active and e.expires_at>now()),'used',coalesce((select reserved_count
 from public.analysis_usage_monthly where user_id=(select auth.uid()) and usage_month=date_trunc('month',now() at time zone 'UTC')::date),0));
$$;
revoke all on function public.kipto_apply_billing_event(text,uuid,text,timestamptz,boolean,timestamptz) from public,anon,authenticated;
grant execute on function public.kipto_apply_billing_event(text,uuid,text,timestamptz,boolean,timestamptz) to service_role;
revoke all on function public.kipto_billing_status() from public,anon;
grant execute on function public.kipto_billing_status() to authenticated;
select cron.schedule('kipto-purge-billing-events','15 3 * * *',$job$delete from public.billing_events where verified_at<now()-interval '180 days';$job$);
-- Rollback: stop webhook ingestion, retain entitlements and receipts. Expiry
-- remains time-based and does not depend on delivery of a future event.
