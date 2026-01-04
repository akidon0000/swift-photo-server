import Foundation

/// 内部管理用のメタデータモデル
///
/// サーバー内部で写真を管理するための完全なメタデータ。
/// ストレージパスや EXIF データなど、クライアントに公開しない情報も含む。
///
/// ## ストレージ構造
/// ```
/// {basePath}/
/// ├── originals/
/// │   └── {id}.{ext}     <- storagePath
/// ├── thumbnails/
/// │   └── {id}.jpg       <- thumbnailPath
/// └── metadata/
///     └── {id}.json      <- このモデルを JSON で保存
/// ```
///
/// ## 関連モデル
/// - `Photo`: API レスポンス用 (公開フィールドのみ)
/// - `PhotoMetadataModel`: PostgreSQL 永続化用 (Fluent)
struct PhotoMetadata: Codable, Sendable {
    /// 写真の一意識別子 (UUID v4)
    let id: UUID

    /// アップロード時のオリジナルファイル名
    let originalFilename: String

    /// MIME タイプ (例: `image/jpeg`, `image/png`, `image/heic`, `image/webp`)
    let mimeType: String

    /// ファイルサイズ (バイト)
    let size: Int64

    /// 画像の幅 (ピクセル)。EXIF またはイメージ解析から取得
    let width: Int?

    /// 画像の高さ (ピクセル)。EXIF またはイメージ解析から取得
    let height: Int?

    /// サーバーへのアップロード日時 (UTC)
    let createdAt: Date

    /// 撮影日時 (EXIF の DateTimeOriginal から取得)
    let takenAt: Date?

    /// ファイルの SHA256 チェックサム (重複検出用、一意制約)
    let checksum: String

    /// オリジナル画像の保存パス (相対パス: `originals/{id}.{ext}`)
    let storagePath: String

    /// サムネイル画像の保存パス (相対パス: `thumbnails/{id}.jpg`)
    let thumbnailPath: String?

    /// EXIF メタデータ (カメラ情報、GPS 等)
    let exifData: ExifData?

    init(
        id: UUID = UUID(),
        originalFilename: String,
        mimeType: String,
        size: Int64,
        width: Int? = nil,
        height: Int? = nil,
        createdAt: Date = Date(),
        takenAt: Date? = nil,
        checksum: String,
        storagePath: String,
        thumbnailPath: String? = nil,
        exifData: ExifData? = nil
    ) {
        self.id = id
        self.originalFilename = originalFilename
        self.mimeType = mimeType
        self.size = size
        self.width = width
        self.height = height
        self.createdAt = createdAt
        self.takenAt = takenAt
        self.checksum = checksum
        self.storagePath = storagePath
        self.thumbnailPath = thumbnailPath
        self.exifData = exifData
    }
}
