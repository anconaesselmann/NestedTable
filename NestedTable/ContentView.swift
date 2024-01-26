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
    var tableViewModel = NestedTableViewModel<MockContent>(
        dataManager: AppState.shared.recordStore,
        delegate: MockNestedTableManager()
    )

    @ViewBuilder
    var table: some View {
        Table(tableViewModel) {
            TableColumn("Name", sortUsing: .nameColumn()) {
                NameColumn(item: $0, vm: tableViewModel)
            }
            TableColumn("Example", sortUsing: .content(\BaseRow.content?.test)) {
                Text($0.content?.test ?? "")
            }
        } rows: {
            ForEach(tableViewModel.items) {
                NestedTableRowContent(vm: tableViewModel, item: $0)
            }
        }
        .contextMenu(
            tableViewModel,
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
                        try await self.create(tableViewModel: vm, selected: selected.first)
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

    private func create(tableViewModel: NestedTableViewModel<MockContent>, selected: UUID?) async throws {
        let mockContentId = UUID()
        let content = MockContent(id: mockContentId, test: mockContentId.uuidString)
        let item = Item<MockContent>(
            id: content.id,
            text: "New item",
            image: Image(systemName: "music.note.list"), 
            content: content
        )
        AppState.shared.mockContentStore.insert(content)
        let id = try await AppState.shared.recordStore.create(selected, item: item)
        await tableViewModel.refresh()
        await MainActor.run {
            tableViewModel.selection = [id]
            tableViewModel.rename(id)
        }
    }
}
