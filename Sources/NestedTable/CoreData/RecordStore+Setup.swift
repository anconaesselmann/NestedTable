//  Created by Axel Ancona Esselmann on 1/26/24.
//

import Foundation
import CoreData

extension RecordsStore {
    @RecordsStore
    internal func createContainer(subdirectory: String? = nil) throws -> NSPersistentContainer {
        let model = dbModel()
        let dbPath = try dbPath(subdirectory: subdirectory)
        let container = NSPersistentContainer(name: "Records", managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: dbPath)
        container.persistentStoreDescriptions[0] = description
        return container
    }

    @RecordsStore
    public func recordEntityDescription() -> NSEntityDescription {
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
    private func dbModel() -> NSManagedObjectModel {
        let recordEntity = recordEntityDescription()

        var model = NSManagedObjectModel()
        model.entities = [ recordEntity ]
        return model
    }

    @RecordsStore
    private func dbPath(subdirectory: String?) throws -> URL {
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

public extension NSPersistentContainer {
    func loadPersistentStores() async throws {
        try await withCheckedThrowingContinuation { [unowned self] (continuation: CheckedContinuation<Void, Error>) in
            self.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            })
        }
    }
}
