//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

struct NestedTableView<Content>: View {

    init(
        of type: Content.Type,
        dataManager: NestedTableDataManager,
        delegate: NestedTableDelegate,
        contextMenuManager: ContextMenuManager? = nil
    ) {
        let vm = NestedTableViewModel<Content>(
            dataManager: dataManager,
            delegate: delegate,
            contextMenuManager: contextMenuManager ?? DefaultContextMenuManager()
        )
        _vm = StateObject(wrappedValue: vm)
    }

    @StateObject
    private var vm: NestedTableViewModel<Content>

    internal var contextMenuElementBuilder: ((String, Set<UUID>) -> AnyView?)?
    internal var contextMenuItems: [any ContextMenuItems] = DefaultContextMenuItems.allCases

    var body: some View {
        Table(of: BaseRow<Content>.self, selection: $vm.selection, sortOrder: $vm.sortOrder) {
            TableColumn("Name", sortUsing: KeyPathComparator(\BaseRow.item.text, comparator: Comparator<String>())) { item in
                NameColumn(item: item, vm: vm)
            }
        } rows: {
            ForEach(vm.items) { item in
                TableRow(item)
#if os(macOS)
                    .itemProvider {
                        vm.itemProvider(for: item)
                    }
                    .if(item.isGroup) {
                        $0.dropDestination(for: Data.self) {
                            vm.itemsDropped($0, into: item.id)
                        }
                    }
#endif
            }
        }
        .contextMenu(forSelectionType: UUID.self) {
            ItemContextMenu(
                vm,
                ids: $0,
                elements: contextMenuItems,
                contextMenuElementBuilder: contextMenuElementBuilder
            )
        } primaryAction: { items in
            vm.primaryAction(items)
        }
        .onAppear {
            vm.fetch()
        }
    }
}
