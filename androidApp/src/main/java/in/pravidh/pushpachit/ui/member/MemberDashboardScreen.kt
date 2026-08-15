package com.pravidh.pushpachit.ui.member

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

@Composable
fun MemberDashboardScreen(onChat: () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("Member Dashboard", style = MaterialTheme.typography.titleLarge)
        Text("Member 01")

        Card(modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Month 1 / 21")
                Text("Monthly contribution: ₹15,000")
                Text("Current winner: Member 01")
                Text("Payment status: DUE")
                Text("Your 21-month contribution: ₹3,15,000")
                Text("Winning-month result: -₹51,000")
            }
        }

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Button(onClick = { /* Navigate to payment in the full navigation graph. */ }) { Text("Payment") }
            Button(onClick = onChat) { Text("Family Chat") }
        }
    }
}
