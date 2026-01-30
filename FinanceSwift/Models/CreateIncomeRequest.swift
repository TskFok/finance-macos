import Foundation

/// 对应 doc.json api.CreateIncomeRequest
struct CreateIncomeRequest: Codable, Sendable {
    let amount: Double
    /// 格式: 2006-01-02 15:04:05
    let incomeTime: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case amount, type
        case incomeTime = "income_time"
    }
}
