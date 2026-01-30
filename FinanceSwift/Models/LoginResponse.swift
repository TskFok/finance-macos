import Foundation

/// 对应 doc.json api.LoginResponse
struct LoginResponse: Codable, Sendable {
    let token: String
    let userInfo: User?

    enum CodingKeys: String, CodingKey {
        case token
        case userInfo = "user_info"
    }
}
