//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationView {
            NestedTableView(
                dataManager: MockDataManager(),
                delegate: MockNestedTableManager()
            )
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    EditButton()
                }
            }
        }
    }
}
