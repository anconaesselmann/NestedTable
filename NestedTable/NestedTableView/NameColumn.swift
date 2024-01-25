//  Created by Axel Ancona Esselmann on 1/25/24.
//

import SwiftUI

struct NameColumn: View {

    let item: BaseRow

    @StateObject
    var vm: NestedTableViewModel

    @FocusState
    private var isNameFocused:Bool

    @State
    private var newName: String = ""

    var body: some View {
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
                TextField("", text: $newName)
                    .onSubmit {
                        Task {
                            await vm.rename(item.id, to: newName)
                        }
                    }
                    .focused($isNameFocused)
                    .defaultTextFieldStyle()
                    .padding(.leading, 6)
            } else {
                Text(item.text)
                    .padding(.leading, 10)
                    .padding(.vertical, 2.5)
            }
        }
        #if os(macOS)
        .padding(.leading, CGFloat(item.indent * 32))
        #endif
        .id(item.id)
        .onChange(of: vm.isNameFocused) {
            isNameFocused = vm.isNameFocused
        }
        .onChange(of: isNameFocused) {
            vm.isNameFocused = isNameFocused
        }
        .onChange(of: vm.renaming) {
            newName = item.text
        }
    }
}
