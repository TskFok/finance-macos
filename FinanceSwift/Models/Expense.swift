import Foundation

/// 对应 doc.json definitions models.Expense
/// 与 APIClient 的 keyDecodingStrategy = .convertFromSnakeCase 配合，接口返回的 expense_time 等会自动映射为 expenseTime
struct Expense: Codable, Sendable, Identifiable {
    let id: Int
    let amount: Double
    let category: String
    var description: String?
    /// 支出时间，接口格式如 2026-02-02T11:24:12+08:00
    var expenseTime: String?
    var userId: Int?
    var createdAt: String?
    var updatedAt: String?
}
