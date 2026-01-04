import Fluent
import Foundation

/// Fluent モデル: photo_metadata テーブル
final class PhotoMetadataModel: Model, @unchecked Sendable {
    static let schema = "photo_metadata"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "original_filename")
    var originalFilename: String

    @Field(key: "mime_type")
    var mimeType: String

    @Field(key: "size")
    var size: Int64

    @OptionalField(key: "width")
    var width: Int?

    @OptionalField(key: "height")
    var height: Int?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @OptionalField(key: "taken_at")
    var takenAt: Date?

    @Field(key: "checksum")
    var checksum: String

    @Field(key: "storage_path")
    var storagePath: String

    @OptionalField(key: "thumbnail_path")
    var thumbnailPath: String?

    @OptionalChild(for: \.$photo)
    var exifData: ExifDataModel?

    init() {}

    /// DTO から Fluent モデルを生成
    convenience init(from dto: PhotoMetadata) {
        self.init()
        self.id = dto.id
        self.originalFilename = dto.originalFilename
        self.mimeType = dto.mimeType
        self.size = dto.size
        self.width = dto.width
        self.height = dto.height
        self.takenAt = dto.takenAt
        self.checksum = dto.checksum
        self.storagePath = dto.storagePath
        self.thumbnailPath = dto.thumbnailPath
    }

    /// Fluent モデルを DTO に変換
    func toDTO(exifData: ExifData?) -> PhotoMetadata {
        PhotoMetadata(
            id: id ?? UUID(),
            originalFilename: originalFilename,
            mimeType: mimeType,
            size: size,
            width: width,
            height: height,
            createdAt: createdAt ?? Date(),
            takenAt: takenAt,
            checksum: checksum,
            storagePath: storagePath,
            thumbnailPath: thumbnailPath,
            exifData: exifData
        )
    }
}
