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
            TableColumn("Name", sortUsing: Comparators<Content>.text) {
                NameColumn(item: $0, vm: vm)
            }
        } rows: {
            ForEach(vm.items) {
                NestedTableRowContent(vm: vm, item: $0)
            }
        }
        .nestedTableView(
            vm,
            elements: contextMenuItems,
            contextMenuElementBuilder: contextMenuElementBuilder
        )
    }
}
