import Foundation

/// 支出相关接口：列表（分页+时间筛选）、创建、删除；类别列表
@MainActor
final class ExpenseService: ObservableObject {
    private let client = APIClient()

    private var token: String? { AuthService.shared.token }

    /// GET /api/v1/categories
    func fetchCategories() async throws -> [ExpenseCategory] {
        let res: APIResponse<[ExpenseCategory]> = try await client.get(
            path: APIConfig.categoriesPath,
            token: token
        )
        return res.data ?? []
    }

    /// GET /api/v1/expenses?page=&page_size=&start_time=&end_time=&category=
    func fetchExpenses(
        page: Int = 1,
        pageSize: Int = 20,
        startTime: String? = nil,
        endTime: String? = nil,
        category: String? = nil
    ) async throws -> PageResponse<Expense> {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "page_size", value: "\(pageSize)")
        ]
        if let s = startTime, !s.isEmpty { items.append(URLQueryItem(name: "start_time", value: s)) }
        if let e = endTime, !e.isEmpty { items.append(URLQueryItem(name: "end_time", value: e)) }
        if let c = category, !c.isEmpty { items.append(URLQueryItem(name: "category", value: c)) }

        let res: APIResponse<PageResponse<Expense>> = try await client.get(
            path: APIConfig.expensesPath,
            queryItems: items,
            token: token
        )
        guard let data = res.data else {
            return PageResponse(list: [], page: page, pageSize: pageSize, total: 0)
        }
        return data
    }

    /// POST /api/v1/expenses
    func createExpense(amount: Double, category: String, expenseTime: String, description: String?) async throws -> Expense {
        let req = CreateExpenseRequest(
            amount: amount,
            category: category,
            description: description?.isEmpty == true ? nil : description,
            expenseTime: expenseTime
        )
        let res: APIResponse<Expense> = try await client.post(
            path: APIConfig.expensesPath,
            body: req,
            token: token
        )
        guard let data = res.data else {
            throw APIError.httpStatus(res.code ?? -1, res.message ?? "创建失败")
        }
        return data
    }

    /// DELETE /api/v1/expenses/{id}
    func deleteExpense(id: Int) async throws {
        _ = try await client.delete(
            path: "\(APIConfig.expensesPath)/\(id)",
            token: token
        )
    }

    /// GET /api/v1/expenses/detailed-statistics
    /// range_type: month | year | custom；month 时传 year_month(2024-01)；year 时传 year(2024)；custom 时传 start_time、end_time(2024-01-01)；categories 可选，逗号分隔
    func fetchDetailedStatistics(
        rangeType: String,
        yearMonth: String? = nil,
        year: String? = nil,
        startTime: String? = nil,
        endTime: String? = nil,
        categories: String? = nil
    ) async throws -> DetailedStatisticsResponse {
        var items: [URLQueryItem] = [URLQueryItem(name: "range_type", value: rangeType)]
        if let ym = yearMonth, !ym.isEmpty { items.append(URLQueryItem(name: "year_month", value: ym)) }
        if let y = year, !y.isEmpty { items.append(URLQueryItem(name: "year", value: y)) }
        if let s = startTime, !s.isEmpty { items.append(URLQueryItem(name: "start_time", value: s)) }
        if let e = endTime, !e.isEmpty { items.append(URLQueryItem(name: "end_time", value: e)) }
        if let c = categories, !c.isEmpty { items.append(URLQueryItem(name: "categories", value: c)) }

        do {
            let res: APIResponse<DetailedStatisticsResponse> = try await client.get(
                path: APIConfig.detailedStatisticsPath,
                queryItems: items,
                token: token
            )
            if let data = res.data {
                return data
            }
            return DetailedStatisticsResponse(totalAmount: 0, totalCount: 0, categoryStats: [])
        } catch let error as DecodingError {
            throw APIError.httpStatus(-1, "统计数据格式异常：\(decodingErrorMessage(error))")
        }
    }
}

private func decodingErrorMessage(_ error: DecodingError) -> String {
    switch error {
    case .keyNotFound(let key, _):
        return "缺少字段 \(key.stringValue)"
    case .typeMismatch(let type, let context):
        return "类型不匹配 \(type) @ \(context.codingPath.map(\.stringValue).joined(separator: "."))"
    case .valueNotFound(_, let context):
        return "值为空 @ \(context.codingPath.map(\.stringValue).joined(separator: "."))"
    case .dataCorrupted(let context):
        return "数据损坏 @ \(context.codingPath.map(\.stringValue).joined(separator: "."))"
    @unknown default:
        return error.localizedDescription
    }
}
