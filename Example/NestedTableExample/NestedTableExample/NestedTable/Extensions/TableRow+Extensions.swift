//  Created by Axel Ancona Esselmann on 1/25/24.
//

import SwiftUI

extension TableRowContent {
    @TableRowBuilder<TableRowValue>
    func `if`<Content>(_ condition: Bool, transform: (Self) -> Content) -> _ConditionalContent<some TableRowContent<TableRowValue>, Self>
        where
            Content: TableRowContent,
            TableRowValue == Content.TableRowValue
    {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
