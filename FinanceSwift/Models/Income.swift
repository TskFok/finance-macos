import Foundation

/// 对应 doc.json definitions models.Income
/// 与 APIClient 的 keyDecodingStrategy = .convertFromSnakeCase 配合，接口返回的 income_time 等会自动映射为 incomeTime
struct Income: Codable, Sendable, Identifiable {
    let id: Int
    let amount: Double
    let type: String
    /// 收入时间，接口格式如 2026-01-10T21:42:00+08:00
    var incomeTime: String?
    var userId: Int?
    var createdAt: String?
    var updatedAt: String?
}
