//  Created by Axel Ancona Esselmann on 1/24/24.
//

import Foundation

class MockNestedTableManager: NestedTableDelegate {
    func performPrimaryAction(for id: UUID) {
        print("Primary action for \(id.uuidString)")
    }

    func error(_ error: Error) {
        print(error.localizedDescription)
    }
}
