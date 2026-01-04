import Fluent
import Foundation

/// PostgreSQL (Fluent) ベースのメタデータストア
final class FluentMetadataStore: MetadataStore, Sendable {
    private let database: any Database

    init(database: any Database) {
        self.database = database
    }

    func loadAll() async throws -> [PhotoMetadata] {
        let models = try await PhotoMetadataModel.query(on: database)
            .with(\.$exifData)
            .all()

        return models.map { model in
            model.toDTO(exifData: model.exifData?.toDTO())
        }
    }

    func get(id: UUID) async throws -> PhotoMetadata? {
        guard let model = try await PhotoMetadataModel.query(on: database)
            .filter(\.$id == id)
            .with(\.$exifData)
            .first() else {
            return nil
        }

        return model.toDTO(exifData: model.exifData?.toDTO())
    }

    func save(_ metadata: PhotoMetadata) async throws {
        let model = PhotoMetadataModel(from: metadata)
        try await model.save(on: database)

        if let exifDTO = metadata.exifData {
            let exifModel = ExifDataModel(from: exifDTO, photoID: metadata.id)
            try await exifModel.save(on: database)
        }
    }

    func delete(id: UUID) async throws {
        try await PhotoMetadataModel.query(on: database)
            .filter(\.$id == id)
            .delete()
    }
}
