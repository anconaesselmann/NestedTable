//  Created by Axel Ancona Esselmann on 1/24/24.
//

import SwiftUI

extension Table {
    @MainActor
    init<Content>(
        _ vm: NestedTableViewModel<Content>,
        @TableColumnBuilder<Value, KeyPathComparator<BaseRow<Content>>>
        columns: () -> Columns,
        @TableRowBuilder<Value>
        rows: () -> Rows
    )
        where
            Value.Type == BaseRow<Content>.Type
    {
        self.init(
            of: BaseRow<Content>.self,
            selection: Binding(get: {
                vm.selection
            }, set: {
                vm.selection = $0
            }),
            sortOrder: Binding(get: {
                vm.sortOrder
            }, set: {
                vm.sortOrder = $0
            }),
            columns: columns,
            rows: rows
        )
    }
}

extension NestedTableView {
    init(
        of type: Content.Type,
        manager: (NestedTableDataManager & NestedTableDelegate & ContextMenuManager)
    ) {
        self.init(
            of: type,
            dataManager: manager,
            delegate: manager,
            contextMenuManager: manager
        )
    }

    init(
        of type: Content.Type,
        manager: (NestedTableDataManager & NestedTableDelegate),
        contextMenuManager: ContextMenuManager? = nil
    ) {
        self.init(
            of: type,
            dataManager: manager,
            delegate: manager,
            contextMenuManager: contextMenuManager
        )
    }
}
