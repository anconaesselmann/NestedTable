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

    @StateObject
    private var vm: NestedTableViewModel

    @FocusState
    private var isNameFocused:Bool

    internal var contextMenuElementBuilder: ((String, Set<UUID>) -> AnyView?)?
    internal var contextMenuItems: [any ContextMenuItems] = DefaultContextMenuItems.allCases

    var body: some View {
        VStack {
            Table(of: BaseRow.self, selection: $vm.selection) {
                TableColumn("Name") { item in
                    nameColumnContent(item)
                }
            } rows: {
                ForEach(vm.items) { item in
                    #if os(macOS)
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
                    #else
                    TableRow(item)
                    #endif
                }
            }
            .contextMenu(forSelectionType: UUID.self) {
                ItemContextMenu(
                    vm, 
                    ids: $0, 
                    elements: contextMenuItems,
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

    @ViewBuilder
    private func nameColumnContent(_ item: BaseRow) -> some View {
        HStack(spacing: 0) {
            #if !os(macOS)
            ForEach(0..<item.indent, id: \.self) { _ in
                Divider()
                    .frame(width: 2)
                    .overlay(.secondary)
                    .padding(.horizontal, 2)
                    .ignoresSafeArea()
            }
            #endif
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
        #if os(macOS)
        .padding(.leading, CGFloat(item.indent * 32))
        #else

        #endif
        .id(item.id)
    }
}
