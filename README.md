# Pushpa Family Chit Fund

Serverless cross-platform family chit management app.

## Current scope

- 1 Agent + 20 Members
- 21-month chit
- ₹15,000 monthly contribution per member
- Monthly Lucky Dip winner selection
- Direct member → winner payment tracking
- Payment proof and Agent verification
- Digital receipts
- Member data isolation
- Audit trail

## Backend foundation

Supabase is the backend platform:

- PostgreSQL
- Supabase Auth
- Row Level Security (RLS)
- Private Storage
- Realtime
- PostgreSQL database functions
- Edge Functions only where external integrations/secrets require them

### Repository structure

```text
supabase/
├── migrations/
│   ├── 20260815000100_initial_schema.sql
│   └── 20260815000200_payment_resubmission.sql
├── storage-policies.sql
└── seed.sql

docs/
├── backend/
│   └── supabase-architecture.md
└── superpowers/
    ├── plans/
    └── specs/
```

## Security model

Every application table has RLS enabled. Members can access only their own private records plus the limited information needed to pay the current monthly winner. The Agent can manage the chit they own.

Lucky Dip winner selection is server-authoritative and uses cryptographic randomness in PostgreSQL. The client never submits a winner ID.

Payment verification, receipt creation, draw finalization, and audit events are handled as transactional backend operations.

**Never place a Supabase service-role/secret key in the mobile app.** Use the publishable key with RLS for client access.

## Development

The Supabase migrations are the source of truth for the database schema. Apply them to a disposable development project first, then verify RLS and transaction behavior with separate Agent and Member identities before production deployment.

The Flutter client scaffolding and production Supabase project configuration are the next implementation phase.
