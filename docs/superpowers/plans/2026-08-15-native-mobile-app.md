# Pushpa Family Chit Native Mobile App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task with verification checkpoints.

**Goal:** Build a production-oriented Android + iOS mobile application using Kotlin Multiplatform for shared business/data logic, Jetpack Compose for the Android UI, SwiftUI for the iOS UI, and Supabase as the serverless backend.

**Architecture:** Keep user interfaces platform-native while sharing domain models, chit calculations, validation, Supabase access, and state transitions in a Kotlin Multiplatform `shared` module. The Android application is a separate `androidApp` module and the iOS application is a native SwiftUI Xcode project consuming the shared framework. Supabase remains the authoritative source for authorization, Lucky Dip/manual winner rules, payments, notifications, chat, and audit history.

**Tech Stack:** Kotlin 2.4.10, Gradle 9.5.x, Android Gradle Plugin 9.1.x, Kotlin Multiplatform, Jetpack Compose Material 3, SwiftUI, Supabase Kotlin SDK 3.7.0, Ktor 3.5.1, Kotlinx Serialization, GitHub Actions.

## Global Constraints

- Exactly 1 Agent/Admin and 20 Members for the initial chit.
- Members contribute ₹15,000 per month; the Agent contributes ₹0.
- The monthly gross collection is ₹3,00,000.
- Month 2 is fixed for the Agent and cannot use Lucky Dip/manual member selection.
- Months other than Month 2 support Random Lucky Dip or Agent manual winner selection.
- The supplied 21-month prize schedule is configurable data, not hard-coded business logic.
- Member-to-winner payments happen outside the app; the app records obligations, proof, winner confirmation, Agent oversight, and receipts.
- Winner confirmation means actual receipt confirmation; a screenshot alone does not prove receipt.
- Members can access only their own private payment/history data plus information required to pay the current winner.
- Family chat is available to all authenticated users; payment proof is private by default and can be explicitly shared to the group.
- Push/in-app reminders are server-driven and persisted; platform push delivery is implemented through native notification adapters.
- No service-role or privileged Supabase key may ship in either mobile application.
- Server-authoritative Lucky Dip and immutable audit events remain mandatory.

---

### Task 1: KMP project and native application shells

**Files:**
- Create: `settings.gradle.kts`
- Create: `build.gradle.kts`
- Create: `gradle.properties`
- Create: `gradle/libs.versions.toml`
- Create: `shared/build.gradle.kts`
- Create: `androidApp/build.gradle.kts`
- Create: `androidApp/src/main/AndroidManifest.xml`
- Create: `androidApp/src/main/java/in/pravidh/pushpachit/MainActivity.kt`
- Create: `androidApp/src/main/java/in/pravidh/pushpachit/PushpaApplication.kt`
- Create: `iosApp/iosApp.swift`
- Create: `iosApp/ContentView.swift`
- Create: `iosApp/Info.plist`
- Create: `gradlew`
- Create: `gradlew.bat`
- Create: `gradle/wrapper/gradle-wrapper.properties`

**Interfaces:**
- `shared` exposes the `in.pravidh.pushpachit.shared` package to both platforms.
- `androidApp` depends on `shared` and owns the Android entry point.
- `iosApp` consumes the generated `SharedKit` framework.

- [ ] **Step 1: Create the Gradle settings and version catalog.**

Pin Kotlin 2.4.10, AGP 9.1.x, Gradle 9.5.x, Supabase Kotlin 3.7.0, and Ktor 3.5.1. Use Google's `com.android.kotlin.multiplatform.library` plugin for the KMP shared Android target.

- [ ] **Step 2: Configure the shared KMP module.**

Targets: Android plus iOS ARM64 and iOS Simulator ARM64. Export a static `SharedKit` framework for the iOS application. Configure Android minimum SDK 26 because the selected Supabase Kotlin client requires API 26+.

- [ ] **Step 3: Configure the Android application shell.**

Use a separate `com.android.application` module with Jetpack Compose Material 3. The application must contain no Supabase service-role credentials.

- [ ] **Step 4: Configure the native SwiftUI application shell.**

Create a SwiftUI `@main` application that imports `SharedKit` and displays the shared app state through a native SwiftUI view.

