import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

abstract final class SupabaseService {
  static Future<void> initialize() async {
    SupabaseConfig.validate();

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.publishableKey,
      debug: false,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;
}
