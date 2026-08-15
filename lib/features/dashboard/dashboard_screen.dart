import 'package:flutter/material.dart';
import '../../data/models/chit_models.dart';
import '../../data/repositories/chit_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.repository});
  final ChitRepository repository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Chit>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.listChits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chit Dashboard')),
      body: FutureBuilder<List<Chit>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Supabase error: ${snapshot.error}'));
          final chits = snapshot.data ?? const <Chit>[];
          if (chits.isEmpty) return const Center(child: Text('No chit configured yet.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chits.length,
            itemBuilder: (_, index) {
              final chit = chits[index];
              return Card(
                child: ListTile(
                  title: Text(chit.name),
                  subtitle: Text('${chit.memberCount} members • ₹${(chit.monthlyContributionPaise / 100).toStringAsFixed(0)}/month • ${chit.monthCount} months'),
                  trailing: Text(chit.status.toUpperCase()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
