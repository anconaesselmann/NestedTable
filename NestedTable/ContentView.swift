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
        delegate: MockNestedTableManager()
    )

    @ViewBuilder
    var table: some View {
        Table(vm) {
            TableColumn("Name", sortUsing: Comparators<MockContent>.text) {
                NameColumn(item: $0, vm: vm)
            }
            TableColumn(
                "Example",
                sortUsing: KeyPathComparator(\BaseRow.content?.test, comparator: OptionalComparator<String>())
            ) { item in
                Text(item.content?.test ?? "")
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
            case .hello where selected.count > 1:
                Button("Hello world") {
                    print("Hello world")
                }
            case .create where selected.count <= 1:
                Button("Create") {
                    Task {
                        let id = try await MockDataManager.shared.create(selected.first)
                        await vm.refresh()
                        await MainActor.run {
                            vm.selection = [id]
                        }
                    }
                }
            default: EmptyView()
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
