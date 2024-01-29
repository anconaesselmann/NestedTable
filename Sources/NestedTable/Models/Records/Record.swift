//  Created by Axel Ancona Esselmann on 1/26/24.
//

import Foundation

public struct Record: Identifiable {
    public var id: UUID
    internal var namespace: UUID?
    public var isGroup: Bool
    public var parent: UUID?
    public var text: String
    public var content: Set<UUID>

    public init(id: UUID, isGroup: Bool, parent: UUID? = nil, text: String, content: Set<UUID>) {
        self.id = id
        self.isGroup = isGroup
        self.parent = parent
        self.text = text
        self.content = content
    }
}


