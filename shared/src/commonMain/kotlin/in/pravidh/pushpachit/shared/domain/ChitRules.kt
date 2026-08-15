package com.pravidh.pushpachit.shared.domain

object ChitRules {
    fun expectedMonthlyCollection(
        memberCount: Int = MEMBER_COUNT,
        contribution: Long = MEMBER_MONTHLY_CONTRIBUTION,
    ): Long {
        require(memberCount == MEMBER_COUNT) { "Initial chit requires exactly 20 members" }
        require(contribution > 0) { "Contribution must be positive" }
        return memberCount.toLong() * contribution
    }

    fun winnerSelectionFor(month: Int, requested: WinnerSelectionMode): WinnerSelectionMode {
        require(month in 1..MONTH_COUNT) { "Month must be between 1 and $MONTH_COUNT" }
        return if (month == 2) WinnerSelectionMode.FIXED_AGENT else requested
    }

    fun isAgentMonth(month: Int): Boolean = month == 2

    fun isMemberWinnerMonth(month: Int): Boolean = month in 1..MONTH_COUNT && month != 2
}