- [ ] **Step 5: Add a deterministic smoke screen on both platforms.**

The Android and iOS shells must render the same product identity and current chit summary without requiring a live Supabase project.

- [ ] **Step 6: Verify Gradle configuration.**

Run `./gradlew :shared:compileKotlinAndroid :shared:compileTestKotlinAndroid :androidApp:assembleDebug`. Expected result: successful compilation/build.

- [ ] **Step 7: Commit the shell.**

Commit message: `feat: scaffold native kmp mobile apps`

---

### Task 2: Shared chit domain and financial engine

**Files:**
- Create: `shared/src/commonMain/kotlin/in/pravidh/pushpachit/shared/domain/ChitModels.kt`
- Create: `shared/src/commonMain/kotlin/in/pravidh/pushpachit/shared/domain/ChitRules.kt`
- Create: `shared/src/commonMain/kotlin/in/pravidh/pushpachit/shared/domain/FinancialCalculator.kt`
- Create: `shared/src/commonTest/kotlin/in/pravidh/pushpachit/shared/domain/FinancialCalculatorTest.kt`
- Create: `shared/src/commonTest/kotlin/in/pravidh/pushpachit/shared/domain/ChitRulesTest.kt`

**Interfaces:**
- `FinancialCalculator.memberNet(payout: Long, totalContribution: Long): Long`
- `FinancialCalculator.marginPercent(payout: Long, monthlyPool: Long): Double`
- `ChitRules.winnerSelectionFor(month: Int, mode: WinnerSelectionMode): WinnerSelectionPolicy`
- `ChitRules.expectedMonthlyCollection(memberCount: Int, contribution: Long): Long`

- [ ] **Step 1: Write failing financial tests.**

Cover ₹15,000 × 21 = ₹3,15,000 total member contribution, Month 1 payout ₹2,64,000 producing −₹51,000, Month 13 payout ₹3,00,000 producing −₹15,000, and Month 21 payout ₹3,61,000 producing +₹46,000.

- [ ] **Step 2: Run tests and verify failure.**

Run `./gradlew :shared:allTests`. Expected: domain symbols are missing.

- [ ] **Step 3: Implement immutable serializable domain models.**

Model roles, winner selection modes (`RANDOM`, `MANUAL`, `FIXED_AGENT`), payment states, draw states, monthly schedule, winner, member obligation, and financial result.

- [ ] **Step 4: Implement the financial calculator.**

Use integer rupee amounts (`Long`) for all money calculations. Percentage values may use `Double` only for display/reporting and must never be used as the accounting source of truth.

- [ ] **Step 5: Implement Month 2 rule.**

Return `FIXED_AGENT` for Month 2 regardless of the requested UI selection mode. Reject invalid month numbers and invalid member counts in the domain layer.

- [ ] **Step 6: Run all shared tests.**

Expected: PASS with no floating-point accounting failures.

- [ ] **Step 7: Commit.**

Commit message: `feat: add shared chit financial domain`

---

### Task 3: Shared Supabase data/auth layer

**Files:**
- Create: `shared/src/commonMain/kotlin/in/pravidh/pushpachit/shared/data/SupabaseConfig.kt`
- Create: `shared/src/commonMain/kotlin/in/pravidh/pushpachit/shared/data/SupabaseProvider.kt`
- Create: `shared/src/commonMain/kotlin/in/pravidh/pushpachit/shared/data/ChitRepository.kt`
- Create: `shared/src/commonMain/kotlin/in/pravidh/pushpachit/shared/data/PaymentRepository.kt`
- Create: `shared/src/commonMain/kotlin/in/pravidh/pushpachit/shared/data/ChatRepository.kt`
- Create: `shared/src/commonMain/kotlin/in/pravidh/pushpachit/shared/data/NotificationRepository.kt`
- Create: `shared/src/commonTest/kotlin/in/pravidh/pushpachit/shared/data/RepositoryContractTest.kt`

**Interfaces:**
- `ChitRepository.currentChit(): Result<ChitSummary>`
- `ChitRepository.currentWinner(): Result<Winner?>`
- `PaymentRepository.myObligations(): Result<List<PaymentObligation>>`
- `PaymentRepository.submitPayment(...)`
- `PaymentRepository.confirmReceipt(...)`
- `ChatRepository.messages(...)`
- `ChatRepository.sendMessage(...)`

