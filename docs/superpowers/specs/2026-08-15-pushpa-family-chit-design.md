# Pushpa Family Chit — Product Design

## 1. Goal

Build a native-feeling cross-platform mobile app for one private family chit with 1 Agent/Admin and 20 Members across 21 months. Android uses Jetpack Compose, iOS uses SwiftUI, and Kotlin Multiplatform shares domain, data, validation, and financial logic. Supabase is the serverless backend.

## 2. Roles

### Agent/Admin
- Manage the chit and 20 members.
- Does not contribute ₹15,000 monthly.
- Acts as organizer/manager and cash/payment guarantor according to the chit agreement.
- Month 2 is permanently fixed for the Agent; no random/manual member selection is allowed for Month 2.
- For other months, choose server-authoritative Random Lucky Dip or Agent manual member selection.
- View all payment obligations, winner collections, submitted proofs, guarantee exposure, receipts, reports, notifications, chat, and audit logs.

### Member
- Authenticate into an individual account.
- Contribute ₹15,000 per month.
- View only their own private payment/status/history.
- View the current month's winner and payment destination details required to pay them.
- Submit payment details/proof and optionally share a proof image into the family group.
- View verification status, receipts, and their personal gain/loss position.

### Winner
- A member who wins a month receives a collection dashboard for that month.
- The winner confirms actual receipt of each member payment.
- A payment screenshot is evidence of a payment claim, not proof of receipt; winner confirmation is required before the payment is considered received.
- The Agent retains administrative oversight and dispute/guarantee controls.

## 3. Chit Rules and Financial Model

- 20 contributing members.
- 21 monthly installments.
- Default member contribution: ₹15,000 per month.
- Monthly member collection: ₹3,00,000.
- Agent contribution: ₹0.
- Month 2 winner: Agent, fixed by business rule.
- Supplied payout schedule:
  - Month 1: ₹2,64,000
  - Month 2: Agent
  - Month 3: ₹2,66,000
  - Month 4: ₹2,68,000
  - Month 5: ₹2,70,000
  - Month 6: ₹2,72,000
  - Month 7: ₹2,75,000
  - Month 8: ₹2,78,000
  - Month 9: ₹2,82,000
  - Month 10: ₹2,86,000
  - Month 11: ₹2,90,000
  - Month 12: ₹2,95,000
  - Month 13: ₹3,00,000
  - Month 14: ₹3,06,000
  - Month 15: ₹3,12,000
  - Month 16: ₹3,19,000
  - Month 17: ₹3,26,000
  - Month 18: ₹3,34,000
  - Month 19: ₹3,42,000
  - Month 20: ₹3,51,000
  - Month 21: ₹3,61,000
- Schedule values are stored as configurable rupee amounts in the database; the application must not hard-code the schedule into UI logic.
- A member who wins a scheduled member month pays ₹15,000 for all 21 months, so their simple contribution-vs-payout result is `payout - ₹3,15,000`.
- Monthly pool margin is `₹3,00,000 - scheduled payout`; negative values are Agent guarantee exposure if the agreement requires the Agent to cover the shortfall.
- Agent's Month-2 personal receipt is distinct from chit-pool margin reporting because the Agent is not a contributing member.
- All financial reports must distinguish gross collection, winner payout, member gain/loss, Agent guarantee amount, Agent expenses, and net Agent position. The app must not automatically label every difference as profit.

## 4. Winner Selection

- Month 2 is `FIXED_AGENT` and cannot be overridden through normal UI operations.
- Other months support `RANDOM` or `MANUAL`.
- Random selection is server-authoritative and cryptographically secure.
- Participant list is locked before a draw.
- Manual selection is server-validated against eligibility.
- Every draw records method, eligible participant snapshot, selected winner, actor, timestamp, and immutable audit identifier.
- A finalized draw cannot be silently rerun or edited.

## 5. Payment and Guarantee Flow

1. Agent starts the monthly cycle.
2. Eligible participant list and scheduled payout are calculated.
3. Winner is fixed/drawn/selected according to the month rule.
4. Winner/payment destination details are shown to members who need to pay.
5. Each member pays the winner outside the app.
6. Member submits payment amount, method, transaction/reference information, and optional private proof.
7. Winner reviews the payment claim and confirms actual receipt.
8. Agent has administrative oversight and can resolve disputes according to authorization rules.
9. Verified payment produces a receipt and immutable ledger event.
10. If a required winner payout is not fully covered by member collections and the agreement requires a guarantee, the Agent guarantee ledger records the shortfall separately.
11. Monthly cycle closes when the configured collection condition is satisfied.

