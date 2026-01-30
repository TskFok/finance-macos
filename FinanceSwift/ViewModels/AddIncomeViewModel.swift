import Foundation

@MainActor
final class AddIncomeViewModel: ObservableObject {
    @Published var amountText: String = ""
    @Published var type: String = ""
    @Published var incomeTime: Date = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didCreate = false

    var amount: Double? { Double(amountText.trimmingCharacters(in: .whitespacesAndNewlines)) }
    var canSubmit: Bool {
        amount != nil && amount! > 0 && !type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private let incomeService = IncomeService()
    private static let incomeTimeFormatter: DateFormatter = {
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
        let timeStr = Self.incomeTimeFormatter.string(from: incomeTime)
        do {
            _ = try await incomeService.createIncome(
                amount: amt,
                type: type.trimmingCharacters(in: .whitespacesAndNewlines),
                incomeTime: timeStr
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
