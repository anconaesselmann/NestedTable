//  Created by Axel Ancona Esselmann on 1/29/24.
//

import Foundation

internal extension Set {
    enum Error: Swift.Error {
        case incompatibleType
    }

    init(_ nsSet: NSSet) throws {
        guard let array = nsSet.allObjects as? [Element] else {
            throw Error.incompatibleType
        }
        self = Set(array)
    }
}
