# Pushpa Family Chit — Product Design

## 1. Goal

Build a cross-platform mobile app for one private family chit with 1 Agent/Admin and 20 Members across 21 months. The app manages the chit ledger, Lucky Dip winner selection, direct member-to-winner payment obligations, payment proof, agent verification, receipts, notifications, and audit history.

## 2. Roles

### Agent/Admin
- Manage the chit and 20 members.
- Configure contribution, schedule, prize/chit amounts, eligibility rules, and payment details.
- Start and finalize monthly Lucky Dip draws.
- View all payment obligations and submitted proofs.
- Verify/reject payments and record correction events through an audit trail.
- View winners, receipts, reports, and audit logs.

### Member
- Authenticate into an individual account.
- View only their own payment/status/history.
- View the current month's winner and payment destination details required to pay them.
- Submit payment method, transaction/reference information, and optional proof.
- View verification status and receipts.

## 3. Chit Rules

- 20 members.
- 21 monthly installments.
- Default member contribution: ₹15,000 per month.
- Monthly pool based on 20 contributors is ₹3,00,000; prize/chit amounts from the supplied sheet remain configurable rather than hard-coded.
- Monthly winner is selected using a server-authoritative cryptographically secure Lucky Dip.
- Participant list is locked before a draw.
- A finalized draw cannot be silently rerun or edited.
- Winner eligibility is configurable; default is one win per member for months 1–20, with an explicit configurable rule for month 21.

## 4. Payment Flow

1. Agent starts the monthly cycle.
2. Eligible participant list is calculated and locked.
3. Secure Lucky Dip selects one winner.
4. Winner/payment destination details are shown to members who need to pay.
5. Each member pays the winner outside the app.
6. Member submits payment details/proof.
7. Agent verifies or rejects the submission.
8. Verified payment produces a receipt and immutable ledger event.
9. Month is completed when the configured collection condition is satisfied.

The app is not a money custodian and does not represent the Agent as receiving/distributing member funds.

## 5. Screens

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
- Winners
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
- Receipts
- Notifications
- Profile

## 6. Security and Integrity

- Backend-enforced role-based access control.
- Members cannot query another member's private payment data even by manipulating API requests.
- HTTPS for all network traffic.
- Secure authentication/session management.
- Server-authoritative draw execution.
- Immutable/finalized draw records with participant snapshot, winner, timestamp, and draw identifier.
- Financial corrections represented as audited adjustment events rather than silent mutation of verified history.
- Payment proofs stored separately from transactional records with access control.

## 7. Data Model

Core entities: users, members, chits, chit_members, installments, draws, draw_participants, winners, payment_obligations, payment_submissions, payment_verifications, receipts, notifications, and audit_logs.

## 8. Architecture

Recommended client: Flutter for Android and iOS from one codebase.

Recommended backend: typed REST API with PostgreSQL for transactional data and object storage for payment proofs/receipts. The backend owns authorization, chit state transitions, Lucky Dip randomness, payment state transitions, and audit logging.

## 9. State Model

Payment submission states: PENDING_VERIFICATION → VERIFIED or REJECTED.

Draw states: DRAFT → PARTICIPANTS_LOCKED → FINAL.

A FINAL draw cannot be changed through normal application operations.

## 10. MVP Acceptance Criteria

- Agent can create/manage exactly one initial chit with 20 members and 21 months.
- Agent can run a secure Lucky Dip and obtain exactly one winner.
- Members see the current winner and their own ₹15,000 obligation.
- Members can submit external-payment proof.
- Agent can verify/reject submissions.
- Verified payments generate receipts.
- Member access is isolated from other members' private data.
- Draws and financial corrections have auditable history.
- Android and iOS share the same application codebase.
