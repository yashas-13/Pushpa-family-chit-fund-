import SwiftUI

struct FamilyChatView: View {
    var body: some View {
        List {
            Section("Pushpa Family Group") {
                Text("Agent: Welcome everyone 👋")
                Text("Member 01: Month 1 payment submitted.")
                Text("Member 07: Received, thank you.")
            }

            Section {
                Text("Text and image attachments are supported. Payment proof remains private unless explicitly shared.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Family Chat")
    }
}
