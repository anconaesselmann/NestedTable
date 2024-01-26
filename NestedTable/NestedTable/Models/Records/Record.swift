//  Created by Axel Ancona Esselmann on 1/26/24.
//

import Foundation

struct Record: Identifiable {
    var id: UUID
    var isGroup: Bool
    var parent: UUID?
    var text: String
    var content: Set<UUID>
}


