import Foundation

@MainActor
final class AddExpenseViewModel: ObservableObject {
    @Published var amountText: String = ""
    @Published var category: String = ""
    @Published var expenseTime: Date = Date()
    @Published var descriptionText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didCreate = false

    var amount: Double? { Double(amountText.trimmingCharacters(in: .whitespacesAndNewlines)) }
    var canSubmit: Bool {
        amount != nil && amount! > 0 && !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private let expenseService = ExpenseService()
    private static let expenseTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        return f
    }()

    func submit() async {
        guard canSubmit, let amt = amount else { return }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        let timeStr = Self.expenseTimeFormatter.string(from: expenseTime)
        do {
            _ = try await expenseService.createExpense(
                amount: amt,
                category: category.trimmingCharacters(in: .whitespacesAndNewlines),
                expenseTime: timeStr,
                description: descriptionText.isEmpty ? nil : descriptionText
            )
            didCreate = true
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
