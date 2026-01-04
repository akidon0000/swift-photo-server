import Fluent

/// photo_metadata テーブルを作成するマイグレーション
struct CreatePhotoMetadata: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("photo_metadata")
            .id()
            .field("original_filename", .string, .required)
            .field("mime_type", .string, .required)
            .field("size", .int64, .required)
            .field("width", .int)
            .field("height", .int)
            .field("created_at", .datetime, .required)
            .field("taken_at", .datetime)
            .field("checksum", .string, .required)
            .field("storage_path", .string, .required)
            .field("thumbnail_path", .string)
            .unique(on: "checksum")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("photo_metadata").delete()
    }
}
