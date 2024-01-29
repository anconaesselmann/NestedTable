//  Created by Axel Ancona Esselmann on 1/26/24.
//

import CoreData
import CoreDataStored

extension Record: CoreDataStored {
    public init(_ entity: RecordEntity) throws {
        self.id = entity.id
        self.isGroup = entity.isGroup
        self.parent = entity.parent
        self.text = entity.text
        self.content = try Set(entity.content)
    }

    public func entity(existing entity: RecordEntity?, in context: NSManagedObjectContext) -> RecordEntity {
        let entity = entity ?? RecordEntity(context: context)
        entity.id = id
        entity.isGroup = isGroup
        entity.parent = parent
        entity.text = text
        entity.content = content as NSSet
        return entity
    }
}
