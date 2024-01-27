//  Created by Axel Ancona Esselmann on 1/25/24.
//

import SwiftUI

public struct PaddedTapGestureModifier: ViewModifier {
    public let padding: CGFloat
    public let onTap: () -> Void

    public init(padding: CGFloat, onTap: @escaping () -> Void) {
        self.padding = padding
        self.onTap = onTap
    }

    public func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding))
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            .padding(EdgeInsets(top: -padding, leading: -padding, bottom: -padding, trailing: -padding))
    }
}

public extension View {
    func onTapGesture(padding: CGFloat, onTap: @escaping () -> Void) -> some View {
        self.modifier(PaddedTapGestureModifier(padding: padding, onTap: onTap))
    }
}
