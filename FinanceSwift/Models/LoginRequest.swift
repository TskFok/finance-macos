import Foundation

/// 对应 doc.json api.LoginRequest
struct LoginRequest: Codable, Sendable {
    let username: String
    let password: String
}
