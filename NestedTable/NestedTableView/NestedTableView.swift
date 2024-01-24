//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

struct NestedTableView: View {
    @StateObject
    var vm = NestedTableViewModel()

    @FocusState
    var isNameFocused:Bool

    var body: some View {
        VStack {
            Table(of: BaseRow.self, selection: $vm.selection) {
                TableColumn("text") { item in
                    HStack(spacing: 0) {
                        if let folder = item.folder {
                            HStack {
                                if vm.isExpanded(folder) {
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
                                    await vm.toggle(folder)
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
                                    isNameFocused = false
                                    Task {
                                        await vm.rename(item.id, to: vm.newName)
                                    }
                                }
                                .focused($isNameFocused)
                                .textFieldStyle(.squareBorder)
                                .padding(.leading, 8)
                        } else {
                            Text(item.text)
                                .padding(.leading, 8)
                        }
                    }
                    .padding(.leading, CGFloat(item.indent * 32))
                    .id(item.id)
                }
            } rows: {
                ForEach(vm.items) { item in
                    if item.isFolder {
                        TableRow(item)
                            .itemProvider {
                                let provider = NSItemProvider()
                                provider.register(item.generateData())
                                return provider
                            }
                            .dropDestination(for: Data.self) { items in
                                Task {
                                    let ids = items.map {
                                        let uuidString = String(data: $0, encoding: .utf8)!
                                        return UUID(uuidString: uuidString)!
                                    }
                                    await vm.move(Set(ids), to: item.id)
                                }
                            }
                    } else {
                        TableRow(item)
                            .itemProvider {
                                let provider = NSItemProvider()
                                provider.register(item.generateData())
                                return provider
                            }
                    }

                }
            }
            .contextMenu(forSelectionType: UUID.self) { ids in
                if ids.count == 1, let id = ids.first {
                    Button("Rename") {
                        isNameFocused = true
                        vm.rename(id)
                    }
                }
                Button("Group") {
                    Task {
                        await vm.createFolder(with: ids)
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
        .onAppear {
            vm.fetch()
        }
    }
}

import UniformTypeIdentifiers

extension BaseRow: Transferable {

    func generateData() -> Data {
        id.uuidString.data(using: .utf8)!
    }
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) { item in
            item.generateData()
        }
    }
}
