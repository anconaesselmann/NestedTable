//  Created by Axel Ancona Esselmann on 1/24/24.
//

import Foundation

public enum DefaultContextMenuItems: String, ContextMenuItems {
    #if !os(macOS)
    case select
    #endif
    case rename, group, removeFromGroup
    case delete
    #if !os(macOS)
    case moveTo
    #endif
}
