import SwiftUI

struct WinnerSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Month 1") {
                    Button("🎲 Run Secure Lucky Dip") {
                        // Production action invokes the server-authoritative draw.
                    }
                    Button("👤 Manual Select Winner") {
                        // Production action invokes server-validated manual selection.
                    }
                }

                Section("Month 2") {
                    Text("Winner is always the Agent.")
                    Text("Random and Manual member selection are disabled.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Winner Selection")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
