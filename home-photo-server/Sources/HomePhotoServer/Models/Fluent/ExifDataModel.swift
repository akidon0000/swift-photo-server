import Fluent
import Foundation

/// Fluent モデル: `exif_data` テーブル
///
/// EXIF メタデータを PostgreSQL に永続化するための Fluent ORM モデル。
/// `PhotoMetadataModel` と 1:1 のリレーションを持つ。
///
/// ## テーブル定義
/// ```sql
/// CREATE TABLE exif_data (
///     id UUID PRIMARY KEY,
///     photo_id UUID NOT NULL REFERENCES photo_metadata(id) ON DELETE CASCADE,
///     camera_make VARCHAR(100),
///     camera_model VARCHAR(100),
///     lens_model VARCHAR(200),
///     focal_length DOUBLE PRECISION,
///     aperture DOUBLE PRECISION,
///     shutter_speed VARCHAR(20),
///     iso INTEGER,
///     latitude DOUBLE PRECISION,
///     longitude DOUBLE PRECISION,
///     altitude DOUBLE PRECISION,
///     date_time_original TIMESTAMPTZ
/// );
/// ```
///
/// ## 注意事項
/// - 親レコード (`photo_metadata`) 削除時に CASCADE で自動削除される
/// - すべてのフィールドは NULL 許容 (EXIF 情報がない場合)
final class ExifDataModel: Model, @unchecked Sendable {
    /// テーブル名
    static let schema = "exif_data"

    /// 主キー (UUID)
    @ID(key: .id)
    var id: UUID?

    /// 親の写真メタデータへの参照 (外部キー)
    @Parent(key: "photo_id")
    var photo: PhotoMetadataModel

    /// カメラメーカー
    @OptionalField(key: "camera_make")
    var cameraMake: String?

    /// カメラモデル
    @OptionalField(key: "camera_model")
    var cameraModel: String?

    /// レンズモデル
    @OptionalField(key: "lens_model")
    var lensModel: String?

    /// 焦点距離 (mm)
    @OptionalField(key: "focal_length")
    var focalLength: Double?

    /// 絞り値 (F値)
    @OptionalField(key: "aperture")
    var aperture: Double?

    /// シャッタースピード (例: `1/125`)
    @OptionalField(key: "shutter_speed")
    var shutterSpeed: String?

    /// ISO 感度
    @OptionalField(key: "iso")
    var iso: Int?

    /// GPS 緯度 (度)
    @OptionalField(key: "latitude")
    var latitude: Double?

    /// GPS 経度 (度)
    @OptionalField(key: "longitude")
    var longitude: Double?

    /// GPS 高度 (メートル)
    @OptionalField(key: "altitude")
    var altitude: Double?

    /// 撮影日時
    @OptionalField(key: "date_time_original")
    var dateTimeOriginal: Date?

    /// Fluent が必要とするデフォルトイニシャライザ
    init() {}

    /// DTO から Fluent モデルを生成
    convenience init(from dto: ExifData, photoID: UUID) {
        self.init()
        self.$photo.id = photoID
        self.cameraMake = dto.cameraMake
        self.cameraModel = dto.cameraModel
        self.lensModel = dto.lensModel
        self.focalLength = dto.focalLength
        self.aperture = dto.aperture
        self.shutterSpeed = dto.shutterSpeed
        self.iso = dto.iso
        self.latitude = dto.latitude
        self.longitude = dto.longitude
        self.altitude = dto.altitude
        self.dateTimeOriginal = dto.dateTimeOriginal
    }

    /// Fluent モデルを DTO に変換
    func toDTO() -> ExifData {
        ExifData(
            cameraMake: cameraMake,
            cameraModel: cameraModel,
            lensModel: lensModel,
            focalLength: focalLength,
            aperture: aperture,
            shutterSpeed: shutterSpeed,
            iso: iso,
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            dateTimeOriginal: dateTimeOriginal
        )
    }
}
