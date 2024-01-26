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

typealias MockItem = Item<MockContent>

import SwiftUI
extension MockItem {
    init(id: UUID, text: String, content: MockContent) {
        self.init(id: id, text: text, image: Image(systemName: "music.note.list"), content: content)
    }
}

extension Group {
    init(id: UUID, parent: UUID?, text: String, contents: Set<UUID>) {
        self.init(id: id, parent: parent, text: text, image: Image(systemName: "folder.fill"), contents: contents)
    }
}

class MockContentStore: ContentStore {

    enum Error: Swift.Error {
        case missingContentId
    }
    
    func rowItems(for records: [Record]) async throws -> [any TableRowItem] {
        try records.map { record in
            if record.isGroup {
                return Group(
                    id: record.id,
                    parent: record.parent,
                    text: record.text,
                    image: Image(systemName: "folder.fill"),
                    contents: record.content
                )
            } else {
                guard let contentId = record.content.first else {
                    throw Error.missingContentId
                }
                return Item<MockContent>(
                    id: record.id,
                    parent: record.parent,
                    text: record.text,
                    image: Image(systemName: "music.note.list"),
                    content: MockContent(test: contentId.uuidString)
                )
            }
        }
    }
}
