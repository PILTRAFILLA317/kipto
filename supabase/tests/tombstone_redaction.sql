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
select set_config('request.jwt.claim.sub',current_setting('kipto.test.a'),true);
do $$ declare t text; begin
 foreach t in array array['items','sources','facts','item_actions','reminders'] loop
  execute format('update public.%I set deleted_at=now() where user_id=$1',t) using current_setting('kipto.test.a')::uuid;
 end loop;
 if exists(select 1 from public.items where user_id=current_setting('kipto.test.a')::uuid and (title<>'Deleted' or summary<>'')) then raise exception 'Deleted item retains text'; end if;
 if exists(select 1 from public.sources where user_id=current_setting('kipto.test.a')::uuid and (original_name<>'Deleted' or text_content is not null)) then raise exception 'Deleted source retains text'; end if;
 if exists(select 1 from public.facts where user_id=current_setting('kipto.test.a')::uuid and (value<>'{"text":"Deleted"}'::jsonb or user_value is not null or evidence->>'quote' is not null)) then raise exception 'Deleted fact retains content'; end if;
 if exists(select 1 from public.item_actions where user_id=current_setting('kipto.test.a')::uuid and (title<>'Deleted' or state<>'dismissed' or payload<>'{}'::jsonb)) then raise exception 'Deleted action retains content'; end if;
 update public.items set deleted_at=null,title='Restore attempt' where id=current_setting('kipto.test.item')::uuid;
 if exists(select 1 from public.items where id=current_setting('kipto.test.item')::uuid and (deleted_at is null or title<>'Deleted')) then raise exception 'Tombstone resurrected'; end if;
end; $$;
reset role;
rollback;
