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
            .onHover {
                vm.onHover(elementId: item.id, isHovering: $0)
            }
            .if(item.isGroup) {
                $0.dropDestination(for: URL.self) {
                    // Note: There apears to be a bug in SwiftUI's TableRowContent:
                    // The documentation states that actions return true of false
                    // based on the success of the drop operation. The closure
                    // that actually is part of the function signatrue returns Void
                    let uuid = $0.compactMap { UUID(nestedTableBaseRowUrl: $0) }
                    if !uuid.isEmpty {
                        vm.itemsDropped(uuid, into: item.id)
                    } else if !$0.isEmpty {
                        vm.itemsDropped($0, into: item.id)
                    } else {
                        
                    }
                }
            }
        #endif
    }
}
