import Vapor

/// 写真 API コントローラー
struct PhotoController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let photos = routes.grouped("api", "v1", "photos")

        photos.get(use: list)
        photos.get(":id", use: get)
        photos.get(":id", "download", use: download)
    }

    /// GET /api/v1/photos - 写真一覧取得
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

    /// GET /api/v1/photos/:id - 写真詳細取得
    @Sendable
    func get(req: Request) async throws -> Photo {
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString) else {
            throw AppError.invalidRequest("Invalid photo ID")
        }

        return try await req.photoStorageService.getPhoto(id: id)
    }

    /// GET /api/v1/photos/:id/download - 写真ダウンロード
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
}
