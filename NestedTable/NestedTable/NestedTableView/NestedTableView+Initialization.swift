//  Created by Axel Ancona Esselmann on 1/24/24.
//

import SwiftUI

extension NestedTableView {
    init(manager: (NestedTableDataManager & NestedTableDelegate & ContextMenuManager)) {
        self.init(
            dataManager: manager,
            delegate: manager,
            contextMenuManager: manager
        )
    }

    init(
        manager: (NestedTableDataManager & NestedTableDelegate),
        contextMenuManager: ContextMenuManager? = nil
    ) {
        self.init(
            dataManager: manager,
            delegate: manager,
            contextMenuManager: contextMenuManager
        )
    }
}
