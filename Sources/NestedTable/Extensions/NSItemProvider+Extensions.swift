//  Created by Axel Ancona Esselmann on 3/9/24.
//

import Foundation

public extension NSItemProvider {

    enum LoadingError: Swift.Error {
        case nilObject
    }

    func loadObject<T>(ofClass classType: T.Type) async throws -> T
        where
            T: _ObjectiveCBridgeable,
            T._ObjectiveCType : NSItemProviderReading
    {
        try await withCheckedThrowingContinuation { [unowned self] (continuation: CheckedContinuation<T, Error>) in
            let _ = self.loadObject(ofClass: classType) { (object, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let object = object else {
                    continuation.resume(throwing: LoadingError.nilObject)
                    return
                }
                continuation.resume(returning: object)
            }
        }
    }
}
