//  Created by Axel Ancona Esselmann on 1/26/24.
//

import Foundation
import CoreData
import Combine

@globalActor
public actor RecordsStore {

    enum Error: Swift.Error {
        case alreadyInitialized, notInitialized, noGroupForRecord
    }

    public static let shared = RecordsStore()

    @RecordsStore
    private var container: NSPersistentContainer!

    @RecordsStore
    private var _contentStore: ContentStore!

    @RecordsStore
    internal lazy var backgroundContext: NSManagedObjectContext = {
        container.newBackgroundContext()
    }()

    @RecordsStore
    var initialized: Bool {
        _contentStore != nil
    }

    private init() { }

    @RecordsStore
    @discardableResult
    public func initialize(
        contentStore: ContentStore,
        subdirectory: String? = nil
    ) async throws -> Self {
        let container = try Self.createContainer(subdirectory: subdirectory)
        let initialized = try await self.initialize(
            contentStore: contentStore,
            container: container
        )
        try await container.loadPersistentStores()
        return initialized
    }

    @RecordsStore
    @discardableResult
    public func initialize(
        contentStore: ContentStore,
        container: NSPersistentContainer
    ) async throws -> Self {
        guard !initialized else {
            throw Error.alreadyInitialized
        }
        self._contentStore = contentStore
        self.container = container
        return self
    }

    @RecordsStore
    public func namespaced(_ namespace: UUID) throws -> NamespacedRecordsStore {
        guard initialized else {
            throw Error.notInitialized
        }
        return NamespacedRecordsStore(namespace, store: self)
    }
}

extension RecordsStore: NestedTableDataManager {

    public func contentStore() async -> ContentStore {
        await _contentStore
    }

    public func fetch() async throws -> [any TableRowItem] {
        try await fetch(namespace: nil)
    }

    internal func fetch(namespace: UUID?) async throws -> [any TableRowItem] {
        let records = try await Record.fetch(
            in: backgroundContext,
            where: 
                (keyPath: \.parent, equal: NSNull()),
                (keyPath: \.namespace, equal: namespace ?? NSNull())
        )
        return try await contentStore().rowItems(for: records)
    }

    public func fetch(ids: Set<UUID>) async throws -> [any TableRowItem] {
        try await fetch(ids: ids, namespace: nil)
    }

    internal func fetch(ids: Set<UUID>, namespace: UUID?) async throws -> [any TableRowItem] {
        let entities = try await Record.fetchEntities(withIds: ids, in: backgroundContext)
            .filter { $0.namespace == namespace } // TODO: filter when fetching
        let records = try entities.map { try Record($0) }
        return try await contentStore().rowItems(for: records)
    }


    public func create(_ selectedId: UUID?, item: any TableRowItem) async throws -> UUID {
        try await create(selectedId, item: item, namespace: nil)
    }

    internal func create(_ selectedId: UUID?, item: any TableRowItem, namespace: UUID?) async throws -> UUID {
        let record = Record(id: item.id, isGroup: false, text: item.text, content: [item.id])
        let context = await backgroundContext
        var parent: UUID?
        try await context.perform {
            let entity = record.entity(in: context)
            entity.namespace = namespace
            if let selectedId = selectedId {
                let selected = try Record(id: selectedId, in: context)
                try context.save()
                if selected.isGroup {
                    parent = selected.id
                } else {
                    parent = selected.parent
                }
            } else {
                parent = nil
            }
        }
        try await move(itemWithId: record.id, toGroupWithId: parent)
        return record.id
    }

    public func createGroup(with ids: Set<UUID>, named name: String, parent: UUID?) async throws -> UUID {
        try await createGroup(with: ids, namespace: nil, named: name, parent: parent)
    }

