import 'package:flutter/foundation.dart';

/// Runtime configuration for Supabase.
///
/// Values are supplied with `--dart-define` so credentials/configuration are
/// not embedded in source control. The publishable/anon client key is safe to
/// ship in a client application only when PostgreSQL RLS is correctly enabled.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  static void validate() {
    if (isConfigured) return;
    throw StateError(
      'Supabase is not configured. Start Flutter with '
      '--dart-define=SUPABASE_URL=... '
      '--dart-define=SUPABASE_PUBLISHABLE_KEY=...',
    );
  }

  static void debugCheck() {
    if (kDebugMode && !isConfigured) {
      debugPrint('Supabase configuration is missing.');
    }
  }
}
