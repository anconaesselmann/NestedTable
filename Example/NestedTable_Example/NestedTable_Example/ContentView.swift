//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI
import NestedTable

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
        dataManager: AppState.shared.recordsStore,
        delegate: MockNestedTableManager()
    )

    @ViewBuilder
    var table: some View {
        Table(tableViewModel) {
            TableColumn("Name", sortUsing: .nameColumn()) {
                NameColumn(item: $0, vm: tableViewModel)
            }
            TableColumn("String", sortUsing: .content(\.content?.string)) {
                Text($0.content?.string ?? "")
            }
            TableColumn("OptionalString", sortUsing: .content(\.content?.optionalString)) {
                Text($0.content?.optionalString ?? "")
            }
            TableColumn("Custom", sortUsing: .content(\.content?.custom, comparison: {
                let lhs = $0.double
                let rhs = $1.double
                if lhs == rhs {
                    return .orderedSame
                } else {
                    return lhs > rhs ? .orderedAscending : .orderedDescending
                }
            })) {
                if let double = $0.content?.custom.double {
                    Text("\(double)")
                }
            }
            TableColumn("OptionalInt", sortUsing: .content(\.content?.optionalInt)) {
                if let int = $0.content?.int {
                    Text("\(int)")
                }
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
        let content = MockContent(
            id: mockContentId,
            string: mockContentId.uuidString,
            optionalString: mockContentId.uuidString
        )
        let item = Item<MockContent>(
            id: content.id,
            text: "New item",
            image: Image(systemName: "music.note.list"),
            content: content
        )
        AppState.shared.mockContentStore.insert(content)
        let id = try await AppState.shared.recordsStore.create(selected, item: item)
        if let selected = selected {
            await tableViewModel.expand(selected, shouldAnimate: false)
        }
        await tableViewModel.refresh()
        await MainActor.run {
            tableViewModel.selection = [id]
            tableViewModel.rename(id)
        }
    }
}
