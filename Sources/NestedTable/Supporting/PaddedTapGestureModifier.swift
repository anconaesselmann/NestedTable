//  Created by Axel Ancona Esselmann on 1/25/24.
//

import SwiftUI

struct PaddedTapGestureModifier: ViewModifier {
    let padding: CGFloat
    let onTap: () -> Void

    init(padding: CGFloat, onTap: @escaping () -> Void) {
        self.padding = padding
        self.onTap = onTap
    }

    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding))
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            .padding(EdgeInsets(top: -padding, leading: -padding, bottom: -padding, trailing: -padding))
    }
}

extension View {
    func onTapGesture(padding: CGFloat, onTap: @escaping () -> Void) -> some View {
        self.modifier(PaddedTapGestureModifier(padding: padding, onTap: onTap))
    }
}
