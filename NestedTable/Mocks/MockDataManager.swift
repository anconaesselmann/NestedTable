//  Created by Axel Ancona Esselmann on 1/23/24.
//

import Foundation

struct MockContent {
    let test: String

    init(_ test: String) {
        self.test = test
    }

    static var a: Self {
        MockContent("a")
    }
    static var b: Self {
        MockContent("b")
    }
    static var c: Self {
        MockContent("c")
    }
}

typealias MockItem = Item<MockContent>

import SwiftUI
extension MockItem {
    init(id: UUID, text: String, content: MockContent) {
        self.init(id: id, text: text, image: Image(systemName: "music.note.list"), content: content)
    }
}

extension Group {
    init(id: UUID, text: String, contents: Set<UUID>) {
        self.init(id: id, text: text, image: Image(systemName: "folder.fill"), contents: contents)
    }
}

class MockDataManager: NestedTableDataManager {

    static let shared = MockDataManager()

    private var root: Set<UUID> = []

    private var itemsById: [UUID: any TableRowItem] = [:]

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

    enum Error: Swift.Error {
        case internalInconcistency
    }

    func rename(_ id: UUID, to newName: String) async throws {
        guard var copy = itemsById[id] else {
            throw Error.internalInconcistency
        }
        copy.text = newName
        itemsById[id] = copy
    }
}
