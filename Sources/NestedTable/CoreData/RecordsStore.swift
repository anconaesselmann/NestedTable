//  Created by Axel Ancona Esselmann on 1/26/24.
//

import Foundation
import CoreData
import Combine

@globalActor
public actor RecordsStore {

    public static let shared = RecordsStore()

    @RecordsStore
    private var container: NSPersistentContainer!

    @RecordsStore
    private var _contentStore: ContentStore!

    private init() { }

    @RecordsStore
    public func initialize(contentStore: ContentStore, subdirectory: String? = nil) async throws {
        self._contentStore = contentStore
        self.container = try createContainer(subdirectory: subdirectory)
        try await container.loadPersistentStores()
    }

    @RecordsStore
    public func initialize(contentStore: ContentStore, container: NSPersistentContainer) async throws {
        self._contentStore = contentStore
        self.container = container
        try await container.loadPersistentStores()
    }

    @RecordsStore
    lazy var backgroundContext: NSManagedObjectContext = {
        container.newBackgroundContext()
    }()
}

extension RecordsStore: NestedTableDataManager {

    public enum Error: Swift.Error {
        case noGroupForRecord
    }

    public func contentStore() async -> ContentStore {
        await _contentStore
    }

    public func fetch() async throws -> [any TableRowItem] {
        let records = try await Record.fetch(
            in: backgroundContext,
            where: (keyPath: \.parent, equal: NSNull())
        )
        return try await contentStore().rowItems(for: records)
    }
    
    public func fetch(ids: Set<UUID>) async throws -> [any TableRowItem] {
        let entities = try await Record.fetchEntities(withIds: ids, in: backgroundContext)
        let records = try entities.map { try Record($0) }
        return try await contentStore().rowItems(for: records)
    }

    public func create(_ selectedId: UUID?, item: any TableRowItem) async throws -> UUID {
        let record = Record(id: item.id, isGroup: false, text: item.text, content: [item.id])
        let context = await backgroundContext
        var parent: UUID?
        try await context.perform {
            record.entity(in: context)
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
        let recordId = UUID()
        let record = Record(
            id: recordId,
            isGroup: true,
            parent: parent,
            text: name,
            content: ids
        )
        try await contentStore().createGroup(record)
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
            record.entity(in: context)
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
    
    public func delete(_ ids: Set<UUID>) async throws -> Set<UUID> {
        guard !ids.isEmpty else {
            return []
        }
        let context = await backgroundContext
        var deleted = ids
        var toDelete = Set<UUID>()
        var recordsToDelete: [Record] = []
        try await context.perform {
            recordsToDelete = try Record.fetchEntities(withIds: ids, in: context)
                .map { try Record($0) }
            for record in recordsToDelete {
                let isGroup = record.isGroup
                if isGroup {
                    toDelete = record.content
                }
                try Record.delete(id: record.id, in: context)
            }
            try context.save()
        }
        let groups = recordsToDelete
            .filter { $0.isGroup }
            .map { $0.id }

        let contentStore = await contentStore()
        if !groups.isEmpty {
            try await contentStore.deleteGroups(Set(groups))
        }
        let items = recordsToDelete
            .filter { !$0.isGroup }
            .map { $0.id }
        if !items.isEmpty {
            try await contentStore.deleteItems(Set(items))
        }
        deleted = deleted.union(try await delete(toDelete))
        return deleted
    }
    
    public func move(itemWithId id: UUID, toGroupWithId groupId: UUID?) async throws {
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
