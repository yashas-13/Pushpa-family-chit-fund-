import 'package:flutter/material.dart';

import 'config/supabase_config.dart';
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ConnectionScreen(),
    );
  }
}

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final configured = SupabaseConfig.isConfigured;
    final session = configured ? SupabaseService.auth.currentSession : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Pushpa Family Chit')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                configured ? Icons.cloud_done : Icons.cloud_off,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                configured
                    ? 'Supabase client initialized'
                    : 'Supabase configuration required',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                configured
                    ? session == null
                        ? 'Backend connected. No authenticated user.'
                        : 'Authenticated session available.'
                    : 'Use SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY dart defines.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
