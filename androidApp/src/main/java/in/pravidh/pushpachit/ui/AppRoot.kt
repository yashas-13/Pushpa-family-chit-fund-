package in.pravidh.pushpachit.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import in.pravidh.pushpachit.shared.domain.UserRole
import in.pravidh.pushpachit.ui.agent.AgentDashboardScreen
import in.pravidh.pushpachit.ui.member.MemberDashboardScreen
import in.pravidh.pushpachit.ui.theme.PushpaTheme

@Composable
fun AppRoot() {
    var role by remember { mutableStateOf(UserRole.AGENT) }
    var showWinnerSelection by remember { mutableStateOf(false) }
    var showChat by remember { mutableStateOf(false) }

    PushpaTheme {
        Scaffold(modifier = Modifier.fillMaxSize()) { padding ->
            Column(
                modifier = Modifier.padding(padding).padding(20.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
            ) {
                Text("Pushpa Family Chit", style = MaterialTheme.typography.headlineMedium)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    FilterChip(selected = role == UserRole.AGENT, onClick = { role = UserRole.AGENT }, label = { Text("Agent") })
                    FilterChip(selected = role == UserRole.MEMBER, onClick = { role = UserRole.MEMBER }, label = { Text("Member") })
                }

                when {
                    showWinnerSelection -> WinnerSelectionHost(onBack = { showWinnerSelection = false })
                    showChat -> ChatHost(onBack = { showChat = false })
                    role == UserRole.AGENT -> AgentDashboardScreen(
                        onWinnerSelection = { showWinnerSelection = true },
                        onChat = { showChat = true },
                    )
                    else -> MemberDashboardScreen(onChat = { showChat = true })
                }
            }
        }
    }
}

@Composable
private fun WinnerSelectionHost(onBack: () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Button(onClick = onBack) { Text("Back") }
        in.pravidh.pushpachit.ui.agent.WinnerSelectionScreen()
    }
}

@Composable
private fun ChatHost(onBack: () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Button(onClick = onBack) { Text("Back") }
        in.pravidh.pushpachit.ui.member.ChatScreen()
    }
}
