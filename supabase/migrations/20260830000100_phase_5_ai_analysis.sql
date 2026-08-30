create table public.analysis_usage_daily (
  user_id uuid not null references auth.users(id) on delete cascade,
  usage_date date not null,
  request_count integer not null default 0 check (request_count >= 0),
  success_count integer not null default 0 check (success_count >= 0),
  error_count integer not null default 0 check (error_count >= 0),
  input_tokens bigint not null default 0 check (input_tokens >= 0),
  output_tokens bigint not null default 0 check (output_tokens >= 0),
  updated_at timestamptz not null default now(),
  primary key (user_id, usage_date),
  constraint analysis_usage_counts_check check (
    success_count + error_count <= request_count
  )
);

create index analysis_usage_daily_date_idx
  on public.analysis_usage_daily (usage_date);

alter table public.analysis_usage_daily enable row level security;
revoke all on table public.analysis_usage_daily from public, anon, authenticated;
grant select, insert, update on table public.analysis_usage_daily to service_role;

create or replace function public.kipto_consume_analysis_quota(
  p_user_id uuid,
  p_limit integer
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  reserved_count integer;
begin
  if p_user_id is null or p_limit < 1 then
    return false;
  end if;

  insert into public.analysis_usage_daily (
    user_id,
    usage_date,
    request_count,
    updated_at
  ) values (
    p_user_id,
    current_date,
    1,
    now()
  )
  on conflict (user_id, usage_date) do update
    set request_count = public.analysis_usage_daily.request_count + 1,
        updated_at = now()
    where public.analysis_usage_daily.request_count < p_limit
  returning request_count into reserved_count;

  return reserved_count is not null;
end;
$$;

create or replace function public.kipto_record_analysis_usage(
  p_user_id uuid,
  p_success boolean,
  p_input_tokens bigint default 0,
  p_output_tokens bigint default 0
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.analysis_usage_daily
  set success_count = success_count + case when p_success then 1 else 0 end,
      error_count = error_count + case when p_success then 0 else 1 end,
      input_tokens = input_tokens + greatest(coalesce(p_input_tokens, 0), 0),
      output_tokens = output_tokens + greatest(coalesce(p_output_tokens, 0), 0),
      updated_at = now()
  where user_id = p_user_id and usage_date = current_date;
end;
$$;

revoke all on function public.kipto_consume_analysis_quota(uuid, integer)
  from public, anon, authenticated;
revoke all on function public.kipto_record_analysis_usage(
  uuid, boolean, bigint, bigint
) from public, anon, authenticated;
grant execute on function public.kipto_consume_analysis_quota(uuid, integer)
  to service_role;
grant execute on function public.kipto_record_analysis_usage(
  uuid, boolean, bigint, bigint
) to service_role;

