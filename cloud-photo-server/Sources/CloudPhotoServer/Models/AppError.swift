import Vapor

/// アプリケーションエラー
enum AppError: AbortError {
    case photoNotFound
    case storageError(String)
    case invalidRequest(String)

    var status: HTTPResponseStatus {
        switch self {
        case .photoNotFound:
            return .notFound
        case .storageError:
            return .internalServerError
        case .invalidRequest:
            return .badRequest
        }
    }

    var reason: String {
        switch self {
        case .photoNotFound:
            return "Photo not found"
        case .storageError(let message):
            return message
        case .invalidRequest(let message):
            return message
        }
    }
}
