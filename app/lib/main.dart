import 'package:flutter/material.dart';

import 'core/supabase_config.dart';
import 'ui/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const PushpaFamilyChitApp());
}

class PushpaFamilyChitApp extends StatelessWidget {
  const PushpaFamilyChitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pushpa Family Chit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B3CC4)),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}
