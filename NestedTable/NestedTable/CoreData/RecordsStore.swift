//  Created by Axel Ancona Esselmann on 1/26/24.
//

import Foundation
import CoreData
import CoreDataContainer
import Combine

@globalActor
actor RecordsStore {

    enum Error: Swift.Error {
        case missingContentId
    }

    static let shared = RecordsStore()

    private let container: CoreDataContainer

    private init() {
        self.container = try! NSPersistentContainer(model: "Records", type: .local(name: "Records"))
    }

    func initialize() async throws {
        try await container.loadPersistentStores()
    }

    @RecordsStore
    lazy var backgroundContext: NSManagedObjectContext = {
        container.newBackgroundContext()
    }()

    @MainActor
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    func create(_ selectedId: UUID?) async throws -> UUID {
        let id = UUID()
        let text = ["A", "B", "C"].shuffled()[0]
        let item = MockItem(id: id, text: text, content: .shuffled)
        let record = Record(id: id, isGroup: false, text: text, content: [item.content.id])
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
        try await move(itemWithId: id, toGroupWithId: parent)
        return id
    }
}

import SwiftUI

extension RecordsStore: NestedTableDataManager {

    func rowItems(for records: [Record]) throws -> [any TableRowItem] {
        try records.map { record in
            if record.isGroup {
                return Group(
                    id: record.id,
                    parent: record.parent,
                    text: record.text,
                    image: Image(systemName: "folder.fill"),
                    contents: record.content
                )
            } else {
                guard let contentId = record.content.first else {
                    throw Error.missingContentId
                }
                return Item<MockContent>(
                    id: record.id,
                    parent: record.parent,
                    text: record.text,
                    image: Image(systemName: "music.note.list"),
                    content: MockContent(test: contentId.uuidString)
                )
            }
        }
    }

    func fetch() async throws -> [any TableRowItem] {
        let records = try await Record.fetch(
            in: backgroundContext,
            where: (keyPath: \.parent, equal: NSNull())
        )
        return try rowItems(for: records)
    }
    
    func fetch(ids: Set<UUID>) async throws -> [any TableRowItem] {
        let entities = try await Record.fetchEntities(withIds: ids, in: backgroundContext)
        let records = try entities.map { try Record($0) }
        return try rowItems(for: records)
    }
    
    func create(group: Group) async throws {
        let context = await backgroundContext
        try await context.perform {
            let record = Record(
                id: group.id,
                isGroup: true,
                parent: group.parent,
                text: group.text,
                content: group.contents
            )
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
    }
    
    func delete(_ ids: Set<UUID>) async throws -> Set<UUID> {
        guard !ids.isEmpty else {
            return []
        }
        let context = await backgroundContext
        var deleted = ids
        var toDelete = Set<UUID>()
        try await context.perform {
            for id in ids {
                let record = try Record(id: id, in: context)
                if record.isGroup {
                    toDelete = record.content
                }
                try Record.delete(id: id, in: context)
            }
            try context.save()
        }
        deleted = deleted.union(try await delete(toDelete))
        return deleted
    }
    
    func move(itemWithId id: UUID, toGroupWithId groupId: UUID?) async throws {
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
    
    func rename(_ id: UUID, to newName: String) async throws {
        let context = await backgroundContext
        try await context.perform {
            var record = try Record(id: id, in: context)
            record.text = newName
            try record.update(in: context)
            try context.save()
        }
    }
}
