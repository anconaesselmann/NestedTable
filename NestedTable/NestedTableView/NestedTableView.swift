//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

struct NestedTableView: View {

    init(dataManager: NestedTableDataManager, delegate: NestedTableDelegate) {
        let vm = NestedTableViewModel(
            dataManager: dataManager,
            delegate: delegate
        )
        _vm = StateObject(wrappedValue: vm)
    }

    init(manager: (NestedTableDataManager & NestedTableDelegate)) {
        self.init(dataManager: manager, delegate: manager)
    }

    @StateObject
    var vm: NestedTableViewModel

    @FocusState
    var isNameFocused:Bool

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
//                                .if(vm.isSingleSelection(item.id)) { view in
//                                    view
//                                        .onTapGesture(count: 1) {
//                                            vm.rename(item.id)
//                                            isNameFocused = true
//                                        }
//                                }
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
                contextMenu(for: $0)
            } primaryAction: { items in
                vm.primaryAction(items)
            }
        }
        .onAppear {
            vm.fetch()
        }
    }

    @ViewBuilder
    func contextMenu(for ids: Set<UUID>) -> some View {
        if ids.count == 1, let id = ids.first {
            Button("Rename") {
                vm.rename(id)
                isNameFocused = true
            }
        }
        Button("Group \(ids.count > 1 ? "items" : "item")") {
            Task {
                guard let id = await vm.createGroup(with: ids) else {
                    return
                }
                vm.rename(id)
                isNameFocused = true
            }
        }
        if ids.count > 0 {
            if vm.isGrouped(ids) {
                Button("Remove from group") {
                    Task {
                        await vm.removeFromGroup(ids)
                    }
                }
            }
            Button("Delete") {
                Task {
                    await vm.delete(ids)
                }
            }
        }
    }
}
