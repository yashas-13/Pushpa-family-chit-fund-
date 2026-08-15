import 'package:flutter/material.dart';

class MemberDashboard extends StatelessWidget {
  const MemberDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Chit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Hello 👋', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text('Month 12 of 21'),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('This month'),
                  const SizedBox(height: 8),
                  Text('₹15,000', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  const Text('Pay directly to the selected chit winner.'),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: () {}, child: const Text('Submit Payment Proof')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.emoji_events_outlined)),
              title: Text('Current Winner'),
              subtitle: Text('Visible when the monthly Lucky Dip is finalized'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.receipt_long_outlined),
              title: Text('My Receipts'),
              subtitle: Text('View verified payment receipts'),
            ),
          ),
        ],
      ),
    );
  }
}
