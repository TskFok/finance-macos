import Foundation

/// 对应 doc.json definitions models.Income
struct Income: Codable, Sendable, Identifiable {
    let id: Int
    let amount: Double
    let type: String
    var incomeTime: String?
    var userId: Int?
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, amount, type
        case incomeTime = "income_time"
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
