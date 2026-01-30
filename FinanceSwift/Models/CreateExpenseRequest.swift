import Foundation

/// 对应 doc.json api.CreateExpenseRequest
struct CreateExpenseRequest: Codable, Sendable {
    let amount: Double
    let category: String
    var description: String?
    /// 格式: 2006-01-02 15:04:05
    let expenseTime: String

    enum CodingKeys: String, CodingKey {
        case amount, category, description
        case expenseTime = "expense_time"
    }
}
