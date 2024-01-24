//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        #if os(macOS)
        NestedTableView(
            dataManager: MockDataManager(),
            delegate: MockNestedTableManager()
        )
        #else
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
        #endif
    }
}
