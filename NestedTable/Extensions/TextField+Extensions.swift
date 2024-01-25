//  Created by Axel Ancona Esselmann on 1/24/24.
//

import SwiftUI

extension View {
    func defaultTextFieldStyle() -> some View {
        #if os(macOS)
            textFieldStyle(.squareBorder)
        #else
            textFieldStyle(.roundedBorder)
        #endif
    }
}
