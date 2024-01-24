//  Created by Axel Ancona Esselmann on 1/24/24.
//

import Foundation

protocol NestedTableDataManager {
    func fetch() async throws -> [any TableRowItem]
    func fetch(ids: Set<UUID>) async throws -> [any TableRowItem]
    func create(group: Group) async throws
    func delete(_ ids: Set<UUID>) async throws -> Set<UUID>
    func move(itemWithId id: UUID, toGroupWithId groupId: UUID?) async throws
    func rename(_ id: UUID, to newName: String) async throws
}

protocol NestedTableDelegate {
    func performPrimaryAction(for id: UUID)
    func error(_ error: Error)
}
