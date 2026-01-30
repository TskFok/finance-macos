import Foundation

@MainActor
final class IncomeListViewModel: ObservableObject {
    @Published var list: [Income] = []
    @Published var page: Int = 1
    @Published var pageSize: Int = 20
    @Published var total: Int = 0
    /// 默认展示当前月份
    @Published var startTime: String = DateHelpers.defaultStartTime
    @Published var endTime: String = DateHelpers.defaultEndTime
    @Published var typeFilter: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let incomeService = IncomeService()

    var totalPages: Int {
        guard pageSize > 0 else { return 0 }
        return (total + pageSize - 1) / pageSize
    }

    var canNextPage: Bool { page < totalPages }
    var canPreviousPage: Bool { page > 1 }

    func loadPage() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let res = try await incomeService.fetchIncomes(
                page: page,
                pageSize: pageSize,
                startTime: startTime.isEmpty ? nil : startTime,
                endTime: endTime.isEmpty ? nil : endTime,
                type: typeFilter.isEmpty ? nil : typeFilter
            )
            list = res.list
            total = res.total ?? 0
            if let p = res.page { page = p }
            if let ps = res.pageSize { pageSize = ps }
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            list = []
        }
    }

    func applyTimeFilterAndReload() async {
        page = 1
        await loadPage()
    }

    func nextPage() {
        guard canNextPage else { return }
        page += 1
        Task { await loadPage() }
    }

    func previousPage() {
        guard canPreviousPage else { return }
        page -= 1
        Task { await loadPage() }
    }

    func deleteIncome(id: Int) async {
        do {
            try await incomeService.deleteIncome(id: id)
            await loadPage()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
