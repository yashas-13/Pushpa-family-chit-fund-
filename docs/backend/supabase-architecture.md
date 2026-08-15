# Pushpa Family Chit — Supabase Backend Architecture

## Runtime

The mobile client will use Supabase directly for ordinary data operations:

- Supabase Auth for Agent/member identity.
- PostgreSQL + RLS for application data and authorization.
- Supabase Storage for private payment proofs and receipts.
- Supabase Realtime for payment/draw status updates.
- PostgreSQL functions for atomic business transitions.
- Edge Functions only when external services or secrets are required.

The Flutter app must contain only the Supabase publishable key. Never embed a service-role or secret key in the mobile binary.

## Roles

There is one `agent` role and up to 20 `member` accounts in the initial chit.

### Agent

Can manage the chit, members, installments, payment verification, and reports for the chit they created.

### Member

Can read their own private records and the minimum current-chit information required to make the monthly payment. A member cannot read another member's private payment history, payment proof, or receipts.

## Core data model

```text
profiles
  └── chit_members ──> chits
                         └── installments
                               ├── draws
                               │    └── draw_participants
                               └── payment_obligations
                                    └── payment_submissions
                                         └── receipts

payment_destinations
notifications
audit_logs
```

## Lucky Dip

`public.finalize_lucky_draw(installment_id)` is the only application entry point for finalizing a draw.

The function:

1. Authenticates the caller as the Agent.
2. Locks the installment row to serialize concurrent draw attempts.
3. Rejects a second draw for the same installment.
4. Calculates eligible active members using the chit repeat-winner policy.
5. Snapshots the participant list.
6. Selects an index using `pgcrypto.gen_random_bytes` with rejection sampling, avoiding modulo bias.
7. Persists the winner and participant snapshot.
8. Creates payment obligations for every active member except the winner.
9. Moves the installment into `collection_open`.
10. Writes an audit event.

The client never supplies the winner ID.

## Payment lifecycle

```text
pending obligation
       ↓
member submits proof
       ↓
submitted
   ↙         ↘
rejected     verified
   ↓             ↓
resubmit       receipt
```

Only the Agent can perform the verification transition. Verification checks the submitted amount against the obligation and creates a receipt atomically.

A rejected obligation can receive a new submission, but there can be only one active (`submitted`) or verified submission for an obligation at a time.

## Payment destination privacy

`payment_destinations` is directly readable only by the owner and Agent. Members obtain the current winner's payment destination through `public.get_payment_destination(installment_id)`, which checks that the caller belongs to the chit and has an obligation for that installment.

## Storage

Private buckets:

- `payment-proofs/{chit_id}/{installment_id}/{member_user_id}/{filename}`
- `receipts/{chit_id}/{member_user_id}/{receipt_id}.pdf`

Bucket configuration is in `supabase/config.toml` for local development. Storage RLS policies are applied by `supabase/migrations/20260815000400_storage_policies.sql`.

## RLS policy strategy

Every application table in `public` has RLS enabled. Policies use `auth.uid()` and private security-definer helpers. The helpers are kept in the unexposed `private` schema and have their search path pinned to an empty value.

Do not add privileged helper functions to the exposed API schemas.

## Deployment sequence

1. Create a Supabase project.
2. Link the project with the Supabase CLI.
3. Apply database migrations with `supabase db push`.
4. Configure the two private Storage buckets using the Storage API/Dashboard or the project's configuration workflow.
5. Create the Agent account through Supabase Auth.
6. Create the Agent profile with role `agent` using a trusted provisioning path.
7. Create member Auth accounts and profiles.
8. Create the Pushpa Family Chit and 21 installments.
9. Verify RLS with two separate member identities and the Agent identity.
10. Run Lucky Dip concurrency and payment-state tests before production use.

## Security rules

- Never ship service-role/secret keys in Flutter.
- Keep payment proofs and receipts private.
- Never allow client writes to draw winners, audit logs, receipts, or payment verification state.
- Use database transactions for Lucky Dip finalization and payment verification.
- Treat verified payments and finalized draws as immutable business events.
- Add explicit indexes for RLS predicates and common dashboard queries.
