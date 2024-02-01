//  Created by Axel Ancona Esselmann on 1/26/24.
//

import Foundation
import CoreData

extension RecordsStore {

    @RecordsStore
    public static func recordEntityDescription() -> NSEntityDescription {
        let recordEntity = NSEntityDescription()
        recordEntity.name = "RecordEntity"
        recordEntity.managedObjectClassName = NSStringFromClass(RecordEntity.self)

        let recordId = NSAttributeDescription()
        recordId.name = "id"
        recordId.attributeType = .UUIDAttributeType

        let recordNamespace = NSAttributeDescription()
        recordNamespace.name = "namespace"
        recordNamespace.attributeType = .UUIDAttributeType

        let recordIsGroup = NSAttributeDescription()
        recordIsGroup.name = "isGroup"
        recordIsGroup.attributeType = .booleanAttributeType

        let recordParent = NSAttributeDescription()
        recordParent.name = "parent"
        recordParent.attributeType = .UUIDAttributeType

        let recordText = NSAttributeDescription()
        recordText.name = "text"
        recordText.attributeType = .stringAttributeType

        let recordContent = NSAttributeDescription()
        recordContent.name = "content"
        recordContent.attributeType = .transformableAttributeType
        recordContent.valueTransformerName = "NSSecureUnarchiveFromDataTransformer"

        recordEntity.properties = [
            recordId,
            recordNamespace,
            recordIsGroup,
            recordParent,
            recordText,
            recordContent
        ]
        return recordEntity
    }

    @RecordsStore
    internal static func createContainer(subdirectory: String? = nil) throws -> NSPersistentContainer {
        let model = Self.dbModel()
        let dbPath = try Self.dbPath(subdirectory: subdirectory)
        let container = NSPersistentContainer(name: "Records", managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: dbPath)
        container.persistentStoreDescriptions[0] = description
        return container
    }

    @RecordsStore
    private static func dbModel() -> NSManagedObjectModel {
        let recordEntity = recordEntityDescription()

        var model = NSManagedObjectModel()
        model.entities = [ recordEntity ]
        return model
    }

    @RecordsStore
    private static func dbPath(subdirectory: String?) throws -> URL {
        let fileManager = FileManager.default

        let appName = Bundle.main.bundleIdentifier?.components(separatedBy: ".").last ?? ""
        var dbDir = try fileManager.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent(appName)
        .appendingPathComponent("db")
        if let subdirectory = subdirectory {
            dbDir = dbDir.appendingPathComponent(subdirectory)
        }
        dbDir = dbDir.appendingPathComponent("Records")

        if !fileManager.fileExists(atPath: dbDir.relativePath) {
            try fileManager.createDirectory(
                at: dbDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        return dbDir
            .appendingPathComponent("Records" + ".sqlite")
    }
}
