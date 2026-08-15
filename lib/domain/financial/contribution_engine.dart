class ContributionConfig {
  const ContributionConfig({this.memberCount = 20, this.monthlyContributionPaise = 1500000, this.monthCount = 21, this.agentContributionPaise = 0});

  final int memberCount;
  final int monthlyContributionPaise;
  final int monthCount;
  final int agentContributionPaise;

  void validateLockedModel() {
    if (memberCount != 20) throw ArgumentError.value(memberCount, 'memberCount', 'Locked model requires 20 members');
    if (monthlyContributionPaise != 1500000) throw ArgumentError.value(monthlyContributionPaise, 'monthlyContributionPaise', 'Locked model requires ₹15,000');
    if (monthCount != 21) throw ArgumentError.value(monthCount, 'monthCount', 'Locked model requires 21 months');
    if (agentContributionPaise != 0) throw ArgumentError.value(agentContributionPaise, 'agentContributionPaise', 'Agent contribution must be ₹0');
  }
}

class ContributionEngine {
  const ContributionEngine();

  int expectedMonthlyCollectionPaise(ContributionConfig config) {
    config.validateLockedModel();
    return config.memberCount * config.monthlyContributionPaise;
  }

  int totalMemberObligationPaise(ContributionConfig config) {
    return expectedMonthlyCollectionPaise(config) * config.monthCount;
  }
}
