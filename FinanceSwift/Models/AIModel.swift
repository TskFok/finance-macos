import Foundation

/// 对应 doc.json definitions models.AIModel（不包含 APIKey）
struct AIModel: Codable, Sendable, Identifiable {
    let id: Int
    let name: String
    var baseUrl: String?
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, baseUrl, createdAt, updatedAt
    }
}
