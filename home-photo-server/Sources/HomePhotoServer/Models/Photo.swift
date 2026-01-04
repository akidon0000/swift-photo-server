import Foundation
import Vapor

/// API レスポンス用の写真モデル
///
/// クライアントに返却する写真情報を表現する。
/// 内部管理用の `PhotoMetadata` から必要なフィールドのみを公開する。
///
/// ## 使用例
/// ```swift
/// let photo = Photo(from: metadata)
/// return photo // JSON としてレスポンス
/// ```
///
/// ## JSON レスポンス例
/// ```json
/// {
///   "id": "550e8400-e29b-41d4-a716-446655440000",
///   "filename": "IMG_0001.jpg",
///   "mimeType": "image/jpeg",
///   "size": 2048576,
///   "width": 4032,
///   "height": 3024,
///   "createdAt": "2025-01-01T12:00:00Z",
///   "takenAt": "2025-01-01T10:30:00Z",
///   "checksum": "sha256:abc123..."
/// }
/// ```
struct Photo: Content, Sendable {
    /// 写真の一意識別子 (UUID v4)
    let id: UUID

    /// オリジナルファイル名
    let filename: String

    /// MIME タイプ (例: `image/jpeg`, `image/png`, `image/heic`)
    let mimeType: String

    /// ファイルサイズ (バイト)
    let size: Int64

    /// 画像の幅 (ピクセル)。取得できない場合は `nil`
    let width: Int?

    /// 画像の高さ (ピクセル)。取得できない場合は `nil`
    let height: Int?

    /// サーバーへのアップロード日時
    let createdAt: Date

    /// 撮影日時 (EXIF から取得)。取得できない場合は `nil`
    let takenAt: Date?

    /// ファイルの SHA256 チェックサム (重複検出に使用)
    let checksum: String

    /// `PhotoMetadata` から `Photo` を生成
    ///
    /// - Parameter metadata: 内部管理用メタデータ
    init(from metadata: PhotoMetadata) {
        self.id = metadata.id
        self.filename = metadata.originalFilename
        self.mimeType = metadata.mimeType
        self.size = metadata.size
        self.width = metadata.width
        self.height = metadata.height
        self.createdAt = metadata.createdAt
        self.takenAt = metadata.takenAt
        self.checksum = metadata.checksum
    }
}
