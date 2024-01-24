//  Created by Axel Ancona Esselmann on 1/23/24.
//

import Foundation

struct BaseRow: Identifiable, Codable {

    init(from decoder: Decoder) throws {
        fatalError()
    }

    func encode(to encoder: Encoder) throws {
        fatalError()
    }

    var parent: UUID?

    var id: UUID {
        item.id
    }

    var text: String {
        item.text
    }

    var folder: Folder? {
        get {
            item as? Folder
        }
        set {
            guard let newFolder = newValue else {
                return
            }
            item = newFolder
        }
    }

    var isFolder: Bool {
        type(of: item) == Folder.self
    }

    var item: any TableRowItem

    var indent: Int

    init(_ item: any TableRowItem, parent: UUID? = nil, indent: Int = 0) {
        self.item = item
        self.indent = indent
        self.parent = parent
    }
}
