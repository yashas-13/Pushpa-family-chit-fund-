-- Storage buckets are declared in supabase/config.toml.
-- This file contains only storage.objects access policies.

-- Payment proof path:
-- payment-proofs/{chit_id}/{installment_id}/{member_user_id}/{filename}
create policy payment_proofs_member_upload
on storage.objects
for insert to authenticated
with check (
  bucket_id = 'payment-proofs'
  and (storage.foldername(name))[1] is not null
  and (storage.foldername(name))[3] = (select auth.uid())::text
  and (select private.is_chit_member(((storage.foldername(name))[1])::uuid))
);

create policy payment_proofs_member_read_own
on storage.objects
for select to authenticated
using (
  bucket_id = 'payment-proofs'
  and (storage.foldername(name))[3] = (select auth.uid())::text
);

create policy payment_proofs_agent_read
on storage.objects
for select to authenticated
using (
  bucket_id = 'payment-proofs'
  and (select private.is_chit_agent(((storage.foldername(name))[1])::uuid))
);

-- Receipts path:
-- receipts/{chit_id}/{member_user_id}/{receipt_id}.pdf
create policy receipts_member_read_own
on storage.objects
for select to authenticated
using (
  bucket_id = 'receipts'
  and (storage.foldername(name))[2] = (select auth.uid())::text
);

create policy receipts_agent_read
on storage.objects
for select to authenticated
using (
  bucket_id = 'receipts'
  and (select private.is_chit_agent(((storage.foldername(name))[1])::uuid))
);

-- Members do not receive update/delete permissions for evidence or receipts.
-- Receipt generation and privileged storage writes should be performed server-side.
