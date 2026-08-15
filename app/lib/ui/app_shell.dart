import 'package:flutter/material.dart';

import '../core/chit_status.dart';
import '../core/supabase_config.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return const _ConfigurationScreen();
    }

    final status = ChitStatus(
      month: 12,
      totalMonths: 21,
      monthlyAmount: 15000,
      paidMonths: 11,
      currentWinner: 'Current winner',
      currentPaymentVerified: false,
    );

    return _AgentDashboard(status: status);
  }
}

class _ConfigurationScreen extends StatelessWidget {
  const _ConfigurationScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                'Supabase is not configured',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Run with SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY.\n'
                'Never put a service-role key in the mobile app.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgentDashboard extends StatelessWidget {
  const _AgentDashboard({required this.status});

  final ChitStatus status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pushpa Family Chit'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Agent Dashboard', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Month ${status.month} of ${status.totalMonths}'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _MetricCard(label: 'Monthly', value: '₹15,000')),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(label: 'Members', value: '20')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _MetricCard(label: 'Payments', value: status.progressLabel)),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(label: 'Due', value: '₹${status.amountDue}')),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.casino_outlined)),
              title: const Text('Lucky Dip'),
              subtitle: const Text('Secure server-side winner selection'),
              trailing: FilledButton(
                onPressed: () {},
                child: const Text('Open'),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Payment Verification'),
              subtitle: const Text('Review member payment submissions'),
              trailing: FilledButton.tonal(
                onPressed: () {},
                child: const Text('Review'),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Members'),
              subtitle: const Text('Manage 20 chit members'),
              trailing: FilledButton.tonal(
                onPressed: () {},
                child: const Text('Manage'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
