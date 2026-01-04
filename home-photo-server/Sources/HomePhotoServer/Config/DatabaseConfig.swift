import Foundation
import Vapor

/// データベース設定
struct DatabaseConfig: Sendable {
    let hostname: String
    let port: Int
    let username: String
    let password: String
    let database: String

    /// 環境変数からデータベース設定を取得
    /// - Returns: 環境変数が設定されている場合は DatabaseConfig、そうでない場合は nil
    static func fromEnvironment() -> DatabaseConfig? {
        guard let hostname = Environment.get("DATABASE_HOST"),
              let username = Environment.get("DATABASE_USERNAME"),
              let password = Environment.get("DATABASE_PASSWORD"),
              let database = Environment.get("DATABASE_NAME") else {
            return nil
        }

        let port = Environment.get("DATABASE_PORT").flatMap(Int.init) ?? 5432

        return DatabaseConfig(
            hostname: hostname,
            port: port,
            username: username,
            password: password,
            database: database
        )
    }
}
