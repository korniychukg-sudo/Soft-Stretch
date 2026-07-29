import SwiftUI

@main
struct MellowbendApp: App {
    @StateObject private var store = StretchStore()
    @StateObject private var companion = CompanionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(companion)
                .preferredColorScheme(.light)
        }
    }
}
