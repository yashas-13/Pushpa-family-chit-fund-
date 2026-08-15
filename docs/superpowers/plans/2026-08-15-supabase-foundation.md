# Pushpa Family Chit Supabase Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the serverless Supabase foundation for the Pushpa Family Chit app with a secure PostgreSQL schema, RLS authorization, auditable Lucky Dip primitives, and payment/receipt data flows.

**Architecture:** Flutter will use Supabase Auth, the Data API, Storage, and Realtime directly for ordinary operations. PostgreSQL RLS will enforce Agent-vs-Member isolation; privileged business transitions such as Lucky Dip finalization will execute inside database functions with tightly scoped `SECURITY DEFINER` functions and explicit grants.

**Tech Stack:** Supabase PostgreSQL, Supabase Auth, PostgreSQL RLS, pgcrypto, Supabase Storage, Supabase Realtime, Flutter (later phase).

## Global Constraints

- Exactly one Agent role and up to 20 members for the initial Pushpa Family Chit.
- The chit has configurable monthly contribution and month count; the initial configuration is ₹15,000 for 21 months.
- Members pay the selected monthly winner outside the app; the app records obligations, submissions, verification, and receipts.
- Members must never read another member's private payment data.
- Lucky Dip selection is server-authoritative and cannot accept a client-supplied winner.
- Finalized draws and verified payments are append-only from the application's perspective.
- Service-role/secret keys must never be embedded in the Flutter application.
- Every exposed application table has RLS enabled and least-privilege grants.

---

### Task 1: Supabase PostgreSQL foundation

**Files:**
- Create: `supabase/migrations/20260815000100_initial_schema.sql`
- Create: `supabase/seed.sql`

**Interfaces:**
- Produces tables/enums/indexes for profiles, chits, memberships, installments, draws, participants, payment obligations, payment submissions, receipts, notifications, and audit logs.
- Produces helper functions for role/chit membership checks and secure Lucky Dip selection.

- [ ] **Step 1: Define enums and base tables**

Create stable UUID primary keys, foreign keys to `auth.users`, UTC timestamps, monetary `numeric(12,2)` values, unique member numbers per chit, and explicit lifecycle/status enums.

- [ ] **Step 2: Add integrity constraints and indexes**

Enforce positive contributions/amounts, valid month numbers, one membership per user per chit, one winner per installment, and indexes matching RLS predicates.

- [ ] **Step 3: Add seed data for deterministic local development**

Seed one sample chit configuration only; do not create fake Auth users because Auth owns `auth.users`.

- [ ] **Step 4: Commit the schema foundation**

Commit with `feat: add supabase chit schema`.

---

### Task 2: RLS authorization boundary

**Files:**
- Modify: `supabase/migrations/20260815000100_initial_schema.sql`
- Create: `supabase/tests/001_rls_and_draw.sql`

**Interfaces:**
- Agent can manage the complete chit.
- Member can read/update only their own permitted records.
- Members can read the current winner's payment destination through a controlled function, not by broadly reading private payment data.

- [ ] **Step 1: Enable RLS on every public application table**

Do not rely on dashboard defaults; enable it explicitly in migration SQL.

- [ ] **Step 2: Add role-aware policies**

Use `auth.uid()` plus a `SECURITY DEFINER` helper in an unexposed `private` schema for role/membership checks. Keep helper functions out of the exposed API surface.

- [ ] **Step 3: Restrict direct writes**

Members may submit payment claims but cannot mark payments verified, assign winners, finalize draws, alter audit history, or modify chit configuration.

- [ ] **Step 4: Add RLS test cases**

Test member isolation, agent access, payment-submission ownership, and rejection of member attempts to mutate privileged state. Tests must also verify a finalized draw cannot be overwritten through normal table writes.

- [ ] **Step 5: Commit the security layer**

Commit with `feat: enforce supabase rls authorization`.

---

### Task 3: Secure Lucky Dip transaction

