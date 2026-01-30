import Foundation

/// 对应 doc.json api.Response，通用包装：{ code, message, data }
struct APIResponse<T: Codable>: Codable {
    let code: Int?
    let message: String?
    let data: T?
}
