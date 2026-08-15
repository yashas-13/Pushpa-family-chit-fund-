package com.pravidh.pushpachit.ui.agent

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Card
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.pravidh.pushpachit.shared.domain.MemberPayment

@Composable
fun PaymentVerificationScreen(payments: List<MemberPayment>) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text("Payment Verification")
        payments.forEach { payment ->
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(payment.memberName)
                    Text("₹${payment.amount}")
                    Text(payment.state.name)
                }
            }
        }
    }
}
