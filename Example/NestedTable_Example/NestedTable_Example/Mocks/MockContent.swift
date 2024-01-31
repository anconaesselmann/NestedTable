//  Created by Axel Ancona Esselmann on 1/26/24.
//

import Foundation

struct SomeCustomType {
    let double: Double
}

struct MockContent {
    let id: UUID
    let string: String
    let optionalString: String?
    let int: Int
    let optionalInt: Int?
    let custom: SomeCustomType

    init(id: UUID = UUID(), string: String, optionalString: String?) {
        self.id = id
        self.string = string
        self.optionalString = optionalString
        self.int = Int.random(in: 0...10)
        self.optionalInt = Bool.random() ? Int.random(in: 11...20) : nil
        self.custom = .init(double: Double.random(in: 0..<1))
    }
}
