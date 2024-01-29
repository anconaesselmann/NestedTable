//  Created by Axel Ancona Esselmann on 1/29/24.
//

import Foundation

@RecordsStore
public struct NamespacedRecordsStore: NestedTableDataManager {

    private let namespace: UUID
    private let store: RecordsStore

    internal init(_ namespace: UUID, store: RecordsStore) {
        self.namespace = namespace
        self.store = store
    }

    public func fetch() async throws -> [any TableRowItem] {
        try await store.fetch(namespace: namespace)
    }

    public func fetch(ids: Set<UUID>) async throws -> [any TableRowItem] {
        try await store.fetch(ids: ids, namespace: namespace)
    }

    public func create(_ selectedId: UUID?, item: any TableRowItem) async throws -> UUID {
        try await store.create(selectedId, item: item, namespace: namespace)
    }

    public func createGroup(with ids: Set<UUID>, named name: String, parent: UUID?) async throws -> UUID {
        try await store.createGroup(with: ids, namespace: namespace, named: name, parent: parent)
    }

    public func delete(_ ids: Set<UUID>) async throws -> Set<UUID> {
        try await store.delete(ids)
    }

    public func move(itemWithId id: UUID, toGroupWithId groupId: UUID?) async throws {
        try await store.move(itemWithId: id, toGroupWithId: groupId)
    }

    public func rename(_ id: UUID, to newName: String) async throws {
        try await store.rename(id, to: newName)
    }

    public func contentStore() async -> ContentStore {
        await store.contentStore()
    }
}
