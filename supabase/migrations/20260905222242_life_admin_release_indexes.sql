create index billing_events_user_idx on public.billing_events(user_id);
create index source_backups_source_owner_idx on public.source_backups(source_id,user_id);
-- Rollback: drop index public.billing_events_user_idx; drop index public.source_backups_source_owner_idx;
