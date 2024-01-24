//  Created by Axel Ancona Esselmann on 1/23/24.
//

import Foundation

class DataManager {
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

            UUID(uuidString: "b799469c-8b2f-4e25-b5f6-90e645f7fd3d")!: Item(id: UUID(uuidString: "b799469c-8b2f-4e25-b5f6-90e645f7fd3d")!, text: "A"),
            UUID(uuidString: "262925e8-59f2-4b98-9880-bf653e0b5423")!: Folder(
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
            UUID(uuidString: "32be27f3-ffa4-41d9-857e-af28860ddc92")!: Item(id: UUID(uuidString: "32be27f3-ffa4-41d9-857e-af28860ddc92")!, text: "C"),
            UUID(uuidString: "5baf36eb-0fd9-4e0f-882d-3d8b5c53fe5d")!: Item(id: UUID(uuidString: "5baf36eb-0fd9-4e0f-882d-3d8b5c53fe5d")!, text: "D"),
            UUID(uuidString: "1604e4f4-a8ae-40ee-9dab-793cbca7e139")!: Item(id: UUID(uuidString: "1604e4f4-a8ae-40ee-9dab-793cbca7e139")!, text: "E"),
            UUID(uuidString: "624b1f4e-d78c-4718-92af-9165c57abd03")!: Item(id: UUID(uuidString: "624b1f4e-d78c-4718-92af-9165c57abd03")!, text: "F"),
            UUID(uuidString: "9f56e4e8-2a6c-41af-ba33-c04ff3103957")!: Item(id: UUID(uuidString: "9f56e4e8-2a6c-41af-ba33-c04ff3103957")!, text: "G"),


            UUID(uuidString: "61aa6c3b-dc14-47fa-81bf-fbdf074abe9a")!: Item(id: UUID(uuidString: "61aa6c3b-dc14-47fa-81bf-fbdf074abe9a")!, text: "B_A"),
            UUID(uuidString: "25b97e1a-4ccf-4ee1-95b1-38072bdbc991")!: Item(id: UUID(uuidString: "25b97e1a-4ccf-4ee1-95b1-38072bdbc991")!, text: "B_B"),
            UUID(uuidString: "a4ba7e44-aaaf-4de1-9e0d-01079c3ec042")!: Folder(
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
            UUID(uuidString: "06a01946-bf21-41cb-9a43-073e3c386d1d")!: Item(id: UUID(uuidString: "06a01946-bf21-41cb-9a43-073e3c386d1d")!, text: "B_D"),
            UUID(uuidString: "67db687d-0bb4-4309-a73f-b00e2929deba")!: Item(id: UUID(uuidString: "67db687d-0bb4-4309-a73f-b00e2929deba")!, text: "B_E"),


            UUID(uuidString: "90d1af9a-1935-44a1-9329-0607336830a3")!: Item(id: UUID(uuidString: "90d1af9a-1935-44a1-9329-0607336830a3")!, text: "B_C_A"),
            UUID(uuidString: "240a17f8-a75c-4e13-a662-edb2767dcd52")!: Item(id: UUID(uuidString: "240a17f8-a75c-4e13-a662-edb2767dcd52")!, text: "B_C_B"),
            UUID(uuidString: "80165ff0-94d7-47ec-b540-439c7369c172")!: Item(id: UUID(uuidString: "80165ff0-94d7-47ec-b540-439c7369c172")!, text: "B_C_C"),
            UUID(uuidString: "7e2dbfc2-d507-4be9-952f-72f858cc3ff3")!: Item(id: UUID(uuidString: "7e2dbfc2-d507-4be9-952f-72f858cc3ff3")!, text: "B_C_D"),
            UUID(uuidString: "aa3a9949-388f-4b95-bfe2-882a067ea298")!: Item(id: UUID(uuidString: "aa3a9949-388f-4b95-bfe2-882a067ea298")!, text: "B_C_E")
        ]

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

    func create(folder: Folder) async throws {
        var containers: Set<UUID> = []
        var removed = 0
        for item in itemsById {
            if var current = item.value as? Folder {
                let remove = current.contents.intersection(folder.contents)
                if !remove.isEmpty {
                    current.contents = current.contents.subtracting(folder.contents)
                    itemsById[item.key] = current
                    containers.insert(current.id)
                    removed += remove.count
                    if removed == folder.contents.count {
                        break
                    }
                }
            }
        }
        itemsById[folder.id] = folder
        if
            removed != folder.contents.count ||
            containers.count != 1 ||
            !root.intersection(folder.contents).isEmpty
        {
            let remove = root.intersection(folder.contents)
            root = root.subtracting(remove)
            root.insert(folder.id)
        } else if let first = containers.first, var current = itemsById[first] as? Folder  {
            current.contents.insert(folder.id)
            itemsById[first] = current
        } else {
            assertionFailure()
        }
    }

    func delete(_ ids: Set<UUID>) async throws -> Set<UUID> {
        var deleted = [UUID]()
        let folders = ids.compactMap {
            itemsById[$0] as? Folder
        }
        for folder in folders {
            deleted += try await delete(folder.contents)
        }
        var removed = 0
        for item in itemsById {
            if var folder = item.value as? Folder {
                let contained = folder.contents.intersection(ids)
                if !contained.isEmpty {
                    folder.contents = folder.contents.subtracting(contained)
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
            if var folder = item.value as? Folder, folder.contents.contains(id) {
                folder.contents.remove(id)
                itemsById[folder.id] = folder
                break
            }
        }
        if root.contains(id) {
            root.remove(id)
        }
        if let groupId = groupId, var copy = itemsById[groupId] as? Folder {
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
