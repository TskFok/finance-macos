import Foundation

/// 对应 doc.json definitions models.Expense
struct Expense: Codable, Sendable, Identifiable {
    let id: Int
    let amount: Double
    let category: String
    var description: String?
    /// 格式: 2006-01-02 15:04:05
    var expenseTime: String?
    var userId: Int?
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, amount, category, description
        case expenseTime = "expense_time"
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
