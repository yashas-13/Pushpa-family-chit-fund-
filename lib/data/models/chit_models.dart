class Chit {
  const Chit({required this.id, required this.name, required this.memberCount, required this.monthlyContributionPaise, required this.monthCount, required this.agentContributionPaise, required this.status});

  final String id;
  final String name;
  final int memberCount;
  final int monthlyContributionPaise;
  final int monthCount;
  final int agentContributionPaise;
  final String status;

  factory Chit.fromMap(Map<String, dynamic> m) => Chit(
    id: m['id'] as String,
    name: m['name'] as String,
    memberCount: m['member_count'] as int,
    monthlyContributionPaise: m['monthly_contribution_paise'] as int,
    monthCount: m['month_count'] as int,
    agentContributionPaise: m['agent_contribution_paise'] as int,
    status: m['status'] as String,
  );
}

class ChitMonth {
  const ChitMonth({required this.id, required this.chitId, required this.monthNumber, required this.state, required this.expectedCollectionPaise, required this.actualCollectionPaise});

  final String id;
  final String chitId;
  final int monthNumber;
  final String state;
  final int expectedCollectionPaise;
  final int actualCollectionPaise;

  factory ChitMonth.fromMap(Map<String, dynamic> m) => ChitMonth(
    id: m['id'] as String,
    chitId: m['chit_id'] as String,
    monthNumber: m['month_number'] as int,
    state: m['state'] as String,
    expectedCollectionPaise: m['expected_collection_paise'] as int,
    actualCollectionPaise: m['actual_collection_paise'] as int,
  );
}

class PaymentObligation {
  const PaymentObligation({required this.id, required this.monthId, required this.memberId, required this.amountPaise, required this.status});

  final String id;
  final String monthId;
  final String memberId;
  final int amountPaise;
  final String status;

  factory PaymentObligation.fromMap(Map<String, dynamic> m) => PaymentObligation(
    id: m['id'] as String,
    monthId: m['chit_month_id'] as String,
    memberId: m['member_id'] as String,
    amountPaise: m['amount_paise'] as int,
    status: m['status'] as String,
  );
}