- [ ] **Step 1: Add Supabase Kotlin 3.7.0 modules and Ktor 3.5.1 engines.**

Use Auth, PostgREST, Storage, Realtime, and Functions modules. Keep the Supabase URL and publishable key injected from platform configuration; never hard-code a service-role key.

- [ ] **Step 2: Define repository interfaces against domain models.**

Do not expose Supabase SDK types outside the data implementation boundary.

- [ ] **Step 3: Implement authentication/session access.**

Support sign-in/session restore and expose a role-aware authenticated state. Authorization remains server-side through RLS.

- [ ] **Step 4: Implement read/write repositories.**

Use PostgREST for normal CRUD, Storage for payment proof files, Realtime for chat/status changes, and Edge Functions for privileged state transitions such as winner finalization and payment verification.

- [ ] **Step 5: Add repository contract tests using fakes.**

Test member isolation at the repository contract level and ensure client code never receives another member's private payment collection.

- [ ] **Step 6: Commit.**

Commit message: `feat: add shared supabase repositories`

---

### Task 4: Native Android Agent and Member MVP

**Files:**
- Create: `androidApp/src/main/java/in/pravidh/pushpachit/ui/AppRoot.kt`
- Create: `androidApp/src/main/java/in/pravidh/pushpachit/ui/agent/AgentDashboardScreen.kt`
- Create: `androidApp/src/main/java/in/pravidh/pushpachit/ui/agent/WinnerSelectionScreen.kt`
- Create: `androidApp/src/main/java/in/pravidh/pushpachit/ui/agent/PaymentVerificationScreen.kt`
- Create: `androidApp/src/main/java/in/pravidh/pushpachit/ui/member/MemberDashboardScreen.kt`
- Create: `androidApp/src/main/java/in/pravidh/pushpachit/ui/member/PaymentScreen.kt`
- Create: `androidApp/src/main/java/in/pravidh/pushpachit/ui/member/ChatScreen.kt`
- Create: `androidApp/src/main/java/in/pravidh/pushpachit/ui/theme/Theme.kt`

**Interfaces:**
- Agent dashboard consumes `ChitSummary`, payment status, winner state, and financial result.
- Winner selection screen accepts `WinnerSelectionMode` but disables RANDOM/MANUAL controls for Month 2.
- Member dashboard consumes only the authenticated member's private data and current winner/payment destination.

- [ ] **Step 1: Add Android UI tests for Month 2 selection and role routing.**

Verify Agent sees administration controls, Member does not, and Month 2 renders Agent as fixed winner.

- [ ] **Step 2: Implement Agent dashboard.**

Show month, ₹3,00,000 gross pool, configured payout, collection progress, Agent guarantee exposure, and winner status.

- [ ] **Step 3: Implement winner selection UI.**

Provide Random and Manual actions for eligible months and a fixed Agent state for Month 2. The UI never generates or stores a winner locally.

- [ ] **Step 4: Implement payment verification UI.**

Show each member's obligation, proof status, winner confirmation status, and Agent override/dispute workflow where permitted by backend policy.

- [ ] **Step 5: Implement Member dashboard/payment flow.**

Show the member's ₹15,000 obligation, current winner, pay-to details, submit-proof flow, payment status, receipts, and gain/loss position.

- [ ] **Step 6: Implement native family chat screen.**

Text and image attachment UI; private payment proofs remain private unless explicitly shared.

- [ ] **Step 7: Run Android tests/build.**

Run `./gradlew :androidApp:testDebugUnitTest :androidApp:assembleDebug` and verify the APK artifact is produced.

- [ ] **Step 8: Commit.**

Commit message: `feat: build android agent and member mvp`

---

### Task 5: Native iOS SwiftUI MVP

**Files:**
- Create: `iosApp/PushpaChitApp.swift`
- Create: `iosApp/Views/AppRootView.swift`
- Create: `iosApp/Views/Agent/AgentDashboardView.swift`
- Create: `iosApp/Views/Agent/WinnerSelectionView.swift`
- Create: `iosApp/Views/Member/MemberDashboardView.swift`
- Create: `iosApp/Views/Member/PaymentView.swift`
- Create: `iosApp/Views/Chat/FamilyChatView.swift`
- Create: `iosApp/Models/AppState.swift`

