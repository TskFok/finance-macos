import Foundation

/// 对应 doc.json api.AIChatRequest
struct AIChatRequest: Codable, Sendable {
    let message: String
    let modelId: Int

    enum CodingKeys: String, CodingKey {
        case message, modelId
    }
}
