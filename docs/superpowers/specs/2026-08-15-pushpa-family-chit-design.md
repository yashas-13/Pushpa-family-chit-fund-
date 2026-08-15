# Pushpa Family Chit — Product Design

## 1. Goal

Build a cross-platform mobile app for one private family chit with 1 Agent/Admin and 20 Members across 21 months. The app manages the chit ledger, Lucky Dip winner selection, direct member-to-winner payment obligations, payment proof, agent verification, receipts, notifications, financial reconciliation, member gain/loss reporting, agent guarantee exposure, and audit history.

## 2. Locked Commercial Rules

- Exactly 20 paying members.
- Exactly 21 monthly installments.
- Every member contributes exactly ₹15,000 per month.
- Agent contribution is exactly ₹0 for all 21 months.
- Monthly expected member collection is ₹3,00,000.
- Total member contribution obligation over 21 months is ₹63,00,000.
- The Agent is not modeled as a 21st contributing member.
- Agent responsibility is modeled separately as management, collection administration, payout execution, and cash guarantee exposure where applicable.
- The existing supplied 21-month financial sheet is the authoritative source for the exact month-by-month payout, member gain/loss, and agent profit/loss rules. Those values/formulas must be represented as explicit configuration/data, not silently replaced by a generic chit formula.
- Where an exact sheet value is not present in the repository, the implementation must not invent it; the configuration remains explicit and requires the supplied value before production use.

## 3. Roles

### Agent/Admin
- Manage the chit and 20 members.
- Configure contribution, schedule, prize/chit amounts, eligibility rules, and payment details.
- Start and finalize monthly Lucky Dip draws.
- View all payment obligations and submitted proofs.
- Verify/reject payments and record correction events through an audit trail.
- View winners, receipts, reports, financial reconciliation, member gain/loss, agent guarantee exposure, and audit logs.

### Member
- Authenticate into an individual account.
- View only their own private payment/status/history.
- View the current month's winner and payment destination details required to pay them.
- Submit payment method, transaction/reference information, and optional proof.
- View verification status, receipts, contribution history, and current/projected gain/loss.

## 4. Financial Model

The financial engine is deterministic, shared by all client platforms, and independent of UI code.

### Monthly expected collection

`expectedCollection = memberCount × monthlyContribution = 20 × ₹15,000 = ₹3,00,000`

### Member position

`totalPaid = sum(verified contributions)`

`totalReceived = sum(verified payouts)`

`netPosition = totalReceived - totalPaid`

The UI must distinguish historical cash position from final projected economic position when future obligations remain.

### Agent exposure

`collectionShortfall = expectedCollection - actualVerifiedCollection`

Where the configured guarantee rule requires coverage, the shortfall creates an explicit agent guarantee event. Recovery creates a separate recovery event. Agent contribution remains ₹0 regardless of guarantee exposure.

### Month lifecycle

`DRAFT → OPEN → COLLECTING → COLLECTION_CLOSED → PAYOUT_READY → PAYOUT_COMPLETED → RECONCILED → CLOSED`

A closed month is immutable through normal application operations. Corrections are append-only adjustment/reversal events.

### Reconciliation invariant

A month can close only when the configured reconciliation equation balances. A mismatch creates a reconciliation exception and blocks closure.

### Exact Model C integration

The application will expose a versioned financial configuration containing the authoritative 21 monthly rows from the supplied sheet. Each row can define the month-specific winner/payout amount, applicable discount/benefit, member gain/loss effect, group surplus/shortfall, agent management margin, and agent guarantee requirement as applicable.

The engine will calculate from ledger events and this configuration; it will not derive unknown commercial values from assumptions.

## 5. Winner Model

Monthly winner selection remains server-authoritative and cryptographically secure. The participant list is locked before selection. A finalized draw cannot be silently rerun or edited.

Winner eligibility is configurable. The default is one win per member for months 1–20, with an explicit configurable rule for month 21.

## 6. Payment Flow

