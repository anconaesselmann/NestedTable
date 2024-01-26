//  Created by Axel Ancona Esselmann on 1/24/24.
//

import SwiftUI
import UniformTypeIdentifiers

extension BaseRow: Transferable {

    func uuidAsData() -> Data {
        id.asData()
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) { item in
            item.id.asData()
        }
    }
}

