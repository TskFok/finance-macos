import Foundation

/// 收入相关接口：列表（分页+时间筛选）、创建、删除
@MainActor
final class IncomeService: ObservableObject {
    private let client = APIClient()

    private var token: String? { AuthService.shared.token }

    /// GET /api/v1/incomes?page=&page_size=&start_time=&end_time=&type=
    func fetchIncomes(
        page: Int = 1,
        pageSize: Int = 20,
        startTime: String? = nil,
        endTime: String? = nil,
        type: String? = nil
    ) async throws -> PageResponse<Income> {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "page_size", value: "\(pageSize)")
        ]
        if let s = startTime, !s.isEmpty { items.append(URLQueryItem(name: "start_time", value: s)) }
        if let e = endTime, !e.isEmpty { items.append(URLQueryItem(name: "end_time", value: e)) }
        if let t = type, !t.isEmpty { items.append(URLQueryItem(name: "type", value: t)) }

        let res: APIResponse<PageResponse<Income>> = try await client.get(
            path: APIConfig.incomesPath,
            queryItems: items,
            token: token
        )
        guard let data = res.data else {
            return PageResponse(list: [], page: page, pageSize: pageSize, total: 0)
        }
        return data
    }

    /// POST /api/v1/incomes
    func createIncome(amount: Double, type: String, incomeTime: String) async throws -> Income {
        let req = CreateIncomeRequest(
            amount: amount,
            incomeTime: incomeTime,
            type: type
        )
        let res: APIResponse<Income> = try await client.post(
            path: APIConfig.incomesPath,
            body: req,
            token: token
        )
        guard let data = res.data else {
            throw APIError.httpStatus(res.code ?? -1, res.message ?? "创建失败")
        }
        return data
    }

    /// DELETE /api/v1/incomes/{id}
    func deleteIncome(id: Int) async throws {
        _ = try await client.delete(
            path: "\(APIConfig.incomesPath)/\(id)",
            token: token
        )
    }
}
