import 'package:flutter_test/flutter_test.dart';

import 'package:pushpa_family_chit/core/chit_status.dart';

void main() {
  group('ChitStatus', () {
    test('returns the expected summary for a member', () {
      final status = ChitStatus(
        month: 12,
        totalMonths: 21,
        monthlyAmount: 15000,
        paidMonths: 11,
        currentWinner: 'Member 07',
        currentPaymentVerified: true,
      );

      expect(status.progressLabel, '11 / 21 paid');
      expect(status.amountDue, 15000);
      expect(status.currentWinner, 'Member 07');
      expect(status.isCurrentPaymentVerified, isTrue);
    });
  });
}
