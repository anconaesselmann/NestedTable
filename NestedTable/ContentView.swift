//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

enum Test: String, ContextMenuItems {
    case hello
}

struct ContentView: View {

    var body: some View {
        #if os(macOS)
        NestedTableView(
            of: MockContent.self,
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
                of: MockContent.self,
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
