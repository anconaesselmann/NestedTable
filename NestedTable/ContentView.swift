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
        .contextMenu(
            items: DefaultContextMenuItems.allCases + [Test.hello]
        ) { (item: Test, selected) in
            switch item {
            case .hello:
                if selected.count > 1 {
                    Button("Hello world") {
                        print("Hello world")
                    }
                }
            }
        }
        #else
        NavigationView {
            NestedTableView(
                dataManager: MockDataManager(),
                delegate: MockNestedTableManager()
            )
            .contextMenu(
                items: DefaultContextMenuItems.allCases + [Test.hello]
            ) { (item: Test, selected) in
                switch item {
                case .hello:
                    if selected.count > 1 {
                        Button("Hello world") {
                            print("Hello world")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {


                    EditButton()
                }
            }
        }
        #endif
    }
}
