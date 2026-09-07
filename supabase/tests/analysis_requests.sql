-- Synthetic assertions only. All users, reservations and usage are rolled back.
begin;
do $$
declare u uuid:=gen_random_uuid(); request_id uuid:=gen_random_uuid(); source_id uuid:=gen_random_uuid(); first jsonb; next jsonb;
begin
 insert into auth.users(id,aud,role,is_anonymous) values(u,'authenticated','authenticated',true);
 first:=public.kipto_reserve_analysis(u,request_id,source_id,1,repeat('a',64));
 if first->>'decision'<>'reserved' then raise exception 'Initial reserve failed'; end if;
 next:=public.kipto_reserve_analysis(u,request_id,source_id,1,repeat('a',64));
 if next->>'decision'<>'busy' then raise exception 'Duplicate request was not busy'; end if;
 if (select reserved_count from public.analysis_usage_monthly where user_id=u)<>1 then raise exception 'Double quota reservation'; end if;
 next:=public.kipto_reserve_analysis(u,request_id,source_id,1,repeat('b',64));
 if next->>'decision'<>'mismatch' then raise exception 'Changed payload accepted'; end if;
 perform public.kipto_complete_analysis(u,request_id,(first->>'leaseToken')::uuid,
  jsonb_build_object('requestId',request_id,'output',jsonb_build_object('sourceRevision',1),'usage',jsonb_build_object('inputTokens',1,'outputTokens',1)));
 next:=public.kipto_reserve_analysis(u,request_id,source_id,1,repeat('a',64));
 if next->>'decision'<>'cached' then raise exception 'Completed result not reused'; end if;
 update public.analysis_request_results set expires_at=now()-interval '1 second' where user_id=u;
 next:=public.kipto_reserve_analysis(u,request_id,source_id,1,repeat('a',64));
 if next->>'decision'<>'expired' then raise exception 'Expired sensitive result served'; end if;
 request_id:=gen_random_uuid();
 first:=public.kipto_reserve_analysis(u,request_id,source_id,1,repeat('c',64));
 perform public.kipto_fail_analysis(u,request_id,(first->>'leaseToken')::uuid,'providerIndeterminate',null);
 next:=public.kipto_reserve_analysis(u,request_id,source_id,1,repeat('c',64));
 if next->>'decision'<>'indeterminate' then raise exception 'Ambiguous provider request restarted'; end if;
 if has_function_privilege('authenticated','public.kipto_reserve_analysis(uuid,uuid,uuid,integer,text)','EXECUTE') then raise exception 'Client can reserve for arbitrary user'; end if;
 if has_table_privilege('authenticated','public.analysis_request_results','SELECT') then raise exception 'Sensitive result table exposed'; end if;
end; $$;
rollback;
