-- Authenticated write denial and backend reserve/lease gates while deletion is pending.
begin;
select set_config('kipto.test.owner',gen_random_uuid()::text,true);
select set_config('kipto.test.item',gen_random_uuid()::text,true);
select set_config('kipto.test.source',gen_random_uuid()::text,true);
insert into auth.users(id,aud,role,is_anonymous) values(current_setting('kipto.test.owner')::uuid,'authenticated','authenticated',true);
insert into public.items(id,user_id,title,summary,status,created_at,client_updated_at) values(current_setting('kipto.test.item')::uuid,current_setting('kipto.test.owner')::uuid,'Synthetic','','active',now(),now());
insert into public.sources(id,item_id,user_id,kind,origin,original_name,mime_type,byte_size,content_hash,created_at,client_updated_at) values(current_setting('kipto.test.source')::uuid,current_setting('kipto.test.item')::uuid,current_setting('kipto.test.owner')::uuid,'text','manual','Synthetic','text/plain',3,repeat('a',64),now(),now());
insert into public.source_backups(user_id,source_id,revision,content_hash,byte_size,object_path,state) values(current_setting('kipto.test.owner')::uuid,current_setting('kipto.test.source')::uuid,1,repeat('a',64),3,current_setting('kipto.test.owner')||'/'||current_setting('kipto.test.source')||'/1/original.txt','reserved');
do $$ declare u uuid:=current_setting('kipto.test.owner')::uuid; s uuid:=current_setting('kipto.test.source')::uuid; r jsonb; begin
 if not public.kipto_backup_upload_lease(u,s,1) then raise exception 'Lease unavailable'; end if;
 r:=public.kipto_begin_account_delete(u,gen_random_uuid());
 if (r->>'pending')::boolean is not true then raise exception 'Deletion ignored live upload'; end if;
 if public.kipto_backup_upload_lease(u,s,1) then raise exception 'Lease issued after deletion'; end if;
 if public.kipto_reserve_backup(u,s,1)->>'error' <> 'sourceUnavailable' then raise exception 'Backup reserved after deletion'; end if;
 if public.kipto_reserve_analysis(u,gen_random_uuid(),s,1,repeat('a',64))->>'decision' <> 'failed' then raise exception 'Analysis reserved after deletion'; end if;
end; $$;
set local role authenticated;
select set_config('request.jwt.claim.sub',current_setting('kipto.test.owner'),true);
do $$ begin
 if public.kipto_account_writable() then raise exception 'Deleting account remains writable'; end if;
 begin
  insert into public.items(id,user_id,title,summary,status,created_at,client_updated_at) values(gen_random_uuid(),current_setting('kipto.test.owner')::uuid,'Denied','','active',now(),now());
  raise exception 'Deleting account inserted new data';
 exception when insufficient_privilege then null; end;
end; $$;
reset role;
rollback;
