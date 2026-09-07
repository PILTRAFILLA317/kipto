-- T18/T19 ledger assertions. No external provider calls or paid events.
begin;
do $$ declare u uuid:=gen_random_uuid(); item uuid:=gen_random_uuid(); source uuid:=gen_random_uuid(); result jsonb; i integer; begin
 insert into auth.users(id,aud,role,is_anonymous,raw_user_meta_data) values(u,'authenticated','authenticated',true,'{"isPro":true}');
 insert into public.items(id,user_id,title,summary,status,created_at,client_updated_at) values(item,u,'Synthetic','','active',now(),now());
 insert into public.sources(id,item_id,user_id,kind,origin,original_name,mime_type,byte_size,content_hash,created_at,client_updated_at)
 values(source,item,u,'text','manual','Synthetic','text/plain',3,repeat('a',64),now(),now());
 result:=public.kipto_reserve_backup(u,source,1);
 if result->>'error'<>'proRequired' then raise exception 'Client metadata granted backup'; end if;
 for i in 1..5 loop
  result:=public.kipto_reserve_analysis(u,gen_random_uuid(),source,1,repeat('a',64));
  if result->>'decision'<>'reserved' then raise exception 'Free quota unavailable'; end if;
 end loop;
 result:=public.kipto_reserve_analysis(u,gen_random_uuid(),source,1,repeat('a',64));
 if result->>'decision'<>'quotaBlocked' then raise exception 'Client metadata granted Pro analysis'; end if;
 perform public.kipto_apply_billing_event('synthetic-new',u,'production',now(),true,now()+interval '1 month');
 perform public.kipto_apply_billing_event('synthetic-new',u,'production',now(),true,now()+interval '1 month');
 perform public.kipto_apply_billing_event('synthetic-old',u,'production',now()-interval '1 day',false,now()-interval '1 day');
 if (select count(*) from public.billing_events where user_id=u)<>2 then raise exception 'Duplicate receipt'; end if;
 if not (select active from public.billing_entitlements where user_id=u and environment='production') then raise exception 'Old event revoked current access'; end if;
 result:=public.kipto_reserve_backup(u,source,1);
 if result->>'state'<>'reserved' then raise exception 'Verified Pro could not reserve'; end if;
 result:=public.kipto_reserve_backup(u,source,1);
 if (select count(*) from public.source_backups where user_id=u)<>1 then raise exception 'Duplicate storage reservation'; end if;
 if (select state from public.source_backups where user_id=u)<>'reserved' then raise exception 'Unsent upload marked ready'; end if;
 update public.billing_entitlements set expires_at=now()-interval '1 second' where user_id=u;
 if not exists(select 1 from public.sources where id=source) then raise exception 'Expired plan destroyed source'; end if;
end; $$;
rollback;
