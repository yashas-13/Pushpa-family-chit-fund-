import SwiftUI

@main
struct PushpaFamilyChitApp: App {
    @UIApplicationDelegateAdaptor(PushNotificationService.self) private var pushService

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
