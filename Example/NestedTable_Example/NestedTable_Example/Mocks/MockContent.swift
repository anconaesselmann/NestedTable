//  Created by Axel Ancona Esselmann on 1/26/24.
//

import Foundation

struct MockContent {
    let id: UUID
    let test: String

    init(id: UUID = UUID(), test: String) {
        self.id = id
        self.test = test
    }
}
