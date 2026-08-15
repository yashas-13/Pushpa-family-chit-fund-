package com.pravidh.pushpachit.shared.data

import com.pravidh.pushpachit.shared.domain.MemberPayment

interface PaymentRepository {
    suspend fun myObligations(): Result<List<MemberPayment>>
    suspend fun submitPayment(memberId: String, amount: Long, reference: String): Result<Unit>
    suspend fun confirmReceipt(memberId: String): Result<Unit>
}

class DemoPaymentRepository : PaymentRepository {
    private val payments = (1..20).map {
        MemberPayment("member-$it", "Member ${it.toString().padStart(2, '0')}")
    }

    override suspend fun myObligations(): Result<List<MemberPayment>> = Result.success(payments)

    override suspend fun submitPayment(memberId: String, amount: Long, reference: String): Result<Unit> {
        require(amount == 15_000L) { "Monthly contribution must be ₹15,000" }
        require(reference.isNotBlank()) { "Payment reference is required" }
        return Result.success(Unit)
    }

    override suspend fun confirmReceipt(memberId: String): Result<Unit> {
        require(payments.any { it.memberId == memberId }) { "Unknown member" }
        return Result.success(Unit)
    }
}
