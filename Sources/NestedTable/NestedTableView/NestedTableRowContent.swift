//  Created by Axel Ancona Esselmann on 1/25/24.
//

import SwiftUI

public struct NestedTableRowContent<Content>: TableRowContent {

    public let vm: NestedTableViewModel<Content>
    public let item: BaseRow<Content>

    public init(vm: NestedTableViewModel<Content>, item: BaseRow<Content>) {
        self.vm = vm
        self.item = item
    }

    @MainActor
    public var tableRowBody: some TableRowContent<ModifiedContent<TableRow<BaseRow<Content>>, ItemProviderTableRowModifier>.TableRowValue> {
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
