//  Created by Axel Ancona Esselmann on 1/31/24.
//

import Foundation
import CoreData

internal extension NSPersistentContainer {
    func loadPersistentStores() async throws {
        try await withCheckedThrowingContinuation { [unowned self] (continuation: CheckedContinuation<Void, Error>) in
            self.loadPersistentStores { (_, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
