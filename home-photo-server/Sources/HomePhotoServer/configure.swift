import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) async throws {
    // リクエストボディサイズ制限 (50MB - 写真アップロード用)
    app.routes.defaultMaxBodySize = "50mb"

    // ストレージ設定
    let basePath = StorageConfig.defaultBasePath()
    let config = StorageConfig(basePath: basePath)
    app.storageConfig = config

    // 画像処理サービス初期化 (プラットフォーム別)
    #if os(Linux)
    let imageProcessor = VipsImageProcessor(thumbnailMaxSize: 300)
    #else
    let imageProcessor = CoreGraphicsImageProcessor(thumbnailMaxSize: 300)
    #endif
    app.imageProcessingService = imageProcessor

    // メタデータストア初期化 (環境に応じて切り替え)
    let metadataStore: any MetadataStore

    if let dbConfig = DatabaseConfig.fromEnvironment() {
        // PostgreSQL 設定
        app.databases.use(
            .postgres(
                configuration: .init(
                    hostname: dbConfig.hostname,
                    port: dbConfig.port,
                    username: dbConfig.username,
                    password: dbConfig.password,
                    database: dbConfig.database,
                    tls: .prefer(try .init(configuration: .clientDefault))
                )
            ),
            as: .psql
        )

        // マイグレーション登録
        app.migrations.add(CreatePhotoMetadata())
        app.migrations.add(CreateExifData())

        // マイグレーション実行
        try await app.autoMigrate()

        metadataStore = FluentMetadataStore(database: app.db)
        app.logger.info("Using PostgreSQL metadata store")
    } else {
        // JSON ストアにフォールバック
        metadataStore = JSONMetadataStore(filePath: config.metadataPath)
        app.logger.info("Using JSON file metadata store (DATABASE_* env not set)")
    }

    app.metadataStore = metadataStore

    // 写真ストレージサービス初期化
    let photoService = LocalPhotoStorageService(
        basePath: config.photosPath,
        thumbnailsPath: config.thumbnailsPath,
        metadataStore: metadataStore,
        imageProcessor: imageProcessor
    )
    app.photoStorageService = photoService

    // ストレージディレクトリ作成
    try ensureStorageDirectories(config: config)

    // ルート登録
    try routes(app)

    app.logger.info("Storage configured at: \(basePath)")
}

/// ストレージディレクトリの存在を確認し、なければ作成
private func ensureStorageDirectories(config: StorageConfig) throws {
    let fm = FileManager.default
    let directories = [
        config.basePath,
        config.photosPath,
        config.thumbnailsPath
    ]

    for dir in directories {
        if !fm.fileExists(atPath: dir) {
            try fm.createDirectory(atPath: dir, withIntermediateDirectories: true)
        }
    }
}
