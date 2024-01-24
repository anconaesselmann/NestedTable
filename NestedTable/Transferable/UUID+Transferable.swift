//  Created by Axel Ancona Esselmann on 1/24/24.
//

import SwiftUI
import UniformTypeIdentifiers

extension UUID: Transferable {
    func asData() -> Data {
        uuidString.data(using: .utf8)!
    }

    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) { item in
            item.asData()
        }
    }
}
