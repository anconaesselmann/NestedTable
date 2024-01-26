//  Created by Axel Ancona Esselmann on 1/25/24.
//

import SwiftUI

struct NestedTableRowContent<Content>: TableRowContent {

    let vm: NestedTableViewModel<Content>
    let item: BaseRow<Content>

    @MainActor
    var tableRowBody: some TableRowContent<ModifiedContent<TableRow<BaseRow<Content>>, ItemProviderTableRowModifier>.TableRowValue> {
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
