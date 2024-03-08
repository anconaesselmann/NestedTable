//  Created by Axel Ancona Esselmann on 1/24/24.
//

import SwiftUI
import UniformTypeIdentifiers

extension BaseRow: Transferable {
    var rowUrl: URL {
        URL(fileURLWithPath: "nested_table_base_row=" + id.uuidString.lowercased())
    }
    
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .url)
    }
}

extension UUID {
    init?(nestedTableBaseRowUrl url: URL) {
        let components = url.lastPathComponent
            .split(separator: "=")
            .map { String($0) }
        guard
            let first = components.first,
            first == "nested_table_base_row",
            let last = components.last,
            let id = UUID(uuidString: last)
        else {
            return nil
        }
        self = id
    }
}