1. Agent starts the monthly cycle.
2. Eligible participant list is calculated and locked.
3. Secure Lucky Dip selects one winner.
4. Winner/payment destination details are shown to members who need to pay.
5. Each member pays the winner outside the app.
6. Member submits payment details/proof.
7. Agent verifies or rejects the submission.
8. Verified payment produces a receipt and immutable ledger event.
9. Financial engine recalculates month/member/agent positions.
10. Month is completed only after configured reconciliation succeeds.

The app is not a money custodian and does not represent the Agent as receiving/distributing member funds.

## 7. Screens

### Agent
- Login
- Dashboard
- Lucky Dip
- Draw Result
- Monthly Payment Status
- Payment Verification
- Members List
- Member Details
- Chit Schedule
- Financial Schedule
- Winners
- Member Gain/Loss
- Agent Exposure / Margin
- Reconciliation
- Reports
- Receipts
- Notifications
- Settings
- Audit Log

### Member
- Login
- Personal Dashboard
- Current Payment / Pay-to-Winner Details
- Submit Payment Proof
- Payment History
- Chit/Winner Status
- Financial Position
- Receipts
- Notifications
- Profile

## 8. Security and Integrity

- Backend-enforced role-based access control.
- Members cannot query another member's private payment data even by manipulating API requests.
- HTTPS for all network traffic.
- Secure authentication/session management.
- Server-authoritative draw execution.
- Immutable/finalized draw records with participant snapshot, winner, timestamp, and draw identifier.
- Financial corrections represented as audited adjustment events rather than silent mutation of verified history.
- Payment proofs stored separately from transactional records with access control.
- Financial amounts use integer minor units (`paise`) or PostgreSQL `numeric`; floating-point arithmetic is prohibited for money.
- Idempotency keys prevent duplicate payment recording and duplicate financial events.

## 9. Data Model

Core entities: users, members, chits, chit_members, chit_months, financial_schedule, installments, draws, draw_participants, winners, payment_obligations, payment_submissions, payment_verifications, payouts, ledger_accounts, ledger_entries, agent_guarantees, guarantee_events, financial_adjustments, reconciliation_runs, receipts, notifications, and audit_logs.

## 10. Architecture

Client: Flutter for Android and iOS from one codebase.

Backend: Supabase/PostgreSQL with Row Level Security, private object storage, realtime where useful, and PostgreSQL functions/Edge Functions only where required for transactional operations or external integrations.

The backend owns authorization, chit state transitions, Lucky Dip randomness, payment state transitions, financial calculations, reconciliation, and audit logging. The mobile client consumes typed application data and never implements authoritative financial calculations.

## 11. State Model

Payment submission states: `PENDING_VERIFICATION → VERIFIED | REJECTED`.

Draw states: `DRAFT → PARTICIPANTS_LOCKED → FINAL`.

Month states: `DRAFT → OPEN → COLLECTING → COLLECTION_CLOSED → PAYOUT_READY → PAYOUT_COMPLETED → RECONCILED → CLOSED`.

A `FINAL` draw and `CLOSED` month cannot be changed through normal application operations.

## 12. MVP Acceptance Criteria

- Agent can create/manage exactly one initial chit with 20 members and 21 months.
- Agent can run a secure Lucky Dip and obtain exactly one winner.
- Members see the current winner and their own ₹15,000 obligation.
- Members can submit external-payment proof.
- Agent can verify/reject submissions.
- Verified payments generate receipts.
- Member access is isolated from other members' private data.
- Draws and financial corrections have auditable history.
- The financial engine enforces 20 × ₹15,000 monthly collection and ₹0 Agent contribution.
- The financial engine supports the exact supplied 21-month Model C schedule without inventing missing commercial values.
- Member gain/loss and Agent guarantee exposure are derived from immutable ledger events.
- Android and iOS share the same application codebase.
- Financial engine tests cover all 21 months, invariants, idempotency, reversals, reconciliation failures, and role isolation.
