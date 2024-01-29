//  Created by Axel Ancona Esselmann on 1/26/24.
//

import Foundation
import CoreData

@objc(RecordEntity)
final public class RecordEntity: NSManagedObject, Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordEntity> {
        NSFetchRequest<RecordEntity>(entityName: "RecordEntity")
    }

    @NSManaged public var content: NSSet
    @NSManaged public var id: UUID
    @NSManaged public var isGroup: Bool
    @NSManaged public var parent: UUID?
    @NSManaged public var text: String

}
