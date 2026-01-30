import Foundation

/// AI 数据分析历史单条记录，对应接口 list 元素：start_date, end_date, result（与聊天历史结构不同）
struct AIAnalysisHistoryItem: Codable, Sendable, Identifiable {
    let id: Int
    var aiModelId: Int?
    var userId: Int?
    var startDate: String?
    var endDate: String?
    var result: String?
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, aiModelId, userId, startDate, endDate, result, createdAt
    }
}