    internal func createGroup(with ids: Set<UUID>, namespace: UUID?, named name: String, parent: UUID?) async throws -> UUID {
        let recordId = UUID()
        let record = Record(
            id: recordId,
            isGroup: true,
            parent: parent,
            text: name,
            content: ids
        )
        if let namespace = namespace {
            try await contentStore().createGroup(record, namespace: namespace)
        } else {
            try await contentStore().createGroup(record)
        }
        guard
            let item = try await contentStore().rowItems(for: [record]).first,
            let group = item as? Group else
        {
            throw Error.noGroupForRecord
        }
        let context = await backgroundContext
        try await context.perform {

            if let parentId = group.parent {
                var parent = try Record(id: parentId, in: context)
                parent.content.insert(group.id)
                try parent.update(in: context)
            }
            let entity = record.entity(in: context)
            entity.namespace = namespace
            let contentRecordEntities = try Record.fetchEntities(withIds: group.contents, in: context)
            let contentRecords = try contentRecordEntities.map { try Record($0) }
            let contentParentIds = Set(contentRecords.compactMap { $0.parent })
            let contentParentEntities = try Record.fetchEntities(withIds: contentParentIds, in: context)
            let contentParents = try contentParentEntities.map { try Record($0) }
            for var contentParent in contentParents {
                contentParent.content = contentParent.content.subtracting(group.contents)
                try contentParent.update(in: context)
            }
            for var contentRecord in contentRecords {
                contentRecord.parent = group.id
                try contentRecord.update(in: context)
            }
            try context.save()
        }
        return recordId
    }
    
    @discardableResult
    public func delete(_ ids: Set<UUID>) async throws -> Set<UUID> {
        guard !ids.isEmpty else {
            return []
        }
        let context = await backgroundContext
        var deleted = Set<UUID>()
        var toDelete = Set<UUID>()
        var recordsToDelete: [Record] = []
        try await context.perform {
            recordsToDelete = try Record.fetchEntities(withIds: ids, in: context)
                .map { try Record($0) }
            var removeFromParent: [UUID: [UUID]] = [:]
            for record in recordsToDelete {
                let recordId = record.id
                let parentId = record.parent
                let isGroup = record.isGroup
                if isGroup {
                    toDelete = toDelete.union(record.content)
                }
                try Record.delete(id: recordId, in: context)
                deleted.insert(recordId)
                if let parentId = parentId {
                    removeFromParent[parentId] = (removeFromParent[parentId] ?? []) + [recordId]
                }
            }
            // Remove entry from parents
            let parentIds = Set(removeFromParent.keys)
            if !parentIds.isEmpty {
                let parents = try Record.fetchEntities(withIds: parentIds, in: context)
                for parent in parents {
                    guard let children = removeFromParent[parent.id] else {
                        continue
                    }
                    guard let content = parent.content.allObjects as? [UUID] else {
                        continue
                    }
                    let newContent = Set(content).subtracting(Set(children))
                    print("Previous content size: \(content.count), new content size: \(newContent.count)")
                    parent.content = newContent as NSSet
                }
            }
            try context.save()
        }
        // If groups are removed remove all nested items
        let groups = recordsToDelete
            .filter { $0.isGroup }
            .map { $0.id }
            .filter { deleted.contains($0) }

        let contentStore = await contentStore()
        if !groups.isEmpty {
            try await contentStore.deleteGroups(Set(groups))
        }
        let items = recordsToDelete
            .filter { !$0.isGroup }
            .map { $0.id }
            .filter { deleted.contains($0) }
        if !items.isEmpty {
            try await contentStore.deleteItems(Set(items))
        }
        deleted = deleted.union(try await delete(toDelete))
        return deleted
    }
    
    public func move(itemWithId id: UUID, toGroupWithId groupId: UUID?) async throws {
        guard id != groupId else {
            return
        }
        let context = await backgroundContext
        try await context.perform {
            var record = try Record(id: id, in: context)
            if let parentId = record.parent {
                var parent = try Record(id: parentId, in: context)
                parent.content.remove(id)
                try parent.update(in: context)
            }
            if let targetGroupId = groupId {
                var targetGroup = try Record(id: targetGroupId, in: context)
                targetGroup.content.insert(id)
                try targetGroup.update(in: context)
            }
            record.parent = groupId
            try record.update(in: context)
            try context.save()
        }
    }

    public func move(itemsWithIds ids: Set<UUID>, toGroupWithId groupId: UUID?) async throws {
        for id in ids {
            try await move(itemWithId: id, toGroupWithId: groupId)
        }
    }

    public func rename(_ id: UUID, to newName: String) async throws {
        let context = await backgroundContext
        var isGroup: Bool = false
        try await context.perform {
            var record = try Record(id: id, in: context)
            isGroup = record.isGroup
            record.text = newName
            try record.update(in: context)
            try context.save()
        }
        let contentStore = await contentStore()
        if isGroup {
            try await contentStore.renameGroup(id, to: newName)
        } else {
            try await contentStore.renameItem(id, to: newName)
        }
    }
}
