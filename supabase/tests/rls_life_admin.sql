-- T17: two generated synthetic identities. JWT subject + authenticated role,
-- never service_role for assertions. Every row (including Storage metadata)
-- is rolled back; no blob is created or deleted through SQL.
begin;
select set_config('kipto.test.a',gen_random_uuid()::text,true);
select set_config('kipto.test.b',gen_random_uuid()::text,true);
select set_config('kipto.test.item',gen_random_uuid()::text,true);
select set_config('kipto.test.source',gen_random_uuid()::text,true);
insert into auth.users(id,aud,role,is_anonymous) values
 (current_setting('kipto.test.a')::uuid,'authenticated','authenticated',true),
 (current_setting('kipto.test.b')::uuid,'authenticated','authenticated',true);
insert into public.items(id,user_id,title,summary,status,created_at,client_updated_at)
 values(current_setting('kipto.test.item')::uuid,current_setting('kipto.test.a')::uuid,'Synthetic','', 'active',now(),now());
insert into public.sources(id,item_id,user_id,kind,origin,original_name,mime_type,byte_size,content_hash,created_at,client_updated_at)
 values(current_setting('kipto.test.source')::uuid,current_setting('kipto.test.item')::uuid,current_setting('kipto.test.a')::uuid,'text','manual','Synthetic','text/plain',3,repeat('a',64),now(),now());
insert into public.facts(id,item_id,user_id,source_id,source_revision,key,value_type,value,provenance,evidence,created_at,client_updated_at)
 values(gen_random_uuid(),current_setting('kipto.test.item')::uuid,current_setting('kipto.test.a')::uuid,current_setting('kipto.test.source')::uuid,1,'label','text','{"text":"Synthetic"}','user','{"page":null,"quote":null,"verification":"userConfirmed"}',now(),now());
insert into public.item_actions(id,item_id,user_id,kind,title,payload,origin,created_at,client_updated_at)
 values(gen_random_uuid(),current_setting('kipto.test.item')::uuid,current_setting('kipto.test.a')::uuid,'keep','Synthetic','{}','user',now(),now());
insert into public.reminders(id,item_id,user_id,remind_at,created_at,client_updated_at)
 values(gen_random_uuid(),current_setting('kipto.test.item')::uuid,current_setting('kipto.test.a')::uuid,now()+interval '1 day',now(),now());
insert into public.source_backups(user_id,source_id,revision,content_hash,byte_size,object_path,state)
 values(current_setting('kipto.test.a')::uuid,current_setting('kipto.test.source')::uuid,1,repeat('a',64),3,
 current_setting('kipto.test.a')||'/'||current_setting('kipto.test.source')||'/1/original.txt','ready');
insert into storage.objects(bucket_id,name,metadata) values('kipto-sources',current_setting('kipto.test.a')||'/'||current_setting('kipto.test.source')||'/1/original.txt','{"size":3,"mimetype":"text/plain"}');
set local role authenticated;
select set_config('request.jwt.claim.sub',current_setting('kipto.test.b'),true);
do $$ declare t text; n bigint; begin
 foreach t in array array['items','sources','facts','item_actions','reminders','source_backups'] loop
  execute format('select count(*) from public.%I where user_id=$1',t) into n using current_setting('kipto.test.a')::uuid;
  if n<>0 then raise exception 'Cross-user read: %',t; end if;
  if t<>'source_backups' then
   execute format('update public.%I set deleted_at=now() where user_id=$1',t) using current_setting('kipto.test.a')::uuid;
   get diagnostics n=row_count; if n<>0 then raise exception 'Cross-user mutation: %',t; end if;
  end if;
 end loop;
 if exists(select 1 from storage.objects where bucket_id='kipto-sources' and name=current_setting('kipto.test.a')||'/'||current_setting('kipto.test.source')||'/1/original.txt') then raise exception 'Cross-user storage read'; end if;
 begin
  insert into public.sources(id,item_id,user_id,kind,origin,original_name,mime_type,byte_size,content_hash,created_at,client_updated_at)
  values(gen_random_uuid(),current_setting('kipto.test.item')::uuid,current_setting('kipto.test.b')::uuid,'text','manual','Synthetic','text/plain',3,repeat('b',64),now(),now());
  raise exception 'Cross-owner relation accepted';
 exception when foreign_key_violation then null; end;
 begin
  perform public.kipto_reserve_backup(current_setting('kipto.test.a')::uuid,current_setting('kipto.test.source')::uuid,1);
  raise exception 'Internal backup RPC exposed';
 exception when insufficient_privilege then null; end;
 begin
  perform public.kipto_reserve_analysis(current_setting('kipto.test.a')::uuid,gen_random_uuid(),gen_random_uuid(),1,repeat('a',64));
  raise exception 'Internal analysis RPC exposed';
 exception when insufficient_privilege then null; end;
 begin
  insert into storage.objects(bucket_id,name) values('kipto-sources',current_setting('kipto.test.b')||'/unlimited');
  raise exception 'Direct client upload allowed';
 exception when insufficient_privilege then null; end;
end; $$;
select set_config('request.jwt.claim.sub',current_setting('kipto.test.a'),true);
do $$ begin
 if (select count(*) from public.sources where id=current_setting('kipto.test.source')::uuid)<>1 then raise exception 'Owner cannot read source'; end if;
 if (select count(*) from storage.objects where bucket_id='kipto-sources' and name=current_setting('kipto.test.a')||'/'||current_setting('kipto.test.source')||'/1/original.txt')<>1 then raise exception 'Owner cannot read backup'; end if;
end; $$;
reset role;
rollback;
