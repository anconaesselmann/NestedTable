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
        .contextMenuItem(
            elements: DefaultContextMenuItems.allCases + [Test.hello]
        ) { (element: Test, selected) in
            switch element {
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
            .contextMenuItem(
                elements: DefaultContextMenuItems.allCases + [Test.hello]
            ) { (element: Test, selected) in
                switch element {
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
