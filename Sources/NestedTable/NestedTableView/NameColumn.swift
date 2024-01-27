//  Created by Axel Ancona Esselmann on 1/25/24.
//

import SwiftUI

public struct NameColumn<Content>: View {

    public let item: BaseRow<Content>

    @StateObject
    public var vm: NestedTableViewModel<Content>

    @FocusState
    private var isNameFocused:Bool

    @State
    private var newName: String = ""

    public init(item: BaseRow<Content>, vm: NestedTableViewModel<Content>) {
        self.item = item
        self._vm = StateObject(wrappedValue: vm)
        self.isNameFocused = isNameFocused
        self.newName = newName
    }

    public var body: some View {
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
            HStack {
                if let groupId = item.group?.id {
                    let imageName = vm.isExpanded(groupId) ? "chevron.down" : "chevron.right"
                    Image(systemName: imageName)
                        .onTapGesture(padding: 8) {
                            Task { await vm.toggle(groupId) }
                        }
                }
            }
            .frame(width: 25)
            // TODO: Decide what to de when no image is present.
            // Current state looks awkward when elements with and without are
            // present in the same level
            HStack {
                if let image = item.item.image {
                    image
                } else {
                    Spacer()
                }
            }.frame(width: 12)
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
