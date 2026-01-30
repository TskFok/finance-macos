import Foundation

/// 认证服务：登录、登出、Token 与当前用户持久化
@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published private(set) var currentUser: User?
    @Published private(set) var token: String?

    private let client = APIClient()
    private let tokenKey = "finance_app_token"
    private let userKey = "finance_app_user"

    private init() {
        token = UserDefaults.standard.string(forKey: tokenKey)
        if let data = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        } else {
            currentUser = nil
        }
    }

    var isLoggedIn: Bool {
        token != nil
    }

    /// 调用 POST /api/v1/auth/login，成功后保存 token 和 user_info
    func login(username: String, password: String) async throws {
        let req = LoginRequest(username: username, password: password)
        let res: APIResponse<LoginResponse> = try await client.post(
            path: APIConfig.loginPath,
            body: req
        )
        guard let data = res.data else {
            throw APIError.httpStatus(res.code ?? -1, res.message ?? "登录失败")
        }
        token = data.token
        currentUser = data.userInfo
        UserDefaults.standard.set(data.token, forKey: tokenKey)
        if let user = data.userInfo, let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userKey)
        } else {
            UserDefaults.standard.removeObject(forKey: userKey)
        }
    }

    func logout() {
        token = nil
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
    }
}
