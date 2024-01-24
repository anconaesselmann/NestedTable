//  Created by Axel Ancona Esselmann on 1/24/24.
//

import Foundation

enum DefaultContextMenuItems: String, ContextMenuItems {
    #if !os(macOS)
    case select
    #endif
    case rename, group
    #if !os(macOS)
    case removeFromGroup
    #endif
    case delete
    #if !os(macOS)
    case moveTo
    #endif
}
