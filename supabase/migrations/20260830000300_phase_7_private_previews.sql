-- Phase 7: private, user-scoped optimized screenshot previews.
-- Originals are never uploaded to this bucket.

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'kipto-previews',
  'kipto-previews',
  false,
  15728640,
  array['image/jpeg', 'image/webp']
)
on conflict (id) do update set
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "kipto preview owners select" on storage.objects;
drop policy if exists "kipto preview owners insert" on storage.objects;
drop policy if exists "kipto preview owners update" on storage.objects;
drop policy if exists "kipto preview owners delete" on storage.objects;

create policy "kipto preview owners select"
on storage.objects for select
to authenticated
using (
  bucket_id = 'kipto-previews'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy "kipto preview owners insert"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'kipto-previews'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy "kipto preview owners update"
on storage.objects for update
to authenticated
using (
  bucket_id = 'kipto-previews'
  and (storage.foldername(name))[1] = (select auth.uid())::text
)
with check (
  bucket_id = 'kipto-previews'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy "kipto preview owners delete"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'kipto-previews'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

