//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI
import NestedTable

@main
struct NestedTable_ExampleApp: App {

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

    let mockContentStore: MockContentStore
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

        let mockContentStore = MockContentStore()

        let recordStore = RecordsStore.shared
        try await recordStore.initialize(contentStore: mockContentStore)

        AppState.shared = AppState(
            mockContentStore: mockContentStore,
            recordStore: recordStore
        )
        initialized = true
    }
}
