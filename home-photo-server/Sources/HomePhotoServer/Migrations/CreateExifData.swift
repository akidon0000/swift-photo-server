import Fluent

/// exif_data テーブルを作成するマイグレーション
struct CreateExifData: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("exif_data")
            .id()
            .field("photo_id", .uuid, .required, .references("photo_metadata", "id", onDelete: .cascade))
            .field("camera_make", .string)
            .field("camera_model", .string)
            .field("lens_model", .string)
            .field("focal_length", .double)
            .field("aperture", .double)
            .field("shutter_speed", .string)
            .field("iso", .int)
            .field("latitude", .double)
            .field("longitude", .double)
            .field("altitude", .double)
            .field("date_time_original", .datetime)
            .unique(on: "photo_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("exif_data").delete()
    }
}
