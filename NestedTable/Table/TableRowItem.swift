//  Created by Axel Ancona Esselmann on 1/23/24.
//

import Foundation

protocol TableRowItem: Identifiable, Codable {
    var id: UUID { get }
    var parent: UUID? { get set }
    var text: String { get set }
}
