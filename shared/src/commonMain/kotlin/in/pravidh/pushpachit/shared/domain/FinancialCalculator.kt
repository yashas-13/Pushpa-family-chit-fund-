package in.pravidh.pushpachit.shared.domain

object FinancialCalculator {
    fun memberNet(payout: Long, totalContribution: Long = TOTAL_MEMBER_CONTRIBUTION): Long =
        payout - totalContribution

    fun poolMargin(payout: Long, monthlyPool: Long = MONTHLY_POOL): Long =
        monthlyPool - payout

    fun marginPercent(payout: Long, monthlyPool: Long = MONTHLY_POOL): Double {
        require(monthlyPool > 0) { "Monthly pool must be positive" }
        return poolMargin(payout, monthlyPool).toDouble() / monthlyPool.toDouble() * 100.0
    }

    fun memberResult(payout: Long): FinancialResult = FinancialResult(
        payout = payout,
        totalContribution = TOTAL_MEMBER_CONTRIBUTION,
        memberNet = memberNet(payout),
        poolMargin = poolMargin(payout),
        marginPercent = marginPercent(payout),
    )

    fun schedule(): List<MonthlySchedule> = listOf(
        MonthlySchedule(1, 264_000, WinnerType.MEMBER),
        MonthlySchedule(2, null, WinnerType.AGENT),
        MonthlySchedule(3, 266_000, WinnerType.MEMBER),
        MonthlySchedule(4, 268_000, WinnerType.MEMBER),
        MonthlySchedule(5, 270_000, WinnerType.MEMBER),
        MonthlySchedule(6, 272_000, WinnerType.MEMBER),
        MonthlySchedule(7, 275_000, WinnerType.MEMBER),
        MonthlySchedule(8, 278_000, WinnerType.MEMBER),
        MonthlySchedule(9, 282_000, WinnerType.MEMBER),
        MonthlySchedule(10, 286_000, WinnerType.MEMBER),
        MonthlySchedule(11, 290_000, WinnerType.MEMBER),
        MonthlySchedule(12, 295_000, WinnerType.MEMBER),
        MonthlySchedule(13, 300_000, WinnerType.MEMBER),
        MonthlySchedule(14, 306_000, WinnerType.MEMBER),
        MonthlySchedule(15, 312_000, WinnerType.MEMBER),
        MonthlySchedule(16, 319_000, WinnerType.MEMBER),
        MonthlySchedule(17, 326_000, WinnerType.MEMBER),
        MonthlySchedule(18, 334_000, WinnerType.MEMBER),
        MonthlySchedule(19, 342_000, WinnerType.MEMBER),
        MonthlySchedule(20, 351_000, WinnerType.MEMBER),
        MonthlySchedule(21, 361_000, WinnerType.MEMBER),
    )
}
