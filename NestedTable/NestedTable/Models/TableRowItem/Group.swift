//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

struct Group: Identifiable, TableRowItem {
    var id: UUID
    var parent: UUID?
    var text: String
    var image: Image?
    var contents: Set<UUID> = []
}
