//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

enum Test: String, ContextMenuItems {
    case hello
    case create
}

struct ContentView: View {

    let dm = MockDataManager()

    var body: some View {
        #if os(macOS)
        NestedTableView(
            of: MockContent.self,
            dataManager: dm,
            delegate: MockNestedTableManager()
        )
        .contextMenu(
            items: DefaultContextMenuItems.allCases + [Test.hello, Test.create]
        ) { (vm, item: Test, selected) in
            switch item {
            case .hello:
                if selected.count > 1 {
                    Button("Hello world") {
                        print("Hello world")
                    }
                }
            case .create:
                if selected.count == 1, let selectedId = selected.first {
                    Button("Create") {
                        Task {
                            let id = try await dm.create(selectedId)
                            await vm.refresh()
                            vm.selection = [id]
                        }
                    }
                }
            }
        }
        #else
        NavigationView {
            NestedTableView(
                of: MockContent.self,
                dataManager: dm,
                delegate: MockNestedTableManager()
            )
            .contextMenu(
                items: DefaultContextMenuItems.allCases + [Test.hello]
            ) { (item: Test, selected) in
                switch item {
                case .hello:
                    if selected.count > 1 {
                        Button("Hello world") {
                            print("Hello world")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {


                    EditButton()
                }
            }
        }
        #endif
    }
}
