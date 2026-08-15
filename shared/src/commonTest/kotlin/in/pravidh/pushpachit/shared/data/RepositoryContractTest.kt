package com.pravidh.pushpachit.shared.data

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

class RepositoryContractTest {
    @Test
    fun demoPaymentRequiresFifteenThousand() = kotlinx.coroutines.test.runTest {
        val repository = DemoPaymentRepository()
        assertFailsWith<IllegalArgumentException> {
            repository.submitPayment("member-1", 14_999, "TXN-1").getOrThrow()
        }
    }

    @Test
    fun demoChatRejectsEmptyMessage() = kotlinx.coroutines.test.runTest {
        val repository = DemoChatRepository()
        val result = repository.sendMessage("")
        assertEquals(true, result.isFailure)
    }
}
