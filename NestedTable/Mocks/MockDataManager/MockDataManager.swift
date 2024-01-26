//  Created by Axel Ancona Esselmann on 1/23/24.
//

import Foundation

class MockDataManager {

    enum Error: Swift.Error {
        case internalInconcistency
    }

    static let shared = MockDataManager()

    internal var root: Set<UUID> = []
    internal var itemsById: [UUID: any TableRowItem] = [:]

    func create(_ selectedId: UUID?) async throws -> UUID {
        let id = UUID()
        itemsById[id] = MockItem(id: id, text: ["A", "B", "C"].shuffled()[0], content: .c)
        let parent: UUID?
        if let selectedId = selectedId {
            let selected = itemsById[selectedId]
            if (selected as? Group) != nil {
                parent = selected?.id
            } else {
                parent = selected?.parent // TODO: parent is not assigned right now...
            }
        } else {
            parent = nil
        }
        try await move(itemWithId: id, toGroupWithId: parent)
        return id
    }
}
