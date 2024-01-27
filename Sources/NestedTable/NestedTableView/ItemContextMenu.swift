//  Created by Axel Ancona Esselmann on 1/24/24.
//

import SwiftUI

public struct ItemContextMenu<Content>: View {
    private let vm: NestedTableViewModel<Content>
    private let ids: Set<UUID>
    private var elements: [any ContextMenuItems]
    private var contextMenuElementBuilder: ((NestedTableViewModel<Content>, String, Set<UUID>) -> AnyView?)?

    public init(
        _ vm: NestedTableViewModel<Content>,
        ids: Set<UUID>,
        elements: [any ContextMenuItems],
        contextMenuElementBuilder: ((NestedTableViewModel<Content>, String, Set<UUID>) -> AnyView?)?
    ) {
        self.vm = vm
        self.elements = elements
        self.ids = ids
        self.contextMenuElementBuilder = contextMenuElementBuilder
    }

    public var body: some View {
        contextMenu(for: ids)
    }

    @MainActor
    @ViewBuilder
    private func contextMenu(for ids: Set<UUID>) -> some View {
        ForEach(elements.map { $0.rawValue}, id: \.self) {
            switch $0 {
            case DefaultContextMenuItems.rename.rawValue:
                if ids.count == 1, let id = ids.first {
                    Button("Rename") {
                        vm.rename(id)
                    }
                }
            case DefaultContextMenuItems.group.rawValue:
                let text: String = {
                    switch ids.count {
                    case 0: return "Create group"
                    case 1: return "Group item"
                    default: return "Group items"
                    }
                }()
                Button(text) {
                    Task {
                        guard let id = await vm.createGroup(with: ids) else {
                            return
                        }
                        vm.rename(id)
                    }
                }
            case DefaultContextMenuItems.removeFromGroup.rawValue:
                if ids.count > 0 {
                    if vm.isGrouped(ids) {
                        Button("Remove from group") {
                            Task {
                                await vm.removeFromGroup(ids)
                            }
                        }
                    }
                }
            case DefaultContextMenuItems.delete.rawValue:
                if ids.count > 0 {
                    Button("Delete") {
                        Task {
                            await vm.delete(ids)
                        }
                    }
                }
#if !os(macOS)
            case DefaultContextMenuItems.select.rawValue:
                if ids.count == 1, let id = ids.first {
                    Button("Select") {
                        vm.selection.insert(id)
                    }
                }
            case DefaultContextMenuItems.moveTo.rawValue:
                if ids.count > 0 {
                    let folders = vm.foldersOfSameLevel(for: ids)
                    Menu("Move to") {
                        ForEach(folders, id: \.1) { name, id in
                            Button(name) {
                                Task {
                                    await vm.move(ids, to: id)
                                }
                            }
                        }
                    }
                }
#endif
            default:
                contextMenuElementBuilder?(vm, $0, ids)
            }
        }
    }
}
