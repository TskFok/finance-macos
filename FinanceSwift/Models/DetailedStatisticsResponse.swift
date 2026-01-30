import Foundation

/// 按类别统计项，对应 doc.json 中 detailed-statistics 返回的 category_stats 元素
struct CategoryStat: Codable, Sendable, Identifiable {
    var id: String { category }
    let category: String
    let total: Double
    let count: Int
    let percentage: Double?

    enum CodingKeys: String, CodingKey {
        case category, total, count, percentage
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        category = try c.decodeIfPresent(String.self, forKey: .category) ?? ""
        // 兼容后端返回 Int 或 Double
        total = try c.decodeIfPresent(Double.self, forKey: .total)
            ?? (try c.decodeIfPresent(Int.self, forKey: .total).map { Double($0) } ?? 0)
        count = try c.decodeIfPresent(Int.self, forKey: .count) ?? 0
        percentage = try c.decodeIfPresent(Double.self, forKey: .percentage)
    }

    init(category: String, total: Double, count: Int, percentage: Double?) {
        self.category = category
        self.total = total
        self.count = count
        self.percentage = percentage
    }
}

/// 详细消费统计返回，对应 api/v1/expenses/detailed-statistics
/// 与 convertFromSnakeCase 一致：JSON 的 total_amount/category_stats 会被解码为 totalAmount/categoryStats
struct DetailedStatisticsResponse: Codable, Sendable {
    let totalAmount: Double
    let totalCount: Int
    let categoryStats: [CategoryStat]

    /// 不指定 rawValue，与 keyDecodingStrategy.convertFromSnakeCase 转换后的键一致
    enum CodingKeys: String, CodingKey {
        case totalAmount
        case totalCount
        case categoryStats
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        totalAmount = try c.decodeIfPresent(Double.self, forKey: .totalAmount)
            ?? (try c.decodeIfPresent(Int.self, forKey: .totalAmount).map { Double($0) } ?? 0)
        totalCount = try c.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
        categoryStats = try c.decodeIfPresent([CategoryStat].self, forKey: .categoryStats) ?? []
    }

    init(totalAmount: Double, totalCount: Int, categoryStats: [CategoryStat]) {
        self.totalAmount = totalAmount
        self.totalCount = totalCount
        self.categoryStats = categoryStats
    }
}
