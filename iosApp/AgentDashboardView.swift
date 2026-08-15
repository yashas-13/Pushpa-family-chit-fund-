import SwiftUI

struct AgentDashboardView: View {
    @Binding var showWinnerSelection: Bool

    var body: some View {
        Section("Agent Dashboard") {
            LabeledContent("Month", value: "1 / 21")
            LabeledContent("Gross collection", value: "₹3,00,000")
            LabeledContent("Scheduled payout", value: "₹2,64,000")
            LabeledContent("Pool margin", value: "₹36,000")
            LabeledContent("Agent contribution", value: "₹0")
            LabeledContent("Guarantee exposure", value: "₹0")

            Button("🎲 Select Winner") {
                showWinnerSelection = true
            }

            NavigationLink("💬 Family Chat") {
                FamilyChatView()
            }
        }

        Section("Rules") {
            Text("Month 2 is permanently fixed for the Agent.")
            Text("Other months support secure Random Lucky Dip or Manual selection.")
        }
    }
}
