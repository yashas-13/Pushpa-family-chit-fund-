import 'package:flutter/material.dart';

class AgentDashboard extends StatelessWidget {
  const AgentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pushpa Family Chit'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Agent Dashboard', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text('Month 12 of 21'),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: _MetricCard(label: 'Monthly', value: '₹15,000')),
              SizedBox(width: 12),
              Expanded(child: _MetricCard(label: 'Members', value: '20')),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: _MetricCard(label: 'Verified', value: '11 / 20')),
              SizedBox(width: 12),
              Expanded(child: _MetricCard(label: 'Pending', value: '₹1,35,000')),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.casino_outlined)),
              title: const Text('Lucky Dip'),
              subtitle: const Text('Secure server-side winner selection'),
              trailing: FilledButton(onPressed: () {}, child: const Text('Open')),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Payment Verification'),
              subtitle: const Text('Review member submissions'),
              trailing: FilledButton.tonal(onPressed: () {}, child: const Text('Review')),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Members'),
              subtitle: const Text('Manage 20 chit members'),
              trailing: FilledButton.tonal(onPressed: () {}, child: const Text('Manage')),
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
            Text(label),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
