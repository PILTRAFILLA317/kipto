-- Serialize reservations and deletion on the same per-account lock.
-- Preserve quota math and receipts; no data rewrite.
do $$
declare signature text; definition text; gate text;
begin
 foreach signature in array array[
 'public.kipto_reserve_analysis(uuid,uuid,uuid,integer,text)',
 'public.kipto_reserve_backup(uuid,uuid,integer)',
 'public.kipto_backup_upload_lease(uuid,uuid,integer)',
 'public.kipto_finish_backup(uuid,uuid,integer,text)',
 'public.kipto_begin_source_delete(uuid,uuid)'] loop
  select pg_get_functiondef(signature::regprocedure) into definition;
  definition := replace(definition, E'begin\n', E'begin\n perform pg_advisory_xact_lock(hashtextextended(\'kipto-backup-\'||p_user_id::text,0));\n');
  execute definition;
 end loop;
end; $$;
-- Rollback: keep serialization; removing it reopens deletion/upload races.
