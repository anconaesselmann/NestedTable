//  Created by Axel Ancona Esselmann on 1/24/24.
//

import SwiftUI
import Combine

enum Test: String, ContextMenuItems {
    case hello
}

@MainActor
class DefaultContextMenuManager: ContextMenuManager {

    var isNameFocused: AnyPublisher<Bool, Never> {
        _isNameFocused.eraseToAnyPublisher()
    }

    private let _isNameFocused = PassthroughSubject<Bool, Never>()

    func focusName(_ isFocused: Bool) {
        _isNameFocused.send(isFocused)
    }
}
