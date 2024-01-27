//  Created by Axel Ancona Esselmann on 1/24/24.
//

import SwiftUI
import Combine

@MainActor
public protocol ContextMenuManager {
    var isNameFocused: AnyPublisher<Bool, Never> { get }

    func focusName(_ isFocused: Bool)
}
