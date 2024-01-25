//  Created by Axel Ancona Esselmann on 1/23/24.
//

import Foundation

struct Item: Identifiable, TableRowItem {
    var id: UUID
    var parent: UUID?
    var text: String
}
