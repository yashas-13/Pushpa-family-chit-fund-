package in.pravidh.pushpachit.shared.domain

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class FinancialCalculatorTest {
    @Test
    fun memberPaysThreeLakhFifteenThousandAcrossTwentyOneMonths() {
        assertEquals(315_000L, TOTAL_MEMBER_CONTRIBUTION)
    }

    @Test
    fun monthOneMemberResultIsNegativeFiftyOneThousand() {
        val result = FinancialCalculator.memberResult(264_000)
        assertEquals(-51_000L, result.memberNet)
        assertEquals(12.0, result.marginPercent)
    }

    @Test
    fun monthThirteenMemberResultIsNegativeFifteenThousand() {
        val result = FinancialCalculator.memberResult(300_000)
        assertEquals(-15_000L, result.memberNet)
        assertEquals(0.0, result.poolMargin.toDouble())
    }

    @Test
    fun monthTwentyOneMemberResultIsPositiveFortySixThousand() {
        val result = FinancialCalculator.memberResult(361_000)
        assertEquals(46_000L, result.memberNet)
        assertTrue(result.marginPercent < 0.0)
    }
}
