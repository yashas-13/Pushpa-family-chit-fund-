# Financial Engine Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a production-safe Flutter/Supabase foundation for the 21-month family chit, with deterministic financial calculations, immutable ledger events, Model C schedule configuration, reconciliation, and automated tests.

**Architecture:** Flutter provides the Android/iOS client. Supabase/PostgreSQL is authoritative for persistence, authorization, transactional state transitions, and financial records. The shared Dart domain/financial engine is pure and deterministic; server-side SQL constraints/functions enforce the same commercial invariants so clients cannot bypass them.

**Tech Stack:** Flutter/Dart, Supabase PostgreSQL, SQL migrations, RLS, GitHub Actions, `flutter_test`/Dart tests.

## Global Constraints

- Exactly 20 paying members.
- Exactly 21 monthly installments.
- Every member contributes exactly ₹15,000 per month.
- Agent contribution is exactly ₹0 for all 21 months.
- Monthly expected member collection is ₹3,00,000.
- Total member contribution obligation over 21 months is ₹63,00,000.
- Exact Model C month-by-month values from the supplied sheet must be configuration/data; unknown values must never be invented.
- Financial amounts must use integer paise or PostgreSQL numeric; floating-point money arithmetic is prohibited.
- Verified financial history is append-only; corrections use audited reversal/adjustment events.
- Closed months and final draws are immutable through normal application operations.
- Members must be isolated from other members' private records through backend authorization/RLS.
- The mobile app must never contain a Supabase service-role/secret key.

## Planned File Structure

```text
lib/
  domain/
    models/
      money.dart
      chit_config.dart
      financial_schedule_row.dart
      ledger_entry.dart
      member_position.dart
      agent_exposure.dart
      month_reconciliation.dart
    financial/
      contribution_engine.dart
      position_engine.dart
      guarantee_engine.dart
      reconciliation_engine.dart
  data/
    repositories/
      financial_repository.dart
supabase/
  migrations/
    20260815000300_financial_engine.sql
  seed.sql
    model_c_schedule_seed.sql
  tests/
    financial_invariants.sql
    rls_financial.sql
test/
  domain/financial/
    contribution_engine_test.dart
    position_engine_test.dart
    guarantee_engine_test.dart
    reconciliation_engine_test.dart
    model_c_schedule_test.dart
.github/workflows/
  flutter.yml
```

### Task 1: Establish the Flutter application shell

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `lib/app.dart`
- Create: `test/smoke_test.dart`

**Interfaces:**
- Produces a bootable Flutter application for Android/iOS and a stable package boundary for the pure financial domain.

- [ ] **Step 1: Write the failing smoke test**

Create a widget test that imports `App` and expects the root application to render without throwing.

- [ ] **Step 2: Run the test and verify failure**

Run `flutter test test/smoke_test.dart -r expanded`.
Expected: FAIL because the Flutter shell does not yet exist.

- [ ] **Step 3: Add the minimal Flutter shell**

Create `main.dart` with `runApp(const App())` and `app.dart` with a `MaterialApp` root and a simple financial-dashboard placeholder route. Keep all financial calculations out of widgets.

- [ ] **Step 4: Run the test and verify pass**

Run `flutter test test/smoke_test.dart -r expanded`.
Expected: PASS.

- [ ] **Step 5: Commit**

Commit with `feat: scaffold flutter application shell`.

### Task 2: Build the pure money and contribution model

**Files:**
- Create: `lib/domain/models/money.dart`
- Create: `lib/domain/models/chit_config.dart`
- Create: `lib/domain/financial/contribution_engine.dart`
- Create: `test/domain/financial/contribution_engine_test.dart`

**Interfaces:**
- `Money.fromPaise(int paise)` and `Money.paise`.
- `ChitConfig(memberCount, monthlyContributionPaise, monthCount, agentContributionPaise)`.
- `ContributionEngine.expectedMonthlyCollection(ChitConfig)` returns `Money`.
- `ContributionEngine.totalMemberObligation(ChitConfig)` returns `Money`.

- [ ] **Step 1: Write failing invariant tests**

Test that the locked configuration computes ₹3,00,000 monthly and ₹63,00,000 over 21 months, and rejects an agent contribution other than zero.

