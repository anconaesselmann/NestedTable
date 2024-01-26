//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

@main
struct NestedTableApp: App {

    @StateObject
    private var appInitializer = AppInitializer()

    var body: some Scene {
        WindowGroup {
            if !appInitializer.initialized {
                ProgressView()
                    .task { await initialize() }
            } else {
                ZStack {
                    ContentView()
                }
            }
        }
    }

    private func initialize() async {
        do {
            try await appInitializer.initialize()
        } catch {
            assertionFailure("Could not initialize app")
        }
    }
}


struct AppState {

    static var shared: AppState!

    let recordStore: RecordsStore
}


@MainActor
class AppInitializer: ObservableObject {

    @Published
    var initialized: Bool = false

    @MainActor
    func initialize() async throws {
        guard !initialized else {
            return
        }

        let recordStore = RecordsStore.shared
        try await recordStore.initialize()

        AppState.shared = AppState(
            recordStore: recordStore
        )
        initialized = true
    }
}
