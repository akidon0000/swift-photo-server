import Vapor

func routes(_ app: Application) throws {
    // API バージョンを一元管理
    let api = app.grouped("api", "v1")

    // Photo API
    try api.register(collection: PhotoController())

    // Health API
    try api.register(collection: HealthController())
}
