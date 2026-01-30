import Foundation

/// 对应 doc.json api.AnalysisRequest
struct AnalysisRequest: Codable, Sendable {
    let startTime: String
    let endTime: String
    let modelId: Int

    enum CodingKeys: String, CodingKey {
        case startTime, endTime, modelId
    }
}
