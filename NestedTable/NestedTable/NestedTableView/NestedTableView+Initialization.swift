//  Created by Axel Ancona Esselmann on 1/24/24.
//

import SwiftUI

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
