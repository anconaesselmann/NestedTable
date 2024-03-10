//  Created by Axel Ancona Esselmann on 3/9/24.
//

import SwiftUI
import Combine

struct HoverView: View {

    @StateObject
    var vm: HoverViewModel

    init(hoveringOverElement: AnyPublisher<UUID?, Never>) {
        let vm = HoverViewModel(hoveringOverElement: hoveringOverElement)
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        if vm.isActive {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

@MainActor
class HoverViewModel: ObservableObject {

    private var bag: AnyCancellable?

    init(hoveringOverElement: AnyPublisher<UUID?, Never>) {
        bag = hoveringOverElement.sink { [weak self] group in
            guard let group = group else {
                self?.isActive = true
                return
            }
            self?.isActive = false
        }
    }

    @Published
    var isActive: Bool = false
}
