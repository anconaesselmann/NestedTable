//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

enum ExampleContextMenuItems: String, ContextMenuItems {
    case hello
    case create

    static let combinedElements: [any ContextMenuItems] = {
        DefaultContextMenuItems.allCases + [ExampleContextMenuItems.hello, ExampleContextMenuItems.create]
    }()
}

struct ContentView: View {

    @StateObject
    var vm = NestedTableViewModel<MockContent>(
        dataManager: AppState.shared.recordStore,
        delegate: MockNestedTableManager()
    )

    @ViewBuilder
    var table: some View {
        Table(vm) {
            TableColumn("Name", sortUsing: .nameColumn()) {
                NameColumn(item: $0, vm: vm)
            }
            TableColumn("Example", sortUsing: .content(\BaseRow.content?.test)) {
                Text($0.content?.test ?? "")
            }
        } rows: {
            ForEach(vm.items) {
                NestedTableRowContent(vm: vm, item: $0)
            }
        }
        .contextMenu(
            vm,
            items: ExampleContextMenuItems.combinedElements
        ) { (vm, item: ExampleContextMenuItems, selected) in
            switch item {
            case .hello where selected.count > 1:
                Button("Hello world") {
                    print("Hello world")
                }
            case .create where selected.count <= 1:
                Button("Create") {
                    Task {
                        let id = try await AppState.shared.recordStore.create(selected.first)
                        await vm.refresh()
                        await MainActor.run {
                            vm.selection = [id]
                            vm.rename(id)
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
