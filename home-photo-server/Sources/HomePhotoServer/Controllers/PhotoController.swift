import Vapor

/// 写真 API コントローラー
struct PhotoController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let photos = routes.grouped("photos")

        // 読み取り
        photos.get(use: list)
        photos.get(":id", use: get)
        photos.get(":id", "download", use: download)
        photos.get(":id", "thumbnail", use: thumbnail)

        // 書き込み
        photos.post(use: upload)
        photos.delete(":id", use: delete)
    }

    /// 写真一覧取得
    ///
    /// - Endpoint: `GET /api/v1/photos`
    /// - Query Parameters:
    ///   - `page`: ページ番号 (デフォルト: 1)
    ///   - `perPage`: 1ページあたりの件数 (デフォルト: 20, 最大: 100)
    ///   - `sortBy`: ソート項目 (`createdAt` | `takenAt`, デフォルト: `createdAt`)
    ///   - `order`: ソート順 (`asc` | `desc`, デフォルト: `desc`)
    ///   - `year`: 年でフィルタ (例: 2025)
    ///   - `month`: 月でフィルタ (例: 1-12)
    /// - Response: `PaginatedResponse<Photo>` (200 OK)
    @Sendable
    func list(req: Request) async throws -> PaginatedResponse<Photo> {
        let query = try req.query.decode(PhotoListQuery.self)
        let service = req.photoStorageService

        let (photos, total) = try await service.listPhotos(
            page: query.validatedPage,
            perPage: query.validatedPerPage,
            sortBy: query.validatedSortBy,
            order: query.validatedOrder,
            year: query.year,
            month: query.month
        )

        let pagination = PaginationInfo(
            page: query.validatedPage,
            perPage: query.validatedPerPage,
            totalItems: total
        )

        return PaginatedResponse(data: photos, pagination: pagination)
    }

    /// 写真詳細取得
    ///
    /// - Endpoint: `GET /api/v1/photos/:id`
    /// - Path Parameters:
    ///   - `id`: 写真の UUID
    /// - Response: `Photo` (200 OK)
    /// - Errors:
    ///   - 400 Bad Request: 無効な UUID 形式
    ///   - 404 Not Found: 写真が存在しない
    @Sendable
    func get(req: Request) async throws -> Photo {
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString) else {
            throw AppError.invalidRequest("Invalid photo ID")
        }

        return try await req.photoStorageService.getPhoto(id: id)
    }

    /// 写真ダウンロード
    ///
    /// - Endpoint: `GET /api/v1/photos/:id/download`
    /// - Path Parameters:
    ///   - `id`: 写真の UUID
    /// - Response: オリジナル画像ファイル (200 OK)
    /// - Response Headers:
    ///   - `Content-Disposition`: `attachment; filename="..."`
    ///   - `ETag`: チェックサム
    ///   - `Cache-Control`: `private, max-age=31536000`
    /// - Errors:
    ///   - 400 Bad Request: 無効な UUID 形式
    ///   - 404 Not Found: 写真が存在しない
    @Sendable
    func download(req: Request) async throws -> Response {
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString) else {
            throw AppError.invalidRequest("Invalid photo ID")
        }

        let service = req.photoStorageService
        let photo = try await service.getPhoto(id: id)
        let filePath = try await service.getPhotoFilePath(id: id)

        let response = req.fileio.streamFile(at: filePath)

        // Content-Type 設定
        let mimeTypeParts = photo.mimeType.split(separator: "/")
        if mimeTypeParts.count == 2 {
            response.headers.contentType = HTTPMediaType(
                type: String(mimeTypeParts[0]),
                subType: String(mimeTypeParts[1])
            )
        }

        // ダウンロード用ヘッダー
        response.headers.add(
            name: .contentDisposition,
            value: "attachment; filename=\"\(photo.filename)\""
        )

        // キャッシュヘッダー
        response.headers.add(name: .eTag, value: "\"\(photo.checksum)\"")
        response.headers.add(name: .cacheControl, value: "private, max-age=31536000")

        return response
    }

    /// 写真アップロード
    ///
    /// - Endpoint: `POST /api/v1/photos`
    /// - Content-Type: `multipart/form-data`
    /// - Request Body:
    ///   - `file`: 画像ファイル (JPEG, PNG, HEIC, WebP)
    /// - Response: `PhotoUploadResponse` (200 OK)
    /// - Errors:
    ///   - 400 Bad Request: ファイルが無い、またはファイル読み取り失敗
    ///   - 400 Bad Request: サポートされていないファイル形式
    ///   - 400 Bad Request: ファイルサイズ超過 (最大 50MB)
    ///   - 409 Conflict: 同一ファイルが既に存在 (SHA256 チェックサム重複)
    @Sendable
    func upload(req: Request) async throws -> PhotoUploadResponse {
        // multipart/form-data からファイルを取得
        let fileUpload = try req.content.decode(FileUpload.self)
        let file = fileUpload.file

        // バリデーション
        try PhotoUploadValidator.validate(file: file)

        // ファイルデータ取得
        guard let data = file.data.getData(at: 0, length: file.data.readableBytes) else {
            throw AppError.invalidRequest("Failed to read file data")
        }

        let mimeType = file.contentType?.serialize() ?? "image/jpeg"

        // アップロード処理
        let photo = try await req.photoStorageService.uploadPhoto(
            filename: file.filename,
            data: data,
            mimeType: mimeType
        )

        return PhotoUploadResponse(photo: photo)
    }

    /// 写真削除
    ///
    /// - Endpoint: `DELETE /api/v1/photos/:id`
    /// - Path Parameters:
    ///   - `id`: 写真の UUID
    /// - Response: 204 No Content
    /// - Errors:
    ///   - 400 Bad Request: 無効な UUID 形式
    ///   - 404 Not Found: 写真が存在しない
    /// - Note: オリジナル画像、サムネイル、メタデータがすべて削除される
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString) else {
            throw AppError.invalidRequest("Invalid photo ID")
        }

        try await req.photoStorageService.deletePhoto(id: id)

        return .noContent
    }

    /// サムネイル取得
    ///
    /// - Endpoint: `GET /api/v1/photos/:id/thumbnail`
    /// - Path Parameters:
    ///   - `id`: 写真の UUID
    /// - Response: サムネイル画像 (JPEG, 300px, 200 OK)
    /// - Response Headers:
    ///   - `Content-Type`: `image/jpeg`
    ///   - `ETag`: チェックサム + `-thumb`
    ///   - `Cache-Control`: `public, max-age=86400`
    /// - Errors:
    ///   - 400 Bad Request: 無効な UUID 形式
    ///   - 404 Not Found: 写真が存在しない
    @Sendable
    func thumbnail(req: Request) async throws -> Response {
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString) else {
            throw AppError.invalidRequest("Invalid photo ID")
        }

        let service = req.photoStorageService
        let photo = try await service.getPhoto(id: id)
        let thumbnailPath = try await service.getThumbnailFilePath(id: id)

        let response = req.fileio.streamFile(at: thumbnailPath)

        response.headers.contentType = .jpeg
        response.headers.add(name: .eTag, value: "\"\(photo.checksum)-thumb\"")
        response.headers.add(name: .cacheControl, value: "public, max-age=86400")

        return response
    }
}
