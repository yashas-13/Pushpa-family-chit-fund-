package in.pravidh.pushpachit.shared.data

import in.pravidh.pushpachit.shared.domain.ChitSummary
import in.pravidh.pushpachit.shared.domain.FinancialCalculator
import in.pravidh.pushpachit.shared.domain.MonthlySchedule

interface ChitRepository {
    suspend fun currentChit(): Result<ChitSummary>
    suspend fun currentWinner(): Result<String?>
    suspend fun schedule(): Result<List<MonthlySchedule>>
}

class DemoChitRepository : ChitRepository {
    override suspend fun currentChit(): Result<ChitSummary> = Result.success(
        ChitSummary(
            currentMonth = 1,
            scheduledPayout = FinancialCalculator.schedule().first().payout,
            winnerName = "Member 01",
        ),
    )

    override suspend fun currentWinner(): Result<String?> = Result.success("Member 01")

    override suspend fun schedule(): Result<List<MonthlySchedule>> =
        Result.success(FinancialCalculator.schedule())
}
