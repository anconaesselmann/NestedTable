//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

@MainActor
class NestedTableViewModel: ObservableObject {

    var items: [BaseRow] = []

    @Published
    var selection = Set<UUID>() {
        didSet {
            if renaming != nil {
                renaming = nil
            }
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

    private var dm: NestedTableDataManager
    private var delegate: NestedTableDelegate

    private var expanded: Set<UUID> = []

    init(dataManager: NestedTableDataManager, delegate: NestedTableDelegate) {
        self.dm = dataManager
        self.delegate = delegate
    }

    func fetch() {
        Task {
            do {
                try await async_fetch()
            } catch {
                delegate.error(error)
            }
        }
    }

    func expand(_ group: Group, shouldAnimate: Bool = true) async {
        do {
            guard let index = items.firstIndex(where: { row in
                row.id == group.id
            }) else {
                return
            }
            let indent = items[index].indent
            let children = try await dm.fetch(ids: group.contents)
                .map { BaseRow($0, parent: group.id, indent: indent + 1) }
            if shouldAnimate {
                withAnimation {
                    items.insert(contentsOf: children, at: index + 1)
                    self.objectWillChange.send()
                }
            } else {
                items.insert(contentsOf: children, at: index + 1)
            }
            for child in children {
                if let childGroup = child.group {
                    if expanded.contains(childGroup.id) {
                        await expand(childGroup, shouldAnimate: shouldAnimate)
                    }
                }
            }
        } catch {
            delegate.error(error)
        }
    }

    func contract(_ group: Group, shouldAnimate: Bool = true) {
        let remove = items.filter { $0.parent == group.id }
        for item in remove {
            if let childGroup = item.group {
                contract(childGroup)
            }
        }
        if shouldAnimate {
            withAnimation {
                items.removeAll(where: { $0.parent == group.id })
                self.objectWillChange.send()
            }
        } else {
            items.removeAll(where: { $0.parent == group.id })
        }
    }

    func toggle(_ group: Group) async {
        for i in 0..<items.count {
            if items[i].id == group.id {
                let current = expanded.contains(group.id)
                let new = !current
                if new {
                    expanded.insert(group.id)
                    await expand(group)
                } else {
                    expanded.remove(group.id)
                    contract(group)
                }
                return
            }
        }
    }

    func isExpanded(_ group: Group) -> Bool {
        expanded.contains(group.id)
    }

    func primaryAction(_ ids: Set<UUID>) {
        guard let id = ids.first, ids.count == 1 else {
            return
        }
        guard let item = items.first(where: { $0.id == id }) else {
            return
        }
        if let group = item.group {
            Task {
                await toggle(group)
            }
        } else {
            delegate.performPrimaryAction(for: id)
        }
    }

    func createGroup(with ids: Set<UUID>) async -> UUID? {
        do {
            let group = Group(id: UUID(), text: "New group", contents: ids)
            try await dm.create(group: group)
            try await async_fetch(shouldAnimate: false)
            expanded.insert(group.id)
            expanded = expanded.subtracting(ids)
            selection = [group.id]
            await expand(group)
            return group.id
        } catch {
            delegate.error(error)
            return nil
        }
    }

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
            delegate.error(error)
        }
    }

    func move(_ ids: Set<UUID>, to newParent: UUID?) async {
        do {
            let ids = ids.filter { $0 != newParent }
            for id in ids {
                try await dm.move(itemWithId: id, toGroupWithId: newParent)
            }
            try await async_fetch(shouldAnimate: false)
            let visible = Set(
                items
                    .filter { ids.contains($0.id) }
                    .map { $0.id }
                )
            if visible.isEmpty, let newParent = newParent {
                selection = [newParent]
            } else {
                selection = visible
            }
        } catch {
            delegate.error(error)
        }
    }

    func rename(_ id: UUID) {
        renaming = id
    }

    func rename(_ id: UUID, to newName: String) async {
        do {
            renaming = nil
            try await dm.rename(id, to: newName)
            try await async_fetch(shouldAnimate: false)
            selection = [id]
        } catch {
            delegate.error(error)
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
            delegate.error(error)
        }
    }

    func itemsDropped(_ items: [Data], into groupId: UUID) {
        Task {
            let ids = items.map {
                let uuidString = String(data: $0, encoding: .utf8)!
                return UUID(uuidString: uuidString)!
            }
            await move(Set(ids), to: groupId)
        }
    }

    func itemProvider(for item: BaseRow) -> NSItemProvider {
        let provider = NSItemProvider()
        provider.register(item.uuidAsData())
        return provider
    }

    func isSingleSelection(_ id: UUID) -> Bool {
        selection.contains(id) && selection.count == 1
    }

    #if os(macOS)

    #else
    func foldersOfSameLevel(for ids: Set<UUID>) -> [(String, UUID?)] {
        let selected =
            items
                .filter { ids.contains($0.id) }
        var names: [UUID: String] = [:]

        for item in items {
            if item.isGroup {
                names[item.id] = item.text
            }
        }
        var folders: [(String, UUID?)] = names
            .map {
                ($0.value, $0.key)
            }
            .sorted { $0.0 < $1.0 }
        folders.append(("Root", nil))
        return folders
    }
    #endif

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
        }
        for item in items {
            if let group = item.group, expanded.contains(item.id) {
                await expand(group, shouldAnimate: shouldAnimate)
            }
        }
    }
}
