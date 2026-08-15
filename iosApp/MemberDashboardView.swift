import SwiftUI

struct MemberDashboardView: View {
    var body: some View {
        Section("Member Dashboard") {
            LabeledContent("Member", value: "Member 01")
            LabeledContent("Month", value: "1 / 21")
            LabeledContent("Monthly contribution", value: "₹15,000")
            LabeledContent("Current winner", value: "Member 01")
            LabeledContent("Payment", value: "DUE")
            LabeledContent("21-month contribution", value: "₹3,15,000")
            LabeledContent("Winning-month result", value: "−₹51,000")

            NavigationLink("💰 Payment") {
                PaymentView()
            }
            NavigationLink("💬 Family Chat") {
                FamilyChatView()
            }
        }
    }
}
