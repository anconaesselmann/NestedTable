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

    private var root: Set<UUID> = [
        UUID(uuidString: "b799469c-8b2f-4e25-b5f6-90e645f7fd3d")!,
        UUID(uuidString: "262925e8-59f2-4b98-9880-bf653e0b5423")!,
        UUID(uuidString: "32be27f3-ffa4-41d9-857e-af28860ddc92")!,
        UUID(uuidString: "5baf36eb-0fd9-4e0f-882d-3d8b5c53fe5d")!,
        UUID(uuidString: "1604e4f4-a8ae-40ee-9dab-793cbca7e139")!,
        UUID(uuidString: "624b1f4e-d78c-4718-92af-9165c57abd03")!,
        UUID(uuidString: "9f56e4e8-2a6c-41af-ba33-c04ff3103957")!
    ]

    private var itemsById: [UUID: any TableRowItem] =
        [

            UUID(uuidString: "b799469c-8b2f-4e25-b5f6-90e645f7fd3d")!: MockItem(id: UUID(uuidString: "b799469c-8b2f-4e25-b5f6-90e645f7fd3d")!, text: "A", content: .a),
            UUID(uuidString: "262925e8-59f2-4b98-9880-bf653e0b5423")!: Group(
                id: UUID(uuidString: "262925e8-59f2-4b98-9880-bf653e0b5423")!,
                text: "B",
                contents: [
                     UUID(uuidString: "61aa6c3b-dc14-47fa-81bf-fbdf074abe9a")!,
                     UUID(uuidString: "25b97e1a-4ccf-4ee1-95b1-38072bdbc991")!,
                     UUID(uuidString: "a4ba7e44-aaaf-4de1-9e0d-01079c3ec042")!,
                     UUID(uuidString: "06a01946-bf21-41cb-9a43-073e3c386d1d")!,
                     UUID(uuidString: "67db687d-0bb4-4309-a73f-b00e2929deba")!
                 ]
             ),
            UUID(uuidString: "32be27f3-ffa4-41d9-857e-af28860ddc92")!: MockItem(id: UUID(uuidString: "32be27f3-ffa4-41d9-857e-af28860ddc92")!, text: "C", content: .b),
            UUID(uuidString: "5baf36eb-0fd9-4e0f-882d-3d8b5c53fe5d")!: MockItem(id: UUID(uuidString: "5baf36eb-0fd9-4e0f-882d-3d8b5c53fe5d")!, text: "D", content: .c),
            UUID(uuidString: "1604e4f4-a8ae-40ee-9dab-793cbca7e139")!: MockItem(id: UUID(uuidString: "1604e4f4-a8ae-40ee-9dab-793cbca7e139")!, text: "E", content: .a),
            UUID(uuidString: "624b1f4e-d78c-4718-92af-9165c57abd03")!: MockItem(id: UUID(uuidString: "624b1f4e-d78c-4718-92af-9165c57abd03")!, text: "F", content: .b),
            UUID(uuidString: "9f56e4e8-2a6c-41af-ba33-c04ff3103957")!: MockItem(id: UUID(uuidString: "9f56e4e8-2a6c-41af-ba33-c04ff3103957")!, text: "G", content: .c),


            UUID(uuidString: "61aa6c3b-dc14-47fa-81bf-fbdf074abe9a")!: MockItem(id: UUID(uuidString: "61aa6c3b-dc14-47fa-81bf-fbdf074abe9a")!, text: "B_A", content: .a),
            UUID(uuidString: "25b97e1a-4ccf-4ee1-95b1-38072bdbc991")!: MockItem(id: UUID(uuidString: "25b97e1a-4ccf-4ee1-95b1-38072bdbc991")!, text: "B_B", content: .a),
            UUID(uuidString: "a4ba7e44-aaaf-4de1-9e0d-01079c3ec042")!: Group(
                id: UUID(uuidString: "a4ba7e44-aaaf-4de1-9e0d-01079c3ec042")!,
                text: "B_C",
                contents: [
                    UUID(uuidString: "90d1af9a-1935-44a1-9329-0607336830a3")!,
                    UUID(uuidString: "240a17f8-a75c-4e13-a662-edb2767dcd52")!,
                    UUID(uuidString: "80165ff0-94d7-47ec-b540-439c7369c172")!,
                    UUID(uuidString: "7e2dbfc2-d507-4be9-952f-72f858cc3ff3")!,
                    UUID(uuidString: "aa3a9949-388f-4b95-bfe2-882a067ea298")!
                ]
            ),
            UUID(uuidString: "06a01946-bf21-41cb-9a43-073e3c386d1d")!: MockItem(id: UUID(uuidString: "06a01946-bf21-41cb-9a43-073e3c386d1d")!, text: "B_D", content: .a),
            UUID(uuidString: "67db687d-0bb4-4309-a73f-b00e2929deba")!: MockItem(id: UUID(uuidString: "67db687d-0bb4-4309-a73f-b00e2929deba")!, text: "B_E", content: .a),


            UUID(uuidString: "90d1af9a-1935-44a1-9329-0607336830a3")!: MockItem(id: UUID(uuidString: "90d1af9a-1935-44a1-9329-0607336830a3")!, text: "B_C_A", content: .a),
            UUID(uuidString: "240a17f8-a75c-4e13-a662-edb2767dcd52")!: MockItem(id: UUID(uuidString: "240a17f8-a75c-4e13-a662-edb2767dcd52")!, text: "B_C_B", content: .a),
            UUID(uuidString: "80165ff0-94d7-47ec-b540-439c7369c172")!: MockItem(id: UUID(uuidString: "80165ff0-94d7-47ec-b540-439c7369c172")!, text: "B_C_C", content: .a),
            UUID(uuidString: "7e2dbfc2-d507-4be9-952f-72f858cc3ff3")!: MockItem(id: UUID(uuidString: "7e2dbfc2-d507-4be9-952f-72f858cc3ff3")!, text: "B_C_D", content: .a),
            UUID(uuidString: "aa3a9949-388f-4b95-bfe2-882a067ea298")!: MockItem(id: UUID(uuidString: "aa3a9949-388f-4b95-bfe2-882a067ea298")!, text: "B_C_E", content: .a)
        ]

    func create(_ selectedId: UUID) async throws -> UUID {
        let id = UUID()
        itemsById[id] = MockItem(id: id, text: ["A", "B", "C"].shuffled()[0], content: .c)
        let parent: UUID?
        let selected = itemsById[selectedId]
        if (selected as? Group) != nil {
            parent = selected?.id
        } else {
            parent = selected?.parent // TODO: parent is not assigned right now...
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
