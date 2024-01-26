//  Created by Axel Ancona Esselmann on 1/26/24.
//

import Foundation

extension MockDataManager: NestedTableDataManager {

    func fetch() async throws -> [any TableRowItem] {
//        try await Task.sleep(nanoseconds: 1_000_000_000)
        return try await fetch(ids: root)
    }

    func fetch(ids: Set<UUID>) async throws -> [any TableRowItem] {
//        try await Task.sleep(nanoseconds: 1_000_000_000)
        return ids.compactMap {
            itemsById[$0]
        }
        .sorted(by: { $0.text < $1.text } )
    }

    func create(group: Group) async throws {
        var containers: Set<UUID> = []
        var removed = 0
        for item in itemsById {
            if var current = item.value as? Group {
                let remove = current.contents.intersection(group.contents)
                if !remove.isEmpty {
                    current.contents = current.contents.subtracting(group.contents)
                    itemsById[item.key] = current
                    containers.insert(current.id)
                    removed += remove.count
                    if removed == group.contents.count {
                        break
                    }
                }
            }
        }
        itemsById[group.id] = group
        if
            removed != group.contents.count ||
            containers.count != 1 ||
            !root.intersection(group.contents).isEmpty
        {
            let remove = root.intersection(group.contents)
            root = root.subtracting(remove)
            root.insert(group.id)
        } else if let first = containers.first, var current = itemsById[first] as? Group  {
            current.contents.insert(group.id)
            itemsById[first] = current
        } else {
            assertionFailure()
        }
    }

    func delete(_ ids: Set<UUID>) async throws -> Set<UUID> {
        var deleted = [UUID]()
        let groups = ids.compactMap {
            itemsById[$0] as? Group
        }
        for group in groups {
            deleted += try await delete(group.contents)
        }
        var removed = 0
        for item in itemsById {
            if var group = item.value as? Group {
                let contained = group.contents.intersection(ids)
                if !contained.isEmpty {
                    group.contents = group.contents.subtracting(contained)
                    removed += contained.count
                    if removed == ids.count {
                        break
                    }
                }
            }
        }
        let contained = root.intersection(ids)
        if !contained.isEmpty {
            root = root.subtracting(contained)
        }
        for id in ids {
            itemsById.removeValue(forKey: id)
        }
        return Set(deleted + ids)
    }

    func move(itemWithId id: UUID, toGroupWithId groupId: UUID?) async throws {
        for item in itemsById {
            if var group = item.value as? Group, group.contents.contains(id) {
                group.contents.remove(id)
                itemsById[group.id] = group
                break
            }
        }
        if root.contains(id) {
            root.remove(id)
        }
        if let groupId = groupId, var copy = itemsById[groupId] as? Group {
            copy.contents.insert(id)
            itemsById[groupId] = copy
        } else {
            root.insert(id)
        }
    }

    func rename(_ id: UUID, to newName: String) async throws {
        guard var copy = itemsById[id] else {
            throw Error.internalInconcistency
        }
        copy.text = newName
        itemsById[id] = copy
    }
}
