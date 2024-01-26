//  Created by Axel Ancona Esselmann on 1/23/24.
//

import SwiftUI

protocol TableRowItem: Identifiable {
    var id: UUID { get }
    var parent: UUID? { get set }
    var text: String { get set }
    var image: Image { get }
}
