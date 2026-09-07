-- Cover the composite action FK without changing reminder data.
create index reminders_action_owner_idx on public.reminders(action_id,item_id,user_id);
-- Rollback: index can be dropped independently; keep action links and data.
