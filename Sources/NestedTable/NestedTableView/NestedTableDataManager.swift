//  Created by Axel Ancona Esselmann on 1/24/24.
//

import Foundation

enum NestedTableDataManagerError: Swift.Error {
    case missingElement
}

public protocol NestedTableDataManager {
    func fetch() async throws -> [any TableRowItem]
    func fetch(ids: Set<UUID>) async throws -> [any TableRowItem]
    func create(_ selectedId: UUID?, item: any TableRowItem) async throws -> UUID
    func createGroup(with ids: Set<UUID>, named: String, parent: UUID?) async throws -> UUID

    @discardableResult
    func delete(_ ids: Set<UUID>) async throws -> Set<UUID>
    func move(itemWithId id: UUID, toGroupWithId groupId: UUID?) async throws
    func move(itemsWithIds ids: Set<UUID>, toGroupWithId groupId: UUID?) async throws
    func rename(_ id: UUID, to newName: String) async throws

    func contentStore() async -> ContentStore
}

public extension NestedTableDataManager {

    func isGroup(_ id: UUID) async throws -> Bool {
        guard let row = try await fetch(ids: [id]).first else {
            throw NestedTableDataManagerError.missingElement
        }
        guard let group = row as? Group else {
            return false
        }
        return true
    }

    func parent(for id: UUID) async throws -> UUID? {
        try await fetch(ids: [id])
            .first?
            .parent
    }
}

public protocol NestedTableDelegate: AnyObject {
    func selection(_ ids: Set<UUID>)
    func performPrimaryAction(for id: UUID)
    func error(_ error: Error)
    // TODO: Update loading state
}

public protocol ContentStore {
    func rowItems(for records: [Record]) async throws -> [any TableRowItem]
    func createGroup(_ groupRecord: Record) async throws
    func deleteGroups(_ ids: Set<UUID>) async throws
    func deleteItems(_ ids: Set<UUID>) async throws
    func renameGroup(_ id: UUID, to newName: String) async throws
    func renameItem(_ id: UUID, to newName: String) async throws

    func changeNamespace(items ids: Set<UUID>, newNamespace: UUID) async throws
}

public extension ContentStore {

    func createGroup(_ groupRecord: Record, namespace: UUID) async throws {
        try await createGroup(groupRecord)
    }

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

    func changeNamespace(items ids: Set<UUID>, newNamespace: UUID) async throws {
        
    }
}
