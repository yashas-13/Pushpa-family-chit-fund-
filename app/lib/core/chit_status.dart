class ChitStatus {
  const ChitStatus({
    required this.month,
    required this.totalMonths,
    required this.monthlyAmount,
    required this.paidMonths,
    required this.currentWinner,
    required this.currentPaymentVerified,
  });

  final int month;
  final int totalMonths;
  final int monthlyAmount;
  final int paidMonths;
  final String currentWinner;
  final bool currentPaymentVerified;

  int get amountDue => currentPaymentVerified ? 0 : monthlyAmount;

  bool get isCurrentPaymentVerified => currentPaymentVerified;

  String get progressLabel => '$paidMonths / $totalMonths paid';
}
