import Fluent
import Foundation

/// Fluent モデル: exif_data テーブル
final class ExifDataModel: Model, @unchecked Sendable {
    static let schema = "exif_data"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "photo_id")
    var photo: PhotoMetadataModel

    @OptionalField(key: "camera_make")
    var cameraMake: String?

    @OptionalField(key: "camera_model")
    var cameraModel: String?

    @OptionalField(key: "lens_model")
    var lensModel: String?

    @OptionalField(key: "focal_length")
    var focalLength: Double?

    @OptionalField(key: "aperture")
    var aperture: Double?

    @OptionalField(key: "shutter_speed")
    var shutterSpeed: String?

    @OptionalField(key: "iso")
    var iso: Int?

    @OptionalField(key: "latitude")
    var latitude: Double?

    @OptionalField(key: "longitude")
    var longitude: Double?

    @OptionalField(key: "altitude")
    var altitude: Double?

    @OptionalField(key: "date_time_original")
    var dateTimeOriginal: Date?

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
