import Foundation

/// 对应 doc.json definitions models.User
struct User: Codable, Sendable {
    let id: Int
    let username: String
    var email: String?
    /// 用户状态：locked / active
    var status: String?
    /// 是否为管理员
    var isAdmin: Bool?
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, username, email, status
        case isAdmin = "is_admin"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
