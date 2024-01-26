//  Created by Axel Ancona Esselmann on 1/26/24.
//

import Foundation

struct MockContent {
    let test: String

    init(_ test: String) {
        self.test = test
    }

    static var a: Self {
        MockContent("a")
    }
    static var b: Self {
        MockContent("b")
    }
    static var c: Self {
        MockContent("c")
    }
}

typealias MockItem = Item<MockContent>

import SwiftUI
extension MockItem {
    init(id: UUID, text: String, content: MockContent) {
        self.init(id: id, text: text, image: Image(systemName: "music.note.list"), content: content)
    }
}

extension Group {
    init(id: UUID, text: String, contents: Set<UUID>) {
        self.init(id: id, text: text, image: Image(systemName: "folder.fill"), contents: contents)
    }
}
