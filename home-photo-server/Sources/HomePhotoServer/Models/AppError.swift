import Vapor

/// アプリケーションエラー
///
/// API で発生するエラーを表現する列挙型。
/// Vapor の `AbortError` プロトコルに準拠し、適切な HTTP ステータスコードを返す。
///
/// ## エラーレスポンス形式
/// ```json
/// {
///   "error": true,
///   "reason": "Photo not found"
/// }
/// ```
///
/// ## HTTP ステータスコードマッピング
/// | エラー | ステータス |
/// |--------|------------|
/// | `photoNotFound` | 404 Not Found |
/// | `thumbnailNotFound` | 404 Not Found |
/// | `invalidRequest` | 400 Bad Request |
/// | `duplicatePhoto` | 409 Conflict |
/// | `storageError` | 500 Internal Server Error |
/// | `imageProcessingError` | 500 Internal Server Error |
enum AppError: AbortError {
    /// 指定された ID の写真が存在しない (404)
    case photoNotFound

    /// サムネイルが生成されていない、または見つからない (404)
    case thumbnailNotFound

    /// ストレージ操作に失敗 (500)
    case storageError(String)

    /// リクエストパラメータが不正 (400)
    case invalidRequest(String)

    /// 同一チェックサムの写真が既に存在 (409)
    case duplicatePhoto(UUID)

    /// 画像処理に失敗 (500)
    case imageProcessingError(String)

    /// HTTP レスポンスステータスコード
    var status: HTTPResponseStatus {
        switch self {
        case .photoNotFound, .thumbnailNotFound:
            return .notFound
        case .storageError, .imageProcessingError:
            return .internalServerError
        case .invalidRequest:
            return .badRequest
        case .duplicatePhoto:
            return .conflict
        }
    }

    /// エラーメッセージ (クライアントに返却される)
    var reason: String {
        switch self {
        case .photoNotFound:
            return "Photo not found"
        case .thumbnailNotFound:
            return "Thumbnail not found"
        case .storageError(let message):
            return message
        case .invalidRequest(let message):
            return message
        case .duplicatePhoto(let id):
            return "Photo already exists with id: \(id)"
        case .imageProcessingError(let message):
            return "Image processing failed: \(message)"
        }
    }
}
