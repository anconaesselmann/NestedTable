//  Created by Axel Ancona Esselmann on 1/26/24.
//

import SwiftUI

class MockContentStore {

    enum Error: Swift.Error {
        case missingContentId
    }

    private var items: [UUID: MockContent] = [:]

    func insert(_ content: MockContent) {
        self.items[content.id] = content
    }
}

extension MockContentStore: ContentStore {
    // MARK: - Required implementations
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
                let content = items[contentId] ?? MockContent(test: contentId.uuidString)
                return Item<MockContent>(
                    id: record.id,
                    parent: record.parent,
                    text: record.text,
                    image: Image(systemName: "music.note.list"),
                    content: content
                )
            }
        }
    }

    // MARK: - Optional implementation
    func createGroup(_ groupRecord: Record) async throws {
        print("Content store is creating group")
    }
}
