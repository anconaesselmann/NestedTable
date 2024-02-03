//  Created by Axel Ancona Esselmann on 1/25/24.
//

import SwiftUI

public struct CustomNameColumn<Content, Icon, Label>: View
    where 
        Icon: View,
        Label: View
{

    public let item: BaseRow<Content>

    @StateObject
    public var vm: NestedTableViewModel<Content>

    @FocusState
    private var isNameFocused:Bool

    @State
    private var newName: String = ""

    public init(
        item: BaseRow<Content>,
        vm: NestedTableViewModel<Content>,
        @ViewBuilder
        icon: @escaping (BaseRow<Content>) -> Icon,
        @ViewBuilder
        label: @escaping (BaseRow<Content>) -> Label
    )
        where Icon: View
    {
        self.item = item
        self._vm = StateObject(wrappedValue: vm)
        self.iconBuilder = icon
        self.labelBuilder = label
        self.isNameFocused = isNameFocused
        self.newName = newName
    }

    var iconBuilder: (BaseRow<Content>) -> Icon
    var labelBuilder: (BaseRow<Content>) -> Label

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
            iconBuilder(item)
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
                labelBuilder(item)
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
