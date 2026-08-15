# Native Mobile Build

## Android

```text
gradle :shared:testDebugUnitTest
gradle :androidApp:assembleDebug
```

The Android CI workflow uploads the debug APK as an artifact.

## iOS

Generate the native Xcode project from `iosApp/project.yml` with XcodeGen, then build the simulator target. The project uses Kotlin Multiplatform direct integration and invokes `:shared:embedAndSignAppleFrameworkForXcode` before the SwiftUI target compiles.

## Backend

The mobile app uses only the Supabase publishable key. Production privileged operations remain in PostgreSQL/RLS/database functions and Edge Functions. Supabase project credentials and APNs/FCM server credentials must be configured outside source control.

## Current implementation boundary

The native screens and shared domain/data contracts are scaffolded. Production authentication, real Supabase repository calls, server-side draw invocation, payment proof upload, winner confirmation, Realtime chat, and push delivery are the next integration layer after the database project is provisioned and CI is green.
