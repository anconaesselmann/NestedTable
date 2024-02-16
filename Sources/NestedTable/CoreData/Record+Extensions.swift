//  Created by Axel Ancona Esselmann on 2/16/24.
//

import Foundation
import CoreData
import CoreDataStored

extension RecordEntity {
    func removeChildren(
        children: Set<UUID>,
        in context: NSManagedObjectContext
    ) throws {
        guard let content = content.allObjects as? [UUID] else {
            return
        }
        let newContent = Set(content).subtracting(children)
        self.content = newContent as NSSet
    }
}