- [ ] **Step 2: Run tests and verify failure**

Run `flutter test test/domain/financial/contribution_engine_test.dart -r expanded`.
Expected: FAIL because the model and engine do not exist.

- [ ] **Step 3: Implement integer-paise money and deterministic contribution calculations**

Use checked integer multiplication and explicit validation for 20 members, 21 months, ₹15,000/member/month, and ₹0 agent contribution in the locked initial configuration.

- [ ] **Step 4: Run tests and verify pass**

Run the same test command. Expected: PASS.

- [ ] **Step 5: Commit**

Commit with `feat: add deterministic contribution engine`.

### Task 3: Add Model C schedule representation

**Files:**
- Create: `lib/domain/models/financial_schedule_row.dart`
- Create: `test/domain/financial/model_c_schedule_test.dart`
- Create: `supabase/seed/model_c_schedule_seed.sql`

**Interfaces:**
- `FinancialScheduleRow(monthNumber, winnerPayoutPaise, discountPaise, memberNetEffectPaise, groupSurplusPaise, agentMarginPaise, agentGuaranteePaise, sourceVersion)`.
- Month numbers are exactly 1..21.

- [ ] **Step 1: Write failing validation tests**

Test that duplicate/missing month numbers are rejected and that the schedule cannot be treated as complete unless all 21 authoritative rows exist.

- [ ] **Step 2: Run tests and verify failure**

Run `flutter test test/domain/financial/model_c_schedule_test.dart -r expanded`.
Expected: FAIL because schedule validation does not exist.

- [ ] **Step 3: Implement schedule validation and seed contract**

Create typed schedule rows and a SQL seed contract. Do not fabricate values not present in the supplied sheet. The seed must clearly reject incomplete production configuration rather than silently supplying generic chit values.

- [ ] **Step 4: Run tests and verify pass**

Run the model C test suite. Expected: PASS for validation behavior.

- [ ] **Step 5: Commit**

Commit with `feat: add versioned model c schedule contract`.

### Task 4: Implement member position calculations

**Files:**
- Create: `lib/domain/models/member_position.dart`
- Create: `lib/domain/financial/position_engine.dart`
- Create: `test/domain/financial/position_engine_test.dart`

**Interfaces:**
- `MemberPosition(totalPaidPaise, totalReceivedPaise, netPositionPaise, remainingObligationPaise)`.
- `PositionEngine.calculate(verifiedContributions, verifiedPayouts, futureObligationPaise)`.

- [ ] **Step 1: Write failing tests**

Cover a member with only contributions, a member who receives a payout, and a member with future obligations.

- [ ] **Step 2: Run tests and verify failure**

Run `flutter test test/domain/financial/position_engine_test.dart -r expanded`.
Expected: FAIL.

- [ ] **Step 3: Implement the pure calculation**

Use integer paise and define `netPosition = totalReceived - totalPaid`. Never infer a payout from a contribution count.

- [ ] **Step 4: Run tests and verify pass**

Expected: PASS.

- [ ] **Step 5: Commit**

Commit with `feat: add member position engine`.

### Task 5: Implement agent guarantee exposure

**Files:**
- Create: `lib/domain/models/agent_exposure.dart`
- Create: `lib/domain/financial/guarantee_engine.dart`
- Create: `test/domain/financial/guarantee_engine_test.dart`

**Interfaces:**
- `AgentExposure(currentExposurePaise, totalGuaranteeEventsPaise, totalRecoveriesPaise)`.
- `GuaranteeEngine.calculate(expectedCollectionPaise, actualCollectionPaise, configuredGuaranteePaise, recoveryPaise)`.

- [ ] **Step 1: Write failing tests**

Cover full collection, collection shortfall, guarantee coverage, and subsequent recovery. Assert agent contribution remains zero in every case.

- [ ] **Step 2: Run tests and verify failure**

Run `flutter test test/domain/financial/guarantee_engine_test.dart -r expanded`.
Expected: FAIL.

- [ ] **Step 3: Implement exposure calculation**

Separate agent contribution from guarantee exposure. A collection shortfall may create exposure only under the configured guarantee rule; recovery reduces exposure through a separate event.

- [ ] **Step 4: Run tests and verify pass**

Expected: PASS.

