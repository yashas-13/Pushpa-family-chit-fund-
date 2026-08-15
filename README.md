# Pushpa Family Chit Fund

Native cross-platform family chit management app with a fully serverless Supabase backend.

## Product

- 1 Agent + 20 Members
- 21-month chit
- ₹15,000 monthly contribution per member
- Agent contributes ₹0 and manages/guarantees the chit according to the agreement
- Month 2 is fixed for the Agent
- Other months support server-authoritative Random Lucky Dip or Agent Manual winner selection
- Direct member → winner payment tracking
- Winner confirms actual payment receipt
- Agent oversight, guarantee ledger, receipts, audit trail
- Family group chat with optional payment-screenshot sharing
- Push and in-app payment reminders

## Native mobile architecture

- Android: Jetpack Compose
- iOS: SwiftUI
- Shared business/data layer: Kotlin Multiplatform
- Backend: Supabase PostgreSQL, Auth, RLS, Storage, Realtime, database functions and Edge Functions where external secrets/integrations are required

## Financial model

```text
20 members × ₹15,000 = ₹3,00,000 monthly collection
21 months × ₹15,000 = ₹3,15,000 total contribution per member
Agent monthly contribution = ₹0
Month 2 winner = Agent
```

The supplied 21-month payout schedule is stored as configurable financial data. Member gain/loss and Agent surplus/guarantee exposure are calculated separately so the Agent is never treated as a contributing member.

## Security

- RLS on application tables
- Member private-data isolation
- Private payment proofs and receipts
- Server-authoritative Lucky Dip
- Finalized draws and verified payments are audited
- No service-role/secret Supabase key in mobile binaries
- Money is paid outside the app; the app is a ledger/verification/communication system, not a money custodian

## Repository

```text
androidApp/   Native Android UI
iosApp/       Native SwiftUI UI + XcodeGen spec
shared/       KMP domain + Supabase data layer
supabase/     Serverless PostgreSQL/RLS/Storage foundation
docs/         Product/backend architecture and implementation plans
.github/      Android, iOS, shared and Supabase CI
```

## Development

Android CI uses JDK 21 and Gradle 9.5.0. iOS CI generates the Xcode project with XcodeGen and uses Kotlin's `embedAndSignAppleFrameworkForXcode` direct-integration flow. Configure Supabase publishable URL/key through environment/platform configuration; never commit privileged credentials.
