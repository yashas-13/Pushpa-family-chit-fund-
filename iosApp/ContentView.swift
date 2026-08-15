import SwiftUI
import SharedKit

struct ContentView: View {
    @State private var role = "Agent"
    @State private var showWinnerSelection = false

    var body: some View {
        NavigationStack {
            List {
                Section("Role") {
                    Picker("Role", selection: $role) {
                        Text("Agent").tag("Agent")
                        Text("Member").tag("Member")
                    }
                    .pickerStyle(.segmented)
                }

                if role == "Agent" {
                    AgentDashboardView(showWinnerSelection: $showWinnerSelection)
                } else {
                    MemberDashboardView()
                }

                Section("Shared Kotlin") {
                    Label("KMP business/data layer connected", systemImage: "checkmark.seal.fill")
                    Text("Android uses Jetpack Compose; iOS uses native SwiftUI.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Pushpa Family Chit")
            .sheet(isPresented: $showWinnerSelection) {
                WinnerSelectionView()
            }
        }
    }
}

#Preview {
    ContentView()
}
