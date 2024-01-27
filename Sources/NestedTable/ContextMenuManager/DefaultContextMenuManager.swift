//  Created by Axel Ancona Esselmann on 1/24/24.
//

import SwiftUI
import Combine

@MainActor
public class DefaultContextMenuManager: ContextMenuManager {

    public var isNameFocused: AnyPublisher<Bool, Never> {
        _isNameFocused.eraseToAnyPublisher()
    }

    private let _isNameFocused = PassthroughSubject<Bool, Never>()

    public func focusName(_ isFocused: Bool) {
        _isNameFocused.send(isFocused)
    }
}
