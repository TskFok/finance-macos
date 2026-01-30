import Foundation

/// 对应 doc.json definitions models.ExpenseCategory
struct ExpenseCategory: Codable, Sendable, Identifiable {
    let id: Int
    let name: String
    var sort: Int?
    var color: String?
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, sort, color
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
