package in.pravidh.pushpachit.ui.agent

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import in.pravidh.pushpachit.shared.domain.FinancialCalculator
import in.pravidh.pushpachit.shared.domain.MONTHLY_POOL

@Composable
fun AgentDashboardScreen(
    onWinnerSelection: () -> Unit,
    onChat: () -> Unit,
) {
    val schedule = FinancialCalculator.schedule()
    val month = 1
    val payout = schedule.first().payout ?: 0L
    val margin = MONTHLY_POOL - payout

    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("Agent Dashboard", style = MaterialTheme.typography.titleLarge)
        Text("Month $month / 21")

        Card(modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Gross collection")
                Text("₹3,00,000", style = MaterialTheme.typography.headlineSmall)
                Text("Scheduled payout: ₹${payout.formatIndian()}")
                Text("Pool margin: ₹${margin.formatIndian()}")
                Text("Agent contribution: ₹0")
                Text("Guarantee exposure: ₹0")
            }
        }

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Button(onClick = onWinnerSelection) { Text("Select Winner") }
            Button(onClick = onChat) { Text("Family Chat") }
        }

        Text("Month 2 is permanently fixed for the Agent.")
        Text("Other months support secure Random Lucky Dip or Manual selection.")
    }
}

private fun Long.formatIndian(): String =
    toString().reversed().chunked(3).joinToString(",").reversed()
