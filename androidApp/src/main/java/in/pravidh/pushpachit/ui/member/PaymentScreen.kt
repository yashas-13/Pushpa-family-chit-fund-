package in.pravidh.pushpachit.ui.member

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Button
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.unit.dp

@Composable
fun PaymentScreen() {
    var reference by remember { mutableStateOf("") }

    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("Pay Month 1")
        Text("Pay ₹15,000 directly to the winner: Member 01")
        OutlinedTextField(
            value = reference,
            onValueChange = { reference = it },
            label = { Text("Transaction / reference") },
            singleLine = true,
        )
        Button(onClick = { /* Upload proof and submit to Supabase in production. */ }, enabled = reference.isNotBlank()) {
            Text("Submit Payment")
        }
        Text("The app never holds or transfers your money.")
    }
}
