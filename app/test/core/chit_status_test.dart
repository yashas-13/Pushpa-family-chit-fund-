import 'package:flutter_test/flutter_test.dart';

import 'package:pushpa_family_chit/core/chit_status.dart';

void main() {
  group('ChitStatus', () {
    test('reports the monthly amount due when payment is unverified', () {
      final status = ChitStatus(
        month: 12,
        totalMonths: 21,
        monthlyAmount: 15000,
        paidMonths: 11,
        currentWinner: 'Member 07',
        currentPaymentVerified: false,
      );

      expect(status.progressLabel, '11 / 21 paid');
      expect(status.amountDue, 15000);
      expect(status.currentWinner, 'Member 07');
      expect(status.isCurrentPaymentVerified, isFalse);
    });
  });
}