**Interfaces:**
- SwiftUI consumes exported/shared Kotlin models and repository facades through `SharedKit`.
- UI behavior must match Android business rules while retaining native iOS navigation and notification patterns.

- [ ] **Step 1: Add iOS state tests for Month 2 and member financial calculations.**

Use shared Kotlin tests for calculation correctness and Swift-side smoke tests for role/route rendering.

- [ ] **Step 2: Implement SwiftUI Agent dashboard and winner selection.**

Match Android functionality and keep Month 2 fixed to Agent.

- [ ] **Step 3: Implement SwiftUI Member dashboard/payment flow.**

Expose only the current user's private payment data plus required winner/payment destination details.

- [ ] **Step 4: Implement native family chat.**

Use SwiftUI image picker/attachment flow while keeping payment proof visibility controlled by backend policy.

- [ ] **Step 5: Add iOS build configuration and verify on macOS CI.**

Run the iOS framework/app build on a macOS GitHub Actions runner; do not claim an iOS build is verified on a Linux runner.

- [ ] **Step 6: Commit.**

Commit message: `feat: build ios swiftui mvp`

---

### Task 6: Notifications, CI, and production build gates

**Files:**
- Create: `androidApp/src/main/java/in/pravidh/pushpachit/notifications/PushNotificationService.kt`
- Create: `iosApp/Notifications/PushNotificationService.swift`
- Create: `.github/workflows/android.yml`
- Create: `.github/workflows/ios.yml`
- Create: `.github/workflows/shared-tests.yml`
- Create: `README.md` update with setup/build instructions

**Interfaces:**
- Notification payloads are server-generated and keyed by user/device token.
- Android and iOS adapters receive the same logical notification categories: `PAYMENT_DUE`, `PAYMENT_OVERDUE`, `PAYMENT_VERIFIED`, `WINNER_ANNOUNCED`, `WINNER_COLLECTION_PENDING`, `AGENT_GUARANTEE_USED`, `CHAT_MESSAGE`.

- [ ] **Step 1: Implement persisted notification preferences and token registration.**

Use Supabase-backed preferences and native token adapters; never store APNs/FCM server credentials in the app.

- [ ] **Step 2: Implement Android push handling.**

Route push messages to deep-linked payment, winner, verification, or chat screens.

- [ ] **Step 3: Implement iOS push handling.**

Route APNs notifications through SwiftUI navigation/deep links without exposing credentials.

- [ ] **Step 4: Add GitHub Actions shared tests and Android build.**

Use a pinned JDK/Gradle toolchain and upload the debug APK as a workflow artifact.

- [ ] **Step 5: Add macOS iOS build workflow.**

Build the shared framework and iOS application; upload the unsigned simulator/app artifact where supported.

- [ ] **Step 6: Run the full CI verification suite.**

Expected gates: shared tests PASS, Android unit tests PASS, Android debug APK build PASS, iOS build PASS on macOS.

- [ ] **Step 7: Commit and open a draft PR.**

Commit message: `ci: add native mobile build gates`

---

## Verification Matrix

| Area | Verification |
|---|---|
| Financial arithmetic | Shared unit tests with exact rupee values |
| Month 2 | Rule test + Android/iOS UI smoke tests |
| Winner selection | Backend integration tests; client never chooses final winner |
| Member isolation | RLS tests + repository contract tests |
| Payment flow | State-transition tests |
| Chat | Realtime integration test and attachment authorization |
| Notifications | Token registration and payload routing tests |
| Android | Debug APK CI build |
| iOS | macOS/Xcode CI build |
| Secrets | Repository scan and no service-role key in client code |

## Sources

- Kotlin Multiplatform current compatibility guidance: https://kotlinlang.org/docs/multiplatform/multiplatform-compatibility-guide.html
- Android KMP library plugin: https://developer.android.com/kotlin/multiplatform/plugin
- Supabase Kotlin Multiplatform client: https://supabase.com/docs/reference/kotlin/introduction
- Supabase Kotlin installation: https://supabase.com/docs/reference/kotlin/installing
