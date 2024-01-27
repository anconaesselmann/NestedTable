//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

public struct Group: Identifiable, TableRowItem {
    public var id: UUID
    public var parent: UUID?
    public var text: String
    public var image: Image?
    public var contents: Set<UUID> = []

    public init(id: UUID, parent: UUID? = nil, text: String, image: Image? = nil, contents: Set<UUID>) {
        self.id = id
        self.parent = parent
        self.text = text
        self.image = image
        self.contents = contents
    }
}
