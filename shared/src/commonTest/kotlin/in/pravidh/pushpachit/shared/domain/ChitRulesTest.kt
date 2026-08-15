package com.pravidh.pushpachit.shared.domain

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class ChitRulesTest {
    @Test
    fun monthlyCollectionIsThreeLakh() {
        assertEquals(300_000L, ChitRules.expectedMonthlyCollection())
    }

    @Test
    fun monthTwoIsAlwaysAgent() {
        assertEquals(
            WinnerSelectionMode.FIXED_AGENT,
            ChitRules.winnerSelectionFor(2, WinnerSelectionMode.RANDOM),
        )
        assertEquals(
            WinnerSelectionMode.FIXED_AGENT,
            ChitRules.winnerSelectionFor(2, WinnerSelectionMode.MANUAL),
        )
        assertTrue(ChitRules.isAgentMonth(2))
    }

    @Test
    fun otherMonthsKeepRequestedSelectionMode() {
        assertEquals(
            WinnerSelectionMode.RANDOM,
            ChitRules.winnerSelectionFor(1, WinnerSelectionMode.RANDOM),
        )
        assertEquals(
            WinnerSelectionMode.MANUAL,
            ChitRules.winnerSelectionFor(21, WinnerSelectionMode.MANUAL),
        )
    }
}
