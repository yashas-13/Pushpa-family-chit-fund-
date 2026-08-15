class MemberPosition {
  const MemberPosition({required this.totalPaidPaise, required this.totalReceivedPaise, required this.netPositionPaise, required this.remainingObligationPaise});

  final int totalPaidPaise;
  final int totalReceivedPaise;
  final int netPositionPaise;
  final int remainingObligationPaise;
}

class PositionEngine {
  const PositionEngine();

  MemberPosition calculate({required Iterable<int> verifiedContributionsPaise, required Iterable<int> verifiedPayoutsPaise, required int futureObligationPaise}) {
    final paid = verifiedContributionsPaise.fold<int>(0, (sum, value) => sum + value);
    final received = verifiedPayoutsPaise.fold<int>(0, (sum, value) => sum + value);
    if (futureObligationPaise < 0) throw ArgumentError.value(futureObligationPaise, 'futureObligationPaise');
    return MemberPosition(totalPaidPaise: paid, totalReceivedPaise: received, netPositionPaise: received - paid, remainingObligationPaise: futureObligationPaise);
  }
}
