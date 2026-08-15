# Storage policy source of truth

Storage access policies are applied by:

`supabase/migrations/20260815000400_storage_policies.sql`

Bucket configuration is defined in `supabase/config.toml` for local development:

- `payment-proofs` — private, image/PDF evidence, 10 MiB limit.
- `receipts` — private, PDF only, 5 MiB limit.

Do not edit the Supabase `storage` metadata tables directly. Use Storage API/configuration and RLS policies instead.
