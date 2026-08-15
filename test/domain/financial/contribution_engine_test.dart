import 'package:flutter_test/flutter_test.dart';
import 'package:pushpa_family_chit_fund/domain/financial/contribution_engine.dart';

void main() {
  const engine = ContributionEngine();
  const config = ContributionConfig();

  test('calculates ₹3,00,000 monthly collection in paise', () {
    expect(engine.expectedMonthlyCollectionPaise(config), 30000000);
  });

  test('calculates ₹63,00,000 total member obligation in paise', () {
    expect(engine.totalMemberObligationPaise(config), 630000000);
  });

  test('rejects non-zero agent contribution', () {
    expect(() => engine.expectedMonthlyCollectionPaise(const ContributionConfig(agentContributionPaise: 1)), throwsArgumentError);
  });
}
