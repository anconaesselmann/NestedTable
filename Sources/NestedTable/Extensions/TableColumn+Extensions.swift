//  Created by Axel Ancona Esselmann on 2/3/24.
//

import SwiftUI

public extension TableColumn {
    init<RowContent, ColumnType, ConditionalContent>(
        _ titleKey: LocalizedStringKey,
        sortUsing keyPath: KeyPath<BaseRow<RowContent>, ColumnType?>,
        @ViewBuilder content: @escaping (ColumnType) -> ConditionalContent
    )
        where
            ColumnType: NestedTable.Comparable,
            Sort == KeyPathComparator<BaseRow<RowContent>>,
            RowValue == BaseRow<RowContent>,
            ConditionalContent: View,
            _ConditionalContent<ConditionalContent, EmptyView> == Content,
            Label == Text
    {
        self.init(
            titleKey,
            sortUsing: KeyPathComparator<BaseRow<RowContent>>.content(keyPath),
            content: {
                if let value = $0[keyPath: keyPath] {
                    content(value)
                } else {
                    EmptyView()
                }
            }
        )
    }

    init<RowContent>(
        _ titleKey: LocalizedStringKey,
        sortUsing keyPath: KeyPath<BaseRow<RowContent>, String?>
    )
        where
            Sort == KeyPathComparator<BaseRow<RowContent>>,
            RowValue == BaseRow<RowContent>,
            _ConditionalContent<Text, EmptyView> == Content,
            Label == Text
    {
        self.init(
            titleKey,
            sortUsing: KeyPathComparator<BaseRow<RowContent>>.content(keyPath),
            content: {
                if let value = $0[keyPath: keyPath] {
                    Text(value)
                } else {
                    EmptyView()
                }
            }
        )
    }
}
