//  Created by Axel Ancona Esselmann on 1/24/24.
//

import SwiftUI

struct ItemContextMenu: View {
    private let vm: NestedTableViewModel
    private let ids: Set<UUID>
    private var elements: [any ContextMenuItems]
    private var contextMenuElementBuilder: ((String, Set<UUID>) -> AnyView?)?

    init(
        _ vm: NestedTableViewModel,
        ids: Set<UUID>,
        elements: [any ContextMenuItems],
        contextMenuElementBuilder: ((String, Set<UUID>) -> AnyView?)?
    ) {
        self.vm = vm
        self.elements = elements
        self.ids = ids
        self.contextMenuElementBuilder = contextMenuElementBuilder
    }

    var body: some View {
        contextMenu(for: ids)
    }

    @MainActor
    @ViewBuilder
    private func contextMenu(for ids: Set<UUID>) -> some View {
        ForEach(elements.map { $0.rawValue}, id: \.self) {
            switch $0 {
            case "rename":
                if ids.count == 1, let id = ids.first {
                    Button("Rename") {
                        vm.rename(id)
                    }
                }
            case "group":
                Button("Group \(ids.count > 1 ? "items" : "item")") {
                    Task {
                        guard let id = await vm.createGroup(with: ids) else {
                            return
                        }
                        vm.rename(id)
                    }
                }
            case "removeFromGroup":
                if ids.count > 0 {
                    if vm.isGrouped(ids) {
                        Button("Remove from group") {
                            Task {
                                await vm.removeFromGroup(ids)
                            }
                        }
                    }
                }
            case "delete":
                if ids.count > 0 {
                    Button("Delete") {
                        Task {
                            await vm.delete(ids)
                        }
                    }
                }
#if !os(macOS)
            case "select":
                if ids.count == 1, let id = ids.first {
                    Button("Select") {
                        vm.selection.insert(id)
                    }
                }
            case "moveTo":
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
                contextMenuElementBuilder?($0, ids)
            }
        }
    }
}
