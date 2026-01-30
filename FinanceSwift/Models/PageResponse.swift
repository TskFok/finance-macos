import Foundation

/// 对应 doc.json api.PageResponse，分页数据包装
struct PageResponse<T: Codable>: Codable {
    var list: [T]
    var page: Int?
    var pageSize: Int?
    var total: Int?

    enum CodingKeys: String, CodingKey {
        case list, page, total, pageSize
    }
}
