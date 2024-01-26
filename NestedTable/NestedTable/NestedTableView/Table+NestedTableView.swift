//  Created by Axel Ancona Esselmann on 1/25/24.
//

import SwiftUI

extension Table {

    @MainActor
    init<Content>(
        _ vm: NestedTableViewModel<Content>,
        @TableColumnBuilder<Value, KeyPathComparator<BaseRow<Content>>>
        columns: () -> Columns,
        @TableRowBuilder<Value>
        rows: () -> Rows
    )
        where
            Value.Type == BaseRow<Content>.Type
    {
        self.init(
            of: BaseRow<Content>.self,
            selection: Binding(get: {
                vm.selection
            }, set: {
                vm.selection = $0
            }),
            sortOrder: Binding(get: {
                vm.sortOrder
            }, set: {
                vm.sortOrder = $0
            }),
            columns: columns,
            rows: rows
        )
    }

    @MainActor
    func contextMenu<Element, Content>(
        _ vm: NestedTableViewModel<Content>,
        items: [any ContextMenuItems]? = nil,
        @ViewBuilder
        builder: @escaping (NestedTableViewModel<Content>, Element, Set<UUID>) -> some View
    ) -> some View
        where Element: ContextMenuItems
    {
        let copy = self
        return copy.contextMenu(forSelectionType: UUID.self) { ids in
            ItemContextMenu(
                vm,
                ids: ids,
                elements: items ?? DefaultContextMenuItems.allCases,
                contextMenuElementBuilder: { (vm: NestedTableViewModel<Content>, string: String, selected: Set<UUID>) -> AnyView? in
                    guard let element = Element(rawValue: string) else {
                        return nil
                    }
                    let view = builder(vm, element, selected)
                    return AnyView(view)
                }

            )
        } primaryAction: { items in
            vm.primaryAction(items)
        }
        .onAppear {
            vm.fetch()
        }
        .contextMenu {
            ItemContextMenu(
                vm,
                ids: [],
                elements: items ?? DefaultContextMenuItems.allCases,
                contextMenuElementBuilder: { (vm: NestedTableViewModel<Content>, string: String, selected: Set<UUID>) -> AnyView? in
                    guard let element = Element(rawValue: string) else {
                        return nil
                    }
                    let view = builder(vm, element, selected)
                    return AnyView(view)
                }
            )
        }
    }

    @MainActor
    func contextMenu<Element, Content>(
        _ vm: NestedTableViewModel<Content>,
        items: [any ContextMenuItems]? = nil,
        @ViewBuilder
        builder: @escaping (Element, Set<UUID>) -> some View
    ) -> some View
        where Element: ContextMenuItems
    {
        let copy = self
        return copy.contextMenu(forSelectionType: UUID.self) { ids in
            ItemContextMenu(
                vm,
                ids: ids,
                elements: items ?? DefaultContextMenuItems.allCases,
                contextMenuElementBuilder: { (vm: NestedTableViewModel<Content>, string: String, selected: Set<UUID>) -> AnyView? in
                    guard let element = Element(rawValue: string) else {
                        return nil
                    }
                    let view = builder(element, selected)
                    return AnyView(view)
                }

            )
        } primaryAction: { items in
            vm.primaryAction(items)
        }
        .onAppear {
            vm.fetch()
        }
    }
}
