package com.pravidh.pushpachit.ui.agent

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.pravidh.pushpachit.shared.domain.ChitRules
import com.pravidh.pushpachit.shared.domain.WinnerSelectionMode

@Composable
fun WinnerSelectionScreen() {
    val month = 1
    val selectedMode = ChitRules.winnerSelectionFor(month, WinnerSelectionMode.RANDOM)

    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("Winner Selection", style = MaterialTheme.typography.titleLarge)
        Text("Month $month")
        Text("Selection mode: ${selectedMode.name}")

        Card(modifier = Modifier.fillMaxWidth()) {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Eligible members: 20")
                Text("Previous winners are excluded according to the active eligibility rule.")
            }
        }

        Button(onClick = { /* Calls server-side Lucky Dip in production. */ }, modifier = Modifier.fillMaxWidth()) {
            Text("🎲 Run Secure Lucky Dip")
        }
        Button(onClick = { /* Opens server-validated member picker in production. */ }, modifier = Modifier.fillMaxWidth()) {
            Text("👤 Manual Select Winner")
        }

        Text("Month 2 is always FIXED_AGENT and cannot use either action.")
    }
}
