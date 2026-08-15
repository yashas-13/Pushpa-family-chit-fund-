import SwiftUI

struct PaymentView: View {
    @State private var reference = ""

    var body: some View {
        Form {
            Section("Month 1") {
                LabeledContent("Amount", value: "₹15,000")
                LabeledContent("Pay to", value: "Member 01")
                TextField("Transaction / reference", text: $reference)
            }

            Section {
                Button("Submit Payment") {
                    // Production action uploads proof to private Supabase Storage and creates the claim.
                }
                .disabled(reference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Text("The app never holds or transfers your money.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Payment")
    }
}
