import 'package:flutter/material.dart';

import 'config/supabase_config.dart';
import 'data/repositories/chit_repository.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SupabaseConfig.debugCheck();
  if (SupabaseConfig.isConfigured) {
    await SupabaseService.initialize();
  }
  runApp(const PushpaChitApp());
}

class PushpaChitApp extends StatelessWidget {
  const PushpaChitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pushpa Family Chit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), useMaterial3: true),
      home: SupabaseConfig.isConfigured
          ? DashboardScreen(repository: ChitRepository(SupabaseService.client))
          : const ConnectionScreen(),
    );
  }
}

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pushpa Family Chit')),
      body: const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Supabase configuration required. Start with SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY dart defines.', textAlign: TextAlign.center))),
    );
  }
}
