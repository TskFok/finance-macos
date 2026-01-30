import Foundation

/// 时间范围类型，对应接口 range_type
enum StatisticsRangeType: String, CaseIterable {
    case month = "month"
    case year = "year"
    case custom = "custom"
}

@MainActor
final class StatisticsViewModel: ObservableObject {
    @Published var categories: [ExpenseCategory] = []
    /// 选中的类别名称（空表示全部）
    @Published var selectedCategoryNames: Set<String> = []
    @Published var rangeType: StatisticsRangeType = .month
    @Published var yearMonth: String = DateHelpers.currentYearMonth
    @Published var year: String = DateHelpers.currentYear
    @Published var startTime: String = DateHelpers.defaultStartTime
    @Published var endTime: String = DateHelpers.defaultEndTime

    @Published var statistics: DetailedStatisticsResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let expenseService = ExpenseService()

    /// 类别筛选参数：不选则 nil（全部），否则逗号分隔
    var categoriesQuery: String? {
        guard !selectedCategoryNames.isEmpty else { return nil }
        return selectedCategoryNames.sorted().joined(separator: ",")
    }

    func loadCategories() async {
        do {
            categories = try await expenseService.fetchCategories()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func loadStatistics() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let res = try await expenseService.fetchDetailedStatistics(
                rangeType: rangeType.rawValue,
                yearMonth: rangeType == .month ? yearMonth : nil,
                year: rangeType == .year ? year : nil,
                startTime: rangeType == .custom ? startTime : nil,
                endTime: rangeType == .custom ? endTime : nil,
                categories: categoriesQuery
            )
            statistics = res
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            statistics = nil
        }
    }

    func toggleCategory(_ name: String) {
        if selectedCategoryNames.contains(name) {
            selectedCategoryNames.remove(name)
        } else {
            selectedCategoryNames.insert(name)
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