**Files:**
- Modify: `supabase/migrations/20260815000100_initial_schema.sql`
- Modify: `supabase/tests/001_rls_and_draw.sql`

**Interfaces:**
- RPC: `public.finalize_lucky_draw(p_installment_id uuid)` returns the finalized draw/winner identifiers.
- RPC: `public.get_payment_destination(p_installment_id uuid)` returns only the current winner's payment destination for a member who owes that installment.

- [ ] **Step 1: Lock one draw per installment**

Use a database transaction and row locks so concurrent Agent requests cannot create competing finalized draws.

- [ ] **Step 2: Snapshot eligible participants**

Persist the exact eligible member IDs used by the draw before selecting the winner.

- [ ] **Step 3: Select the winner server-side**

Use `pgcrypto.gen_random_bytes` with rejection sampling to avoid modulo bias; never accept a winner ID from the client.

- [ ] **Step 4: Finalize atomically**

Create the draw, participant snapshot, winner record, and payment obligations in one transaction. If any step fails, none of the state is committed.

- [ ] **Step 5: Test concurrency and repeat-winner rules**

Verify only one final winner can exist per installment, previous winners are excluded when repeat winners are disabled, and the configured month-21 repeat policy is respected.

- [ ] **Step 6: Commit the Lucky Dip implementation**

Commit with `feat: add secure lucky dip transaction`.

---

### Task 4: Payment verification and audit model

**Files:**
- Modify: `supabase/migrations/20260815000100_initial_schema.sql`
- Modify: `supabase/tests/001_rls_and_draw.sql`

**Interfaces:**
- Members create `payment_submissions` for their own obligation.
- Agent verifies/rejects a submission through a transactional RPC.
- Verified submissions create receipts and audit entries.

- [ ] **Step 1: Add submission state machine constraints**

Allow `pending -> verified` or `pending -> rejected`; prohibit direct client transitions to terminal states.

- [ ] **Step 2: Implement verification RPC**

Lock the payment obligation and submission, validate Agent authorization, transition the state, and create an audit record atomically.

- [ ] **Step 3: Implement receipt creation**

Create a unique receipt number only after successful verification.

- [ ] **Step 4: Add audit immutability policies**

No authenticated client can update/delete audit records.

- [ ] **Step 5: Test invalid transitions**

Verify members cannot verify payments, rejected submissions cannot be verified without an explicit audited re-submission path, and verified payments cannot be silently edited.

- [ ] **Step 6: Commit the payment ledger layer**

Commit with `feat: add payment verification ledger`.

---

### Task 5: Storage and deployment documentation

**Files:**
- Create: `supabase/storage-policies.sql`
- Create: `docs/backend/supabase-architecture.md`
- Modify: `README.md`

**Interfaces:**
- Private `payment-proofs` and `receipts` storage buckets.
- Documented Flutter client boundary, environment variables, migration workflow, and production key handling.

- [ ] **Step 1: Define private storage policy SQL**

Members can upload/read their own payment proof; Agent can access proof files belonging to the managed chit. Receipt files remain private.

- [ ] **Step 2: Document the architecture**

Include schema relationships, RLS rules, Lucky Dip transaction semantics, payment lifecycle, and the distinction between publishable and secret keys.

- [ ] **Step 3: Update the repository README**

Add current project status and Supabase setup commands/workflow without embedding project credentials.

- [ ] **Step 4: Commit the deployment documentation**

Commit with `docs: document supabase backend setup`.

---

## Verification

- Run the Supabase local database test suite once the Supabase CLI is available.
- Apply migrations to a disposable Supabase project before production.
- Verify RLS with two member identities and one Agent identity.
- Verify two concurrent Lucky Dip calls result in one finalized winner.
- Verify a member cannot access another member's payment proof or receipt.
- Verify no service-role/secret key exists in the repository.
- Run Flutter integration tests against the development Supabase project in the next implementation phase.
