package in.pravidh.pushpachit.shared.domain

import kotlinx.serialization.Serializable

const val MEMBER_COUNT = 20
const val MONTH_COUNT = 21
const val MEMBER_MONTHLY_CONTRIBUTION = 15_000L
const val MONTHLY_POOL = MEMBER_COUNT * MEMBER_MONTHLY_CONTRIBUTION
const val TOTAL_MEMBER_CONTRIBUTION = MONTH_COUNT * MEMBER_MONTHLY_CONTRIBUTION

@Serializable
enum class UserRole { AGENT, MEMBER }

@Serializable
enum class WinnerSelectionMode { RANDOM, MANUAL, FIXED_AGENT }

@Serializable
enum class DrawState { DRAFT, PARTICIPANTS_LOCKED, FINAL }

@Serializable
enum class PaymentState { DUE, CLAIMED, RECEIPT_PENDING, VERIFIED, REJECTED }

@Serializable
data class MonthlySchedule(
    val month: Int,
    val payout: Long?,
    val winnerType: WinnerType,
)

@Serializable
enum class WinnerType { MEMBER, AGENT }

@Serializable
data class FinancialResult(
    val payout: Long,
    val totalContribution: Long,
    val memberNet: Long,
    val poolMargin: Long,
    val marginPercent: Double,
)

@Serializable
data class ChitSummary(
    val currentMonth: Int,
    val totalMonths: Int = MONTH_COUNT,
    val memberCount: Int = MEMBER_COUNT,
    val monthlyContribution: Long = MEMBER_MONTHLY_CONTRIBUTION,
    val monthlyPool: Long = MONTHLY_POOL,
    val scheduledPayout: Long? = null,
    val winnerName: String? = null,
    val winnerType: WinnerType? = null,
)

@Serializable
data class MemberPayment(
    val memberId: String,
    val memberName: String,
    val amount: Long = MEMBER_MONTHLY_CONTRIBUTION,
    val state: PaymentState = PaymentState.DUE,
)
