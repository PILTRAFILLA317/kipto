-- Preserve tombstone identity/relationships without retaining deleted content.
create or replace function public.kipto_deleted_rows_stay_deleted() returns trigger
language plpgsql set search_path='' as $$
begin
 if old.deleted_at is not null then new := old; end if;
 if new.deleted_at is null then return new; end if;
 case TG_TABLE_NAME
 when 'items' then new.title:='Deleted'; new.summary:='';
 when 'sources' then new.original_name:='Deleted'; new.text_content:=null;
 when 'facts' then
  new.key:='deleted'; new.value_type:='text'; new.value:='{"text":"Deleted"}'::jsonb;
  new.user_value:=null; new.evidence:='{"page":null,"quote":null,"verification":"unverified"}'::jsonb;
 when 'item_actions' then
  new.title:='Deleted'; new.state:='dismissed'; new.execution_state:='notRequested';
  new.accepted_at:=null; new.evidence_fact_ids:='{}'::uuid[];
  new.payload:=case new.kind when 'keep' then '{}'::jsonb when 'remind' then '{"instant":null,"zone":null}'::jsonb
   else '{"allDay":false,"start":null,"end":null,"startDate":null,"endDateExclusive":null,"zone":null,"location":null}'::jsonb end;
 when 'reminders' then new.title:=null; new.time_zone:='UTC'; new.remind_at:='1970-01-01T00:00:00Z';
 else null;
 end case;
 return new;
end; $$;
-- Covers existing tombstones only; live content is not modified.
do $$ declare t text; begin
 foreach t in array array['items','sources','facts','item_actions','reminders'] loop
  execute format('update public.%I set deleted_at=deleted_at where deleted_at is not null',t);
 end loop;
end; $$;
create or replace function public.kipto_begin_source_delete(p_user_id uuid,p_source_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare wait_until timestamptz; paths jsonb;
begin
 perform pg_advisory_xact_lock(hashtextextended('kipto-backup-'||p_user_id::text,0));
 -- Invalidates even local-only analysis whose metadata was never synced.
 update public.analysis_requests set state='failed',error_code='deleted',updated_at=now()
  where user_id=p_user_id and source_id=p_source_id;
 delete from public.analysis_request_results x using public.analysis_requests r
  where x.user_id=r.user_id and x.request_id=r.request_id and r.user_id=p_user_id and r.source_id=p_source_id;
 update public.sources set deleted_at=coalesce(deleted_at,now()),client_updated_at=greatest(client_updated_at,now()) where id=p_source_id and user_id=p_user_id;
 update public.source_backups set state='deleting',updated_at=now() where source_id=p_source_id and user_id=p_user_id;
 select max(active_until),coalesce(jsonb_agg(object_path),'[]') into wait_until,paths from public.source_backups where source_id=p_source_id and user_id=p_user_id;
 return jsonb_build_object('pending',coalesce(wait_until>now(),false),'paths',paths);
end; $$;
-- Rollback preserves redaction: never restore user-deleted text from backups.
