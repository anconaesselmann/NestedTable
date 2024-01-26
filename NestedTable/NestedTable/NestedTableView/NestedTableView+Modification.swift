//  Created by Axel Ancona Esselmann on 1/24/24.
//

import SwiftUI

extension NestedTableView {
    func contextMenu<Element>(items: [any ContextMenuItems]? = nil, @ViewBuilder builder: @escaping (NestedTableViewModel<Content>, Element, Set<UUID>) -> some View) -> some View
        where Element: ContextMenuItems
    {
        var copy = self
        if let elements = items {
            copy.contextMenuItems = elements
        }
        copy.contextMenuElementBuilder = { (vm: NestedTableViewModel<Content>, string: String, selected: Set<UUID>) -> AnyView? in
            guard let element = Element(rawValue: string) else {
                return nil
            }
            let view = builder(vm, element, selected)
            return AnyView(view)
        }
        return copy
    }

    func contextMenu<Element>(items: [any ContextMenuItems]? = nil, @ViewBuilder builder: @escaping (Element, Set<UUID>) -> some View) -> some View
        where Element: ContextMenuItems
    {
        var copy = self
        if let elements = items {
            copy.contextMenuItems = elements
        }
        copy.contextMenuElementBuilder = { (vm: NestedTableViewModel<Content>, string: String, selected: Set<UUID>) -> AnyView? in
            guard let element = Element(rawValue: string) else {
                return nil
            }
            let view = builder(element, selected)
            return AnyView(view)
        }
        return copy
    }
}
