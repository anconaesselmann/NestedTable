//  Created by Axel Ancona Esselmann on 1/24/24.
//

import Foundation

protocol NestedTableDataManager {
    func fetch() async throws -> [any TableRowItem]
    func fetch(ids: Set<UUID>) async throws -> [any TableRowItem]
    func create(_ selectedId: UUID?, item: any TableRowItem) async throws -> UUID
    func createGroup(with ids: Set<UUID>, named: String, parent: UUID?) async throws -> UUID
    func delete(_ ids: Set<UUID>) async throws -> Set<UUID>
    func move(itemWithId id: UUID, toGroupWithId groupId: UUID?) async throws
    func rename(_ id: UUID, to newName: String) async throws

    func contentStore() async -> ContentStore
}

protocol NestedTableDelegate {
    func performPrimaryAction(for id: UUID)
    func error(_ error: Error)
    // TODO: Update loading state
}

protocol ContentStore {
    func rowItems(for records: [Record]) async throws -> [any TableRowItem]
    func createGroup(_ groupRecord: Record) async throws
    func deleteGroups(_ ids: Set<UUID>) async throws
    func deleteItems(_ ids: Set<UUID>) async throws
    func renameGroup(_ id: UUID, to newName: String) async throws
    func renameItem(_ id: UUID, to newName: String) async throws
}

extension ContentStore {
    func createGroup(_ groupRecord: Record) async throws {
        // Implement to track group creation
    }

    func deleteGroups(_ ids: Set<UUID>) async throws {
        // Implement to track
    }

    func deleteItems(_ ids: Set<UUID>) async throws {
        // Implement to track item deletion
    }

    func renameGroup(_ id: UUID, to newName: String) async throws {
        // Implement to track group renaming
    }

    func renameItem(_ id: UUID, to newName: String) async throws {
        // Implement to track item renaming
    }
}