//  Created by Axel Ancona Esselmann on 1/25/24.
//

import SwiftUI

extension Table {

    @MainActor
    func nestedTableView<Content>(
        _ vm: NestedTableViewModel<Content>,
        elements: [any ContextMenuItems],
        contextMenuElementBuilder: ((NestedTableViewModel<Content>, String, Set<UUID>) -> AnyView?)?
    ) -> some View {
        let copy = self
        return copy.contextMenu(forSelectionType: UUID.self) { ids in
            ItemContextMenu(
                vm,
                ids: ids,
                elements: elements,
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
