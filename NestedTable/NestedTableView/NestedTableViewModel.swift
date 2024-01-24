//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

@MainActor
class NestedTableViewModel: ObservableObject {

    var items: [BaseRow] = []

    @Published
    var selection = Set<UUID>()

    private let dm = DataManager()

    private var expanded: Set<UUID> = []

    func fetch() {
        Task {
            do {
                try await async_fetch()
            } catch {

            }
        }
    }

    private func async_fetch(shouldAnimate: Bool = true) async throws {
        let items = try await dm
            .fetch()
            .map { BaseRow($0) }
        if shouldAnimate {
            withAnimation {
                self.items = items
                self.objectWillChange.send()
            }
        } else {

                self.items = items
                self.objectWillChange.send()
        }
        for item in items {
            if let folder = item.folder, expanded.contains(item.id) {
                await expand(folder, shouldAnimate: shouldAnimate)
            }
        }
    }

    func expand(_ folder: Folder, shouldAnimate: Bool = true) async {
        do {
            guard let index = items.firstIndex(where: { row in
                row.id == folder.id
            }) else {
                return
            }
            let indent = items[index].indent
            let children = try await dm.fetch(ids: folder.contents)
                .map { BaseRow($0, parent: folder.id, indent: indent + 1) }
            if shouldAnimate {
                withAnimation {
                    items.insert(contentsOf: children, at: index + 1)
                    self.objectWillChange.send()
                }
            } else {
                items.insert(contentsOf: children, at: index + 1)
                self.objectWillChange.send()
            }
            for child in children {
                if let childFolder = child.folder {
                    if expanded.contains(childFolder.id) {
                        await expand(childFolder)
                    }
                }
            }
        } catch {

        }
    }

    func contract(_ folder: Folder, shouldAnimate: Bool = true) {
        let remove = items.filter { $0.parent == folder.id }
        for item in remove {
            if let childFolder = item.folder {
                contract(childFolder)
            }
        }
        if shouldAnimate {
            withAnimation {
                items.removeAll(where: { $0.parent == folder.id })
                self.objectWillChange.send()
            }
        } else {
            items.removeAll(where: { $0.parent == folder.id })
            self.objectWillChange.send()
        }
    }

    func toggle(_ folder: Folder) async {
        for i in 0..<items.count {
            if items[i].id == folder.id {
                let current = expanded.contains(folder.id)
                let new = !current
                if new {
                    expanded.insert(folder.id)
                    await expand(folder)
                } else {
                    expanded.remove(folder.id)
                    contract(folder)
                }
                return
            }
        }
    }

    func isExpanded(_ folder: Folder) -> Bool {
        expanded.contains(folder.id)
    }

    func createFolder(with ids: Set<UUID>) async -> UUID? {
        do {
//            guard let firstId = ids.first else {
//                return
//            }
//            guard let row = items.first(where: { $0.id == firstId }) else {
//                return
//            }
            let folder = Folder(id: UUID(), text: "New group", contents: ids)
//            if let parent = row.parent {
//                let parentIndex = items.firstIndex(where: { $0.id == parent })
//            } else {
//                
//            }
            try await dm.create(folder: folder)
//            await removeFromList(ids: ids)
            try await async_fetch()
            expanded.insert(folder.id)
            expanded = expanded.subtracting(ids)
            selection = [folder.id]
            await expand(folder)
            return folder.id
        } catch {
            return nil
        }
    }

//    func isGrouped(_ id: UUID) -> Bool {
//        guard let item = items.first(where: { $0.id == id }) else {
//            return false
//        }
//        return item.parent != nil
//    }

    func isGrouped(_ ids: Set<UUID>) -> Bool {
        items
            .filter { ids.contains($0.id) }
            .map { $0.parent != nil }
            .reduce(into: true) {
                if !$1 {
                    $0 = false
                }
            }
    }

    func removeFromGroup(_ ids: Set<UUID>) async {
        let toRemove = items.filter { ids.contains($0.id) }
        do {
            for item in toRemove {
                let parent = self.items.first(where: { $0.id == item.parent })?.parent
                try await dm.move(itemWithId: item.id, toGroupWithId: parent)
            }
            try await async_fetch(shouldAnimate: false)
            selection = ids
        } catch {
            print(error)
        }
    }

    func move(_ ids: Set<UUID>, to newParent: UUID) async {
        do {
            for id in ids {
                try await dm.move(itemWithId: id, toGroupWithId: newParent)
            }
            try await async_fetch(shouldAnimate: false)
            selection = ids
        } catch {
            print(error)
        }
    }

    var renaming: UUID? {
        didSet {
            guard 
                let newValue = renaming,
                let item = items.first(where: { $0.id == newValue})
            else {
                return
            }
            newName = item.text
        }
    }

    @Published
    var newName: String = ""

    func rename(_ id: UUID) {
        renaming = id
    }

    func rename(_ id: UUID, to newName: String) async {
        do {
            renaming = nil
            try await dm.rename(id, to: newName)
            try await async_fetch(shouldAnimate: false)
        } catch {
            print(error)
        }
    }

    func delete(_ ids: Set<UUID>) async {
        do {
            let deleted = try await dm.delete(ids)
            withAnimation {
                items.removeAll { deleted.contains($0.id) }
                selection = []
            }
        } catch {

        }
    }

//    private func removeFromList(ids: Set<UUID>) async {
//        let remove = items.filter { ids.contains($0.id) }
//        for item in remove {
//            if let childFolder = item.folder {
//                contract(childFolder)
//            }
//        }
//        withAnimation {
//            items.removeAll(where: { ids.contains($0.id) } )
//            self.objectWillChange.send()
//        }
//    }
}
