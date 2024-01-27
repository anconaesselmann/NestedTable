//  Created by Axel Ancona Esselmann on 1/25/24.
//

import Foundation

public extension KeyPathComparator {
    static func nameColumn<Content>() -> KeyPathComparator<BaseRow<Content>>
        where Compared == BaseRow<Content>
    {
        KeyPathComparator(\BaseRow.item.text, comparator: Comparator<String>())
    }

    static func content<Content, T>(_ keyPath: KeyPath<BaseRow<Content>, T?>) -> KeyPathComparator<BaseRow<Content>>
        where 
            Compared == BaseRow<Content>,
            T: Comparable
    {
        KeyPathComparator(keyPath, comparator: Comparator<T>())
    }

    // TODO: Create implementation for OptionalComparator
}
