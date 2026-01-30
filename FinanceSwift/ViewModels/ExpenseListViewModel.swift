import Foundation

@MainActor
final class ExpenseListViewModel: ObservableObject {
    @Published var list: [Expense] = []
    @Published var page: Int = 1
    @Published var pageSize: Int = 20
    @Published var total: Int = 0
    @Published var startTime: String = DateHelpers.defaultStartTime
    @Published var endTime: String = DateHelpers.defaultEndTime
    @Published var categoryFilter: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var categories: [ExpenseCategory] = []

    private let expenseService = ExpenseService()

    var totalPages: Int {
        guard pageSize > 0 else { return 0 }
        return (total + pageSize - 1) / pageSize
    }

    var canNextPage: Bool { page < totalPages }
    var canPreviousPage: Bool { page > 1 }

    func loadCategories() async {
        do {
            categories = try await expenseService.fetchCategories()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func loadPage() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let res = try await expenseService.fetchExpenses(
                page: page,
                pageSize: pageSize,
                startTime: startTime.isEmpty ? nil : startTime,
                endTime: endTime.isEmpty ? nil : endTime,
                category: categoryFilter.isEmpty ? nil : categoryFilter
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

    func deleteExpense(id: Int) async {
        do {
            try await expenseService.deleteExpense(id: id)
            await loadPage()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
