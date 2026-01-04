import Foundation

/// EXIF メタデータ
///
/// 写真ファイルから抽出した撮影情報を保持する。
/// すべてのフィールドは Optional (EXIF 情報が存在しない場合がある)。
///
/// ## 対応フォーマット
/// - JPEG: EXIF 2.32 準拠
/// - HEIC: Apple 拡張 EXIF
/// - PNG: tEXt チャンク (限定的)
///
/// ## 抽出例
/// ```swift
/// let exif = ExifData(
///     cameraMake: "Apple",
///     cameraModel: "iPhone 15 Pro",
///     focalLength: 6.765,
///     aperture: 1.78,
///     iso: 100
/// )
/// ```
struct ExifData: Codable, Sendable {
    /// カメラメーカー (例: `Apple`, `Canon`, `Sony`)
    let cameraMake: String?

    /// カメラモデル (例: `iPhone 15 Pro`, `EOS R5`)
    let cameraModel: String?

    /// レンズモデル (例: `RF24-105mm F4 L IS USM`)
    let lensModel: String?

    /// 焦点距離 (mm 単位、例: `24.0`, `105.0`)
    let focalLength: Double?

    /// 絞り値 / F値 (例: `1.8`, `4.0`, `11.0`)
    let aperture: Double?

    /// シャッタースピード (文字列形式、例: `1/125`, `1/1000`, `30"`)
    let shutterSpeed: String?

    /// ISO 感度 (例: `100`, `800`, `6400`)
    let iso: Int?

    /// GPS 緯度 (度、北緯が正、南緯が負)
    let latitude: Double?

    /// GPS 経度 (度、東経が正、西経が負)
    let longitude: Double?

    /// GPS 高度 (メートル、海抜基準)
    let altitude: Double?

    /// 撮影日時 (カメラ内蔵時計の記録値)
    let dateTimeOriginal: Date?

    init(
        cameraMake: String? = nil,
        cameraModel: String? = nil,
        lensModel: String? = nil,
        focalLength: Double? = nil,
        aperture: Double? = nil,
        shutterSpeed: String? = nil,
        iso: Int? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        altitude: Double? = nil,
        dateTimeOriginal: Date? = nil
    ) {
        self.cameraMake = cameraMake
        self.cameraModel = cameraModel
        self.lensModel = lensModel
        self.focalLength = focalLength
        self.aperture = aperture
        self.shutterSpeed = shutterSpeed
        self.iso = iso
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.dateTimeOriginal = dateTimeOriginal
    }
}
