import Fluent
import Foundation

/// Fluent モデル: `photo_metadata` テーブル
///
/// PostgreSQL に写真メタデータを永続化するための Fluent ORM モデル。
/// DTO (`PhotoMetadata`) と相互変換可能。
///
/// ## テーブル定義
/// ```sql
/// CREATE TABLE photo_metadata (
///     id UUID PRIMARY KEY,
///     original_filename VARCHAR(255) NOT NULL,
///     mime_type VARCHAR(100) NOT NULL,
///     size BIGINT NOT NULL,
///     width INTEGER,
///     height INTEGER,
///     created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
///     taken_at TIMESTAMPTZ,
///     checksum VARCHAR(64) NOT NULL UNIQUE,
///     storage_path VARCHAR(512) NOT NULL,
///     thumbnail_path VARCHAR(512)
/// );
/// ```
///
/// ## リレーション
/// - `exifData`: 1:1 で `ExifDataModel` と関連 (CASCADE 削除)
final class PhotoMetadataModel: Model, @unchecked Sendable {
    /// テーブル名
    static let schema = "photo_metadata"

    /// 主キー (UUID)
    @ID(key: .id)
    var id: UUID?

    /// オリジナルファイル名
    @Field(key: "original_filename")
    var originalFilename: String

    /// MIME タイプ (例: `image/jpeg`)
    @Field(key: "mime_type")
    var mimeType: String

    /// ファイルサイズ (バイト)
    @Field(key: "size")
    var size: Int64

    /// 画像の幅 (ピクセル)
    @OptionalField(key: "width")
    var width: Int?

    /// 画像の高さ (ピクセル)
    @OptionalField(key: "height")
    var height: Int?

    /// レコード作成日時 (自動設定)
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    /// 撮影日時 (EXIF から取得)
    @OptionalField(key: "taken_at")
    var takenAt: Date?

    /// SHA256 チェックサム (UNIQUE 制約)
    @Field(key: "checksum")
    var checksum: String

    /// オリジナル画像の保存パス
    @Field(key: "storage_path")
    var storagePath: String

    /// サムネイル画像の保存パス
    @OptionalField(key: "thumbnail_path")
    var thumbnailPath: String?

    /// 関連する EXIF データ (1:1)
    @OptionalChild(for: \.$photo)
    var exifData: ExifDataModel?

    /// Fluent が必要とするデフォルトイニシャライザ
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
