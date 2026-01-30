import Foundation

/// AI 聊天/分析历史单条记录，对应接口 list 元素：ai_model_id, user_id, user_text, ai_text, created_at
/// 与 APIClient 的 convertFromSnakeCase 一致：JSON 键会被转为 camelCase 再解码
struct AIChatHistoryItem: Codable, Sendable, Identifiable {
    let id: Int
    var aiModelId: Int?
    var userId: Int?
    var userText: String?
    var aiText: String?
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, aiModelId, userId, userText, aiText, createdAt
    }
}
