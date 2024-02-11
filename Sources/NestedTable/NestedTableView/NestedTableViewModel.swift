//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI
import Combine

@MainActor
public class NestedTableViewModel<Content>: ObservableObject {

    @MainActor
    public var items: [BaseRow<Content>] = []

    @MainActor
    @Published
    public var selection = Set<UUID>() {
        didSet {
            if renaming != nil {
                renaming = nil
            }
            delegate.selection(selection)
        }
    }

    public var renaming: UUID?

    @MainActor
    public var sortOrder: [KeyPathComparator<BaseRow<Content>>] {
        didSet {
            Task {
                try await async_fetch(shouldAnimate: false)
                self.objectWillChange.send()
            }
        }
    }

    private var dm: NestedTableDataManager
    public private(set) var delegate: NestedTableDelegate
    internal var contextMenuManager: ContextMenuManager

    private var expanded: Set<UUID> = []

    private var bag = Set<AnyCancellable>()

    @Published
    public var isNameFocused: Bool = false

    public init(
        dataManager: NestedTableDataManager,
        delegate: NestedTableDelegate,
        contextMenuManager: ContextMenuManager? = nil,
        sortOrder: [KeyPathComparator<BaseRow<Content>>] = []
    ) {
        self.sortOrder = sortOrder
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

            // TODO: Could intermittently crash, verify.
            var newIndex = index + 1
            if newIndex > items.count {
                newIndex = items.count
            }
            if shouldAnimate {
                withAnimation {
                    items.insert(contentsOf: children, at: index + 1)
                    self.objectWillChange.send()
                }
            } else {
                items.insert(contentsOf: children, at: newIndex)
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
        let visibleSelectedIds = items
            .filter { selection.contains($0.id) }
            .map { $0.id }
        selection = Set(visibleSelectedIds)
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
        // TODO: O(N) make O(1)
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

    public func createGroup(with ids: Set<UUID>, named name: String? = nil) async -> UUID? {
        do {
            let items = self.items.filter { ids.contains($0.id) }
                .sorted { $0.indent < $1.indent }
            let parentId = items.first?.parent
            let groupId = try await dm.createGroup(with: ids, named: name ?? "New group", parent: parentId)
            try await async_fetch(shouldAnimate: false)
            if !ids.isEmpty {
                expanded.insert(groupId)
            }
            await expand(groupId, shouldAnimate: false)
            selection = [groupId]
            focusAndRename(groupId)
            return groupId
        } catch {
            delegate.error(error)
            return nil
        }
    }

    public func expand(_ ids: Set<UUID>, shouldAnimate: Bool = true) async {
        do {
            let groupIds = try await dm
                .fetch(ids: ids)
                .compactMap { ($0 as? Group)?.id }
            for id in groupIds {
                await expand(id, shouldAnimate: shouldAnimate)
            }
        } catch {
            delegate.error(error)
        }
    }

    public func contract(_ ids: Set<UUID>, shouldAnimate: Bool = true) async {
        do {
            let groupIds = try await dm
                .fetch(ids: ids)
                .compactMap { ($0 as? Group)?.id }
            for id in groupIds {
                await contract(id, shouldAnimate: shouldAnimate)
            }
        } catch {
            delegate.error(error)
        }
    }

    public func leftArrow(_ ids: Set<UUID>, shouldAnimate: Bool = true) async {
        guard !ids.isEmpty else {
            return
        }
        if ids.count == 1 {
            do {
                let elements = try await dm
                    .fetch(ids: ids)
                if let group = elements.compactMap({ ($0 as? Group)?.id }).first {
                    await contract(ids, shouldAnimate: shouldAnimate)
                } else if let parentId = elements.compactMap({ ($0 as? Item<Content>)?.parent }).first {
                    selection = [parentId]
                    focus.send(parentId)
                } else {
                    assertionFailure()
                }
            } catch {
                delegate.error(error)
            }
        } else {
            await contract(ids, shouldAnimate: shouldAnimate)
        }
    }

    private func focusAndRename(_ id: UUID) {
        Task {
            try await Task.sleep(nanoseconds: 2_000)
            await MainActor.run {
                focus.send(id)
            }
            try await Task.sleep(nanoseconds: 1_000)
            await MainActor.run {
                rename(id)
            }
        }
    }

    private func focusAndSelect(_ id: UUID) {
        Task {
            try await Task.sleep(nanoseconds: 2_000)
            await MainActor.run {
                focus.send(id)
                selection = [id]
            }
        }
    }

    public var focus = PassthroughSubject<UUID, Never>()

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
            try await dm.move(itemsWithIds: ids, toGroupWithId: newParent)
            try await async_fetch(shouldAnimate: false)
            selectIfVisible(ids, default: newParent)
        } catch {
            delegate.error(error)
        }
    }

    private func selectIfVisible(_ ids: Set<UUID>, default fallback: UUID?) {
        let visible = Set(
            items
                .filter { ids.contains($0.id) }
                .map { $0.id }
            )
        if visible.isEmpty, let fallback = fallback {
            selection = [fallback]
        } else {
            selection = visible
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
            focusAndSelect(id)
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

    public func fetchRowsSorted(ids: Set<UUID>) async throws -> [BaseRow<Content>] {
        return try await dm
            .fetch(ids: ids)
            .map { BaseRow<Content>($0) }
            .sorted(using: sortOrder)
    }

    public func isGroup(_ id: UUID) -> Bool {
        // TODO: Make O(1)
        items.first(where: { $0.id == id})?.isGroup ?? false
    }

    public func fetchContentIds(forGroup id: UUID) async -> Set<UUID>? {
        do {
            guard let group = try await dm.fetch(ids: [id]).first as? Group else {
                throw NestedTableDataManagerError.missingElement
            }
            return group.contents
        } catch {
            delegate.error(error)
            return nil
        }
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
