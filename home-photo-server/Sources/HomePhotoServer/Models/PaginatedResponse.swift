import Vapor

/// ページネーション付きレスポンス
///
/// 一覧 API のレスポンス形式。データ配列とページネーション情報を含む。
///
/// ## JSON レスポンス例
/// ```json
/// {
///   "data": [...],
///   "pagination": {
///     "page": 1,
///     "perPage": 20,
///     "totalItems": 150,
///     "totalPages": 8,
///     "hasNextPage": true,
///     "hasPrevPage": false
///   }
/// }
/// ```
struct PaginatedResponse<T: Content>: Content {
    /// ページ内のデータ配列
    let data: [T]

    /// ページネーション情報
    let pagination: PaginationInfo
}

/// ページネーション情報
///
/// 現在のページ位置と全体の件数情報を提供する。
/// クライアントはこの情報を使って前後ページへのナビゲーションを実装できる。
struct PaginationInfo: Content {
    /// 現在のページ番号 (1-indexed)
    let page: Int

    /// 1ページあたりの件数
    let perPage: Int

    /// 全体の件数
    let totalItems: Int

    /// 全体のページ数 (計算値: `ceil(totalItems / perPage)`)
    let totalPages: Int

    /// 次のページが存在するか
    let hasNextPage: Bool

    /// 前のページが存在するか
    let hasPrevPage: Bool

    /// ページネーション情報を生成
    ///
    /// - Parameters:
    ///   - page: 現在のページ番号
    ///   - perPage: 1ページあたりの件数
    ///   - totalItems: 全体の件数
    init(page: Int, perPage: Int, totalItems: Int) {
        self.page = page
        self.perPage = perPage
        self.totalItems = totalItems
        self.totalPages = perPage > 0 ? Int(ceil(Double(totalItems) / Double(perPage))) : 0
        self.hasNextPage = page < self.totalPages
        self.hasPrevPage = page > 1
    }
}
