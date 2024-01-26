//  Created by Axel Ancona Esselmann on 1/25/24.
//

import Foundation

struct Comparators<Content> {
    static var text: KeyPathComparator<BaseRow<Content>> {
        KeyPathComparator(\BaseRow.item.text, comparator: Comparator<String>())
    }
}
