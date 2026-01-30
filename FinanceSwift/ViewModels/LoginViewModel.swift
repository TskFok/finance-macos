import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var loginSucceeded = false

    private let auth = AuthService.shared

    var canSubmit: Bool {
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !password.isEmpty
    }

    func login() async {
        guard canSubmit else { return }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await auth.login(username: username.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            loginSucceeded = true
        } catch let e as APIError {
            errorMessage = e.errorDescription ?? "登录失败"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
