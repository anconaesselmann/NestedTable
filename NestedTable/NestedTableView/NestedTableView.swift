//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

struct NestedTableView: View {

    init(
        dataManager: NestedTableDataManager,
        delegate: NestedTableDelegate,
        contextMenuManager: ContextMenuManager? = nil
    ) {
        let vm = NestedTableViewModel(
            dataManager: dataManager,
            delegate: delegate, 
            contextMenuManager: contextMenuManager ?? DefaultContextMenuManager()
        )
        _vm = StateObject(wrappedValue: vm)
    }

    init(manager: (NestedTableDataManager & NestedTableDelegate & ContextMenuManager)) {
        self.init(
            dataManager: manager,
            delegate: manager,
            contextMenuManager: manager
        )
    }

    init(
        manager: (NestedTableDataManager & NestedTableDelegate),
        contextMenuManager: ContextMenuManager? = nil
    ) {
        self.init(
            dataManager: manager,
            delegate: manager,
            contextMenuManager: contextMenuManager
        )
    }

    @StateObject
    var vm: NestedTableViewModel

    @FocusState
    var isNameFocused:Bool

    private var contextMenuElementBuilder: ((String, Set<UUID>) -> AnyView?)?

    private var elements: [any ContextMenuItems] = DefaultContextMenuItems.allCases

    func contextMenuItem<Element>(elements: [any ContextMenuItems]? = nil, @ViewBuilder builder: @escaping (Element, Set<UUID>) -> some View) -> some View
        where Element: ContextMenuItems
    {
        var copy = self
        if let elements = elements {
            copy.elements = elements
        }
        copy.contextMenuElementBuilder = { (string: String, selected: Set<UUID>) -> AnyView? in
            guard let element = Element(rawValue: string) else {
                return nil
            }
            let view = builder(element, selected)
            return AnyView(view)
        }
        return copy
    }

    var body: some View {
        VStack {
            Table(of: BaseRow.self, selection: $vm.selection) {
                TableColumn("text") { item in
                    HStack(spacing: 0) {
                        if let group = item.group {
                            HStack {
                                if vm.isExpanded(group) {
                                    Image(systemName: "chevron.down")
                                } else {
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .frame(width: 25)
                            .frame(maxHeight: .infinity)
                            .containerShape(Rectangle())
                            .onTapGesture {
                                Task {
                                    await vm.toggle(group)
                                }
                            }
                            Image(systemName: "folder.fill")
                        } else {
                            Spacer()
                                .frame(width: 25)
                            Image(systemName: "music.note.list")
                        }
                        if vm.renaming == item.id {
                            TextField("", text: $vm.newName)
                                .onSubmit {
                                    Task {
                                        await vm.rename(item.id, to: vm.newName)
                                    }
                                }
                                .focused($isNameFocused)
                            #if os(macOS)
                                .textFieldStyle(.squareBorder)
                            #else
                                .textFieldStyle(.roundedBorder)
                            #endif
                                .padding(.leading, 6)
                        } else {
                            Text(item.text)
                                .padding(.leading, 10)
                                .padding(.vertical, 2.5)
                        }
                    }
                    .padding(.leading, CGFloat(item.indent * 32))
                    .id(item.id)
                }
            } rows: {
                ForEach(vm.items) { item in
                    if item.isGroup {
                        TableRow(item)
                            .itemProvider {
                                vm.itemProvider(for: item)
                            }
                            .dropDestination(for: Data.self) {
                                vm.itemsDropped($0, into: item.id)
                            }
                    } else {
                        TableRow(item)
                            .itemProvider {
                                vm.itemProvider(for: item)
                            }
                    }
                }
            }
            .contextMenu(forSelectionType: UUID.self) {
                ItemContextMenu(
                    vm, 
                    ids: $0, 
                    elements: elements,
                    contextMenuElementBuilder: contextMenuElementBuilder
                )
            } primaryAction: { items in
                vm.primaryAction(items)
            }
        }
        .onAppear {
            vm.fetch()
        }
        .onChange(of: vm.isNameFocused) {
            isNameFocused = vm.isNameFocused
        }
        .onChange(of: isNameFocused) {
            vm.isNameFocused = isNameFocused
        }
    }
}
