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

    static var a: Self {
        MockContent(test: "a")
    }
    static var b: Self {
        MockContent(test: "b")
    }
    static var c: Self {
        MockContent(test: "c")
    }
    static var shuffled: Self {
        [Self.a, Self.b, Self.c].shuffled()[0]
    }
}