The app is not a money custodian and does not hold or transfer member funds.

## 6. Communication and Notifications

- One authenticated family group is available to Agent and all 20 members.
- Chat supports text, images/payment screenshots, winner announcements, and system messages.
- Payment proof is private by default and can be explicitly shared to the family group.
- Push and in-app reminders cover payment due, payment overdue, winner announcement, payment proof submitted, payment received/verified, winner collection pending, Agent guarantee used, monthly start, and chat messages.
- Notification preferences are persisted per user.

## 7. Screens

### Agent
- Login
- Dashboard
- Winner Selection
- Draw Result
- Monthly Payment Status
- Winner Collection
- Payment Verification
- Members List
- Member Details
- Chit Schedule
- Winners
- Financial Reports
- Member Gain/Loss
- Agent Guarantee Ledger
- Receipts
- Notifications
- Family Chat
- Settings
- Audit Log

### Member
- Login
- Personal Dashboard
- Current Payment / Pay-to-Winner Details
- Submit Payment Proof
- Payment History
- Chit/Winner Status
- My Gain/Loss
- Receipts
- Notifications
- Family Chat
- Profile

### Winner
- Winner Collection Dashboard
- Member-by-member payment status
- Proof review
- Confirm receipt
- Pending payment reminders
- Final collection confirmation

## 8. Security and Integrity

- Backend-enforced role-based access control.
- Members cannot query another member's private payment data even by manipulating API requests.
- HTTPS for all network traffic.
- Secure authentication/session management.
- Server-authoritative draw execution.
- Immutable/finalized draw records with participant snapshot, winner, timestamp, and draw identifier.
- Financial corrections represented as audited adjustment events rather than silent mutation of verified history.
- Payment proofs stored separately from transactional records with access control.
- No service-role key or privileged backend credential in mobile binaries.

## 9. Data Model

Core entities: users/profiles, members, chits, chit_members, installments, draws, draw_participants, winners, payment_obligations, payment_submissions, payment_verifications, winner_receipts, agent_guarantees, receipts, notifications, notification_preferences, chat_rooms, chat_messages, chat_attachments, and audit_logs.

## 10. Architecture

### Android
- Separate native Android application module.
- Jetpack Compose Material 3 UI.

### iOS
- Native SwiftUI application.
- Shared KMP framework consumed by Swift.

### Shared KMP
- Kotlin Multiplatform domain models.
- Financial calculations and validation.
- Supabase repository/data layer.
- Auth/session state.
- Payment/draw state models.

### Backend
- Supabase PostgreSQL for transactional data.
- Supabase Auth for authentication.
- RLS for authorization/data isolation.
- Storage for private payment proofs and receipts.
- Realtime for chat and status updates.
- Edge Functions/database functions for privileged state transitions, Lucky Dip, winner finalization, payment verification, notifications, and receipts.

## 11. State Model

Payment submission states: `DUE → CLAIMED → RECEIPT_PENDING → VERIFIED` or `REJECTED → CLAIMED`.

Draw states: `DRAFT → PARTICIPANTS_LOCKED → FINAL`.

Winner selection modes: `RANDOM`, `MANUAL`, `FIXED_AGENT`.

A `FINAL` draw cannot be changed through normal application operations.

## 12. MVP Acceptance Criteria

- Agent can manage exactly one initial chit with 20 contributing members and 21 months.
- Agent does not have a monthly ₹15,000 member obligation.
- Month 2 is always the Agent winner and cannot be selected through Lucky Dip/manual member selection.
- Agent can choose Random Lucky Dip or Manual selection for other months.
- Members see the current winner and their own ₹15,000 obligation.
- Members can submit external-payment proof.
- Winner can confirm actual receipt of each payment.
- Agent can oversee payment verification and disputes.
- Verified payments generate receipts.
- Members can use the family group chat and optionally share payment screenshots.
- Payment reminders and push/in-app notification categories work through server-driven events.
- Member access is isolated from other members' private data.
- Draws, payment corrections, guarantee usage, and financial adjustments have auditable history.
- Android and iOS use native UI with shared KMP business/data logic.
