//  Created by Axel Ancona Esselmann on 1/29/24.
//

import Foundation
import Combine

@RecordsStore
public class NamespacedRecordsStore: NestedTableDataManager {

    private var namespace: UUID
    private let store: RecordsStore

    nonisolated public var removed: PassthroughSubject<Set<UUID>, Never> {
        store.removed
    }
    
    nonisolated public var hardRefreshSelection: PassthroughSubject<UUID, Never> {
        store.hardRefreshSelection
    }

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

    public func create(in groupId: UUID, item: any TableRowItem) async throws -> UUID {
        try await store.create(in: groupId, item: item, namespace: namespace)
    }

    public func createGroup(withContent ids: Set<UUID>, named name: String, parent: UUID?) async throws -> UUID {
        try await store.createGroup(withContent: ids, named: name, parent: parent, namespace: namespace)
    }

    public func createGroup(withId recordId: UUID, content ids: Set<UUID>, named name: String, parent: UUID?) async throws {
        try await store.createGroup(withId: recordId, content: ids, named: name, parent: parent, namespace: namespace)
    }

    @discardableResult
    public func delete(_ ids: Set<UUID>) async throws -> Set<UUID> {
        try await store.delete(ids)
    }

    public func move(itemWithId id: UUID, toGroupWithId groupId: UUID?) async throws {
        try await store.move(itemWithId: id, toGroupWithId: groupId)
    }

    public func move(itemsWithIds ids: Set<UUID>, toGroupWithId groupId: UUID?) async throws {
        try await store.move(itemsWithIds: ids, toGroupWithId: groupId)
    }

    public func rename(_ id: UUID, to newName: String) async throws {
        try await store.rename(id, to: newName)
    }

    public func contentStore() async -> ContentStore {
        await store.contentStore()
    }

    public func switchNamespace(_ uuid: UUID) async {
        namespace = uuid
    }

    @discardableResult
    public func moveNamespace(_ ids: Set<UUID>, to namespaceId: UUID) async throws -> Set<UUID> {
        try await store.moveNamespace(ids, to: namespaceId)
    }
}
