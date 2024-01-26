//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

struct NestedTableView<Content>: View {

    init(vm: NestedTableViewModel<Content>) {
        _vm = StateObject(wrappedValue: vm)
    }

    @StateObject
    internal var vm: NestedTableViewModel<Content>

    internal var contextMenuElementBuilder: ((NestedTableViewModel<Content>, String, Set<UUID>) -> AnyView?)?
    internal var contextMenuItems: [any ContextMenuItems] = DefaultContextMenuItems.allCases

    var body: some View {
        Table(vm) {
            TableColumn("Name", sortUsing: KeyPathComparator(\.item.text, comparator: Comparator<String>())) { item in
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
