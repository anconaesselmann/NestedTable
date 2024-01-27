//  Created by Axel Ancona Esselmann on 1/26/24.
//

import CoreData
import CoreDataStored

extension Record: CoreDataStored {
    public init(_ entity: RecordEntity) throws {
        let id = try NotNil(entity.id).unwrapped
        self.id = id
        self.isGroup = entity.isGroup
        self.parent = entity.parent
        self.text = try NotNil(entity.text).unwrapped
        self.content = Set((entity.content?.allObjects as? [UUID]) ?? [])
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
