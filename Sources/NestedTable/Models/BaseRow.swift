//  Created by Axel Ancona Esselmann on 1/23/24.
//

import Foundation

public struct BaseRow<Content>: Identifiable, Codable {

    public init(from decoder: Decoder) throws {
        fatalError()
    }

    public func encode(to encoder: Encoder) throws {
        fatalError()
    }

    public var parent: UUID?

    public var id: UUID {
        item.id
    }

    public var text: String {
        item.text
    }

    public var group: Group? {
        get {
            item as? Group
        }
        set {
            guard let newFolder = newValue else {
                return
            }
            item = newFolder
        }
    }

    public var content: Content? {
        (item as? Item<Content>)?.content
    }

    public var isGroup: Bool {
        type(of: item) == Group.self
    }

    public var item: any TableRowItem

    public var indent: Int

    public init(_ item: any TableRowItem, parent: UUID? = nil, indent: Int = 0) {
        self.item = item
        self.indent = indent
        self.parent = parent
    }
}
