class MonthReconciliation {
  const MonthReconciliation({required this.expectedCollectionPaise, required this.actualCollectionPaise, required this.payoutPaise, required this.adjustmentsPaise, required this.carryForwardPaise, required this.differencePaise, required this.balanced});

  final int expectedCollectionPaise;
  final int actualCollectionPaise;
  final int payoutPaise;
  final int adjustmentsPaise;
  final int carryForwardPaise;
  final int differencePaise;
  final bool balanced;
}

class ReconciliationEngine {
  const ReconciliationEngine();

  MonthReconciliation reconcile({required int expectedCollectionPaise, required int actualCollectionPaise, required int payoutPaise, int adjustmentsPaise = 0, int carryForwardPaise = 0}) {
    final difference = actualCollectionPaise + adjustmentsPaise + carryForwardPaise - payoutPaise - expectedCollectionPaise;
    return MonthReconciliation(expectedCollectionPaise: expectedCollectionPaise, actualCollectionPaise: actualCollectionPaise, payoutPaise: payoutPaise, adjustmentsPaise: adjustmentsPaise, carryForwardPaise: carryForwardPaise, differencePaise: difference, balanced: difference == 0);
  }
}
