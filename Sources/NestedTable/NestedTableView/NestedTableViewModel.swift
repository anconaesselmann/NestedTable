//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI
import Combine

@MainActor
public class NestedTableViewModel<Content>: ObservableObject {

    public var items: [BaseRow<Content>] = []

    @MainActor
    @Published
    public var selection = Set<UUID>() {
        didSet {
            if renaming != nil {
                renaming = nil
            }
        }
    }

    public var renaming: UUID?

    @MainActor
    public var sortOrder: [KeyPathComparator<BaseRow<Content>>] = [] {
        didSet {
            Task {
                try await async_fetch(shouldAnimate: false)
                self.objectWillChange.send()
            }
        }
    }

    private var dm: NestedTableDataManager
    private var delegate: NestedTableDelegate
    internal var contextMenuManager: ContextMenuManager

    private var expanded: Set<UUID> = []

    private var bag = Set<AnyCancellable>()

    @Published
    public var isNameFocused: Bool = false

    public init(
        dataManager: NestedTableDataManager,
        delegate: NestedTableDelegate,
        contextMenuManager: ContextMenuManager? = nil
    ) {
        self.dm = dataManager
        self.delegate = delegate
        self.contextMenuManager = contextMenuManager ?? DefaultContextMenuManager()

        self.contextMenuManager.isNameFocused.sink { [weak self] newValue in
            self?.isNameFocused = newValue
        }.store(in: &bag)
    }

    public func fetch() {
        Task {
            do {
                try await async_fetch()
            } catch {
                delegate.error(error)
            }
        }
    }

    @MainActor
    public func refresh() async {
        do {
            try await async_fetch(shouldAnimate: false)
            self.objectWillChange.send()
        } catch {
            delegate.error(error)
        }
    }

    public func expand(_ groupId: UUID, shouldAnimate: Bool = true) async {
        do {
            guard let index = items.firstIndex(where: { $0.id == groupId }) else {
                return
            }
            let item = items[index]
            guard let group = item.group else {
                return
            }
            let indent = items[index].indent
            let children = try await dm.fetch(ids: group.contents)
                .map { BaseRow<Content>($0, parent: group.id, indent: indent + 1) }
                .sorted(using: sortOrder) // TODO: See if I can pass this into the DM
            if shouldAnimate {
                withAnimation {
                    items.insert(contentsOf: children, at: index + 1)
                    self.objectWillChange.send()
                }
            } else {
                items.insert(contentsOf: children, at: index + 1)
            }
            var needsToUpdate = false
            for child in children {
                if let childGroup = child.group {
                    if expanded.contains(childGroup.id) {
                        await expand(childGroup.id, shouldAnimate: false)
                        needsToUpdate = true
                    }
                }
            }
            if shouldAnimate && needsToUpdate {
                self.objectWillChange.send()
            }
            expanded.insert(groupId)
        } catch {
            delegate.error(error)
        }
    }

    public func contract(_ groupId: UUID, shouldAnimate: Bool = true, clearState: Bool = true) {
        let remove = items.filter { $0.parent == groupId }
        for item in remove {
            if let childGroup = item.group {
                contract(childGroup.id, clearState: false)
            }
        }
        if shouldAnimate {
            withAnimation {
                items.removeAll(where: { $0.parent == groupId })
                self.objectWillChange.send()
            }
        } else {
            items.removeAll(where: { $0.parent == groupId })
        }
        if clearState {
            expanded.remove(groupId)
        }
    }

    public func toggle(_ groupId: UUID) async {
        let current = expanded.contains(groupId)
        let new = !current
        if new {
            await expand(groupId)
        } else {
            contract(groupId)
        }
    }

    public func isExpanded(_ groupId: UUID) -> Bool {
        expanded.contains(groupId)
    }

    public func primaryAction(_ ids: Set<UUID>) {
        guard let id = ids.first, ids.count == 1 else {
            return
        }
        guard let item = items.first(where: { $0.id == id }) else {
            return
        }
        if let group = item.group {
            Task {
                await toggle(group.id)
            }
        } else {
            delegate.performPrimaryAction(for: id)
        }
    }

    public func createGroup(with ids: Set<UUID>) async -> UUID? {
        do {
            let items = self.items.filter { ids.contains($0.id) }
                .sorted { $0.indent < $1.indent }
            let parentId = items.first?.parent
            let groupId = try await dm.createGroup(with: ids, named: "New group", parent: parentId)
            try await async_fetch(shouldAnimate: false)
            if !ids.isEmpty {
                expanded.insert(groupId)
            }
            selection = [groupId]
            await expand(groupId, shouldAnimate: false)
            return groupId
        } catch {
            delegate.error(error)
            return nil
        }
    }

    public func isGrouped(_ ids: Set<UUID>) -> Bool {
        items
            .filter { ids.contains($0.id) }
            .map { $0.parent != nil }
            .reduce(into: true) {
                if !$1 {
                    $0 = false
                }
            }
    }

    public func removeFromGroup(_ ids: Set<UUID>) async {
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

    public func move(_ ids: Set<UUID>, to newParent: UUID?) async {
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

    public func rename(_ id: UUID) {
        renaming = id
        contextMenuManager.focusName(true)
    }

    public func rename(_ id: UUID, to newName: String) async {
        do {
            renaming = nil
            try await dm.rename(id, to: newName)
            try await async_fetch(shouldAnimate: false)
            selection = [id]
        } catch {
            delegate.error(error)
        }
    }

    public func delete(_ ids: Set<UUID>) async {
        do {
            let deleted = try await dm.delete(ids)
            withAnimation {
                items.removeAll { deleted.contains($0.id) }
                if !selection.isEmpty {
                    selection = []
                } else {
                    self.objectWillChange.send()
                }
            }
        } catch {
            delegate.error(error)
        }
    }

    public func itemsDropped(_ items: [Data], into groupId: UUID) {
        Task {
            let ids = items.map {
                let uuidString = String(data: $0, encoding: .utf8)!
                return UUID(uuidString: uuidString)!
            }
            await move(Set(ids), to: groupId)
        }
    }

    public func itemProvider(for item: BaseRow<Content>) -> NSItemProvider {
        let provider = NSItemProvider()
        provider.register(item.uuidAsData())
        return provider
    }

    public func isSingleSelection(_ id: UUID) -> Bool {
        selection.contains(id) && selection.count == 1
    }

    #if !os(macOS)
    public func foldersOfSameLevel(for ids: Set<UUID>) -> [(String, UUID?)] {
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
            .map { BaseRow<Content>($0) }
            .sorted(using: sortOrder) // TODO: See if I can pass this into the DM
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
                await expand(group.id, shouldAnimate: shouldAnimate)
            }
        }
    }
}
