package in.pravidh.pushpachit.ui.member

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Card
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun ChatScreen() {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text("Pushpa Family Group")
        listOf(
            "Agent: Welcome everyone 👋",
            "Member 01: Month 1 payment submitted.",
            "Member 07: Received, thank you.",
        ).forEach { message ->
            Card(modifier = Modifier.fillMaxWidth()) { Text(message) }
        }
        Text("Payment screenshots remain private unless explicitly shared to this group.")
    }
}
