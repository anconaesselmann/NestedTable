//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

enum ExampleContextMenuItems: String, ContextMenuItems {
    case hello
    case create
}

struct ContentView: View {

    @StateObject
    var vm = NestedTableViewModel<MockContent>(
        dataManager: MockDataManager.shared,
        delegate: MockNestedTableManager(),
        contextMenuManager: DefaultContextMenuManager()
    )

    @ViewBuilder
    var table: some View {
        Table(vm) {
            TableColumn("Name", sortUsing: Comparators<MockContent>.text) {
                NameColumn(item: $0, vm: vm)
            }
        } rows: {
            ForEach(vm.items) {
                NestedTableRowContent(vm: vm, item: $0)
            }
        }
        .contextMenu(
            vm,
            items: DefaultContextMenuItems.allCases + [ExampleContextMenuItems.hello, ExampleContextMenuItems.create]
        ) { (vm, item: ExampleContextMenuItems, selected) in
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
                            let id = try await MockDataManager.shared.create(selectedId)
                            await vm.refresh()
                            await MainActor.run {
                                vm.selection = [id]
                            }
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        #if os(macOS)
        table
        #else
        NavigationView {
            table
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    EditButton()
                }
            }
        }
        #endif
    }
}