- [ ] **Step 5: Commit**

Commit with `feat: add agent guarantee exposure engine`.

### Task 6: Implement reconciliation

**Files:**
- Create: `lib/domain/models/month_reconciliation.dart`
- Create: `lib/domain/financial/reconciliation_engine.dart`
- Create: `test/domain/financial/reconciliation_engine_test.dart`

**Interfaces:**
- `MonthReconciliation(expectedCollectionPaise, actualCollectionPaise, payoutPaise, adjustmentsPaise, carryForwardPaise, balanced, differencePaise)`.
- `ReconciliationEngine.reconcile(...)`.

- [ ] **Step 1: Write failing tests**

Cover exact balance, short collection, unexplained difference, and a correction event that restores balance.

- [ ] **Step 2: Run tests and verify failure**

Expected: FAIL.

- [ ] **Step 3: Implement deterministic reconciliation**

Calculate all inputs from explicit ledger totals. Return a non-balanced result for unexplained differences; never round or silently absorb the difference.

- [ ] **Step 4: Run tests and verify pass**

Expected: PASS.

- [ ] **Step 5: Commit**

Commit with `feat: add monthly reconciliation engine`.

### Task 7: Add authoritative Supabase financial schema and RLS

**Files:**
- Create: `supabase/migrations/20260815000300_financial_engine.sql`
- Create: `supabase/tests/financial_invariants.sql`
- Create: `supabase/tests/rls_financial.sql`

**Interfaces:**
- Tables for `chit_months`, `financial_schedule`, `installments`, `payouts`, `ledger_accounts`, `ledger_entries`, `agent_guarantees`, `guarantee_events`, `financial_adjustments`, and `reconciliation_runs`.
- Database constraints enforce 20 members, 21 months, ₹15,000 member contribution, and ₹0 agent contribution for the initial product configuration.

- [ ] **Step 1: Write SQL tests for invariants and RLS**

Tests must attempt invalid agent contributions, duplicate member/month obligations, post-close mutation, member access to another member's private data, and unauthorized financial writes.

- [ ] **Step 2: Run tests against a disposable Supabase/PostgreSQL instance**

Expected: FAIL until migration and policies exist.

- [ ] **Step 3: Implement schema, constraints, indexes, triggers/functions, and RLS**

Use numeric/integer money columns, immutable ledger event IDs, unique idempotency keys, role-aware RLS, and explicit month/draw state transitions. Store payment proofs outside transactional tables with private storage policies.

- [ ] **Step 4: Run SQL tests**

Expected: PASS for valid operations and expected rejection of invalid operations.

- [ ] **Step 5: Commit**

Commit with `feat: add authoritative financial schema and rls`.

### Task 8: Wire repository boundaries and CI

**Files:**
- Create: `lib/data/repositories/financial_repository.dart`
- Create: `.github/workflows/flutter.yml`
- Modify: `README.md`

**Interfaces:**
- Repository methods expose typed reads/commands without exposing service-role credentials or embedding financial formulas in widgets.

- [ ] **Step 1: Write repository contract tests**

Verify that the repository delegates financial mutations to authorized backend operations and handles idempotency/reconciliation errors explicitly.

- [ ] **Step 2: Implement repository boundary and CI**

CI must run formatting, static analysis, Flutter tests, and SQL tests against the configured disposable database workflow.

- [ ] **Step 3: Run local verification**

Run `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`, and the PostgreSQL/Supabase test suite.

- [ ] **Step 4: Commit**

Commit with `ci: verify flutter and financial engine`.

## Final Verification

Before declaring the implementation complete, verify:

1. `20 × ₹15,000 = ₹3,00,000` monthly.
2. `₹3,00,000 × 21 = ₹63,00,000` total member obligation.
3. Agent contribution is always ₹0.
4. No floating-point money calculations exist.
5. Model C schedule cannot silently use invented values.
6. Member gain/loss derives from verified ledger events.
7. Agent exposure derives from explicit guarantee events.
8. Reconciliation blocks an unbalanced month.
9. Closed/finalized records cannot be silently mutated.
10. RLS prevents cross-member private-data access.
11. Duplicate financial events are rejected/idempotent.
12. Android/iOS client code shares the same financial domain implementation.
