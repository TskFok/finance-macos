import Foundation

/// API 配置。baseURL 不写死在代码中，防止生产环境内容被提交到 GitHub。
/// 优先级：环境变量 API_BASE_URL > API-Secrets.plist > API-Secrets.example.plist > 默认 localhost
enum APIConfig {
    private static let envBaseURLKey = "API_BASE_URL"
    private static let plistBaseURLKey = "BaseURL"
    private static let defaultBaseURLString = "http://localhost:8080"

    /// API 根地址。从环境变量或 plist 读取，未配置时使用 localhost。
    static var baseURL: URL {
        if let env = ProcessInfo.processInfo.environment[envBaseURLKey], !env.isEmpty,
           let url = URL(string: env.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return url
        }
        if let urlString = loadBaseURLFromPlist(name: "API-Secrets"),
           let url = URL(string: urlString) {
            return url
        }
        if let urlString = loadBaseURLFromPlist(name: "API-Secrets.example"),
           let url = URL(string: urlString) {
            return url
        }
        return URL(string: defaultBaseURLString)!
    }

    private static func loadBaseURLFromPlist(name: String) -> String? {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let value = dict[plistBaseURLKey] as? String, !value.isEmpty else {
            return nil
        }
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - 路径（可提交，无敏感信息）
    static var loginPath: String { "/api/v1/auth/login" }
    static var expensesPath: String { "/api/v1/expenses" }
    static var categoriesPath: String { "/api/v1/categories" }
    static var incomesPath: String { "/api/v1/incomes" }
    static var detailedStatisticsPath: String { "/api/v1/expenses/detailed-statistics" }
    static var aiModelsPath: String { "/api/v1/ai-models" }
    static var aiChatPath: String { "/api/v1/ai-chat" }
    static var aiChatHistoryPath: String { "/api/v1/ai-chat/history" }
    static var aiAnalysisPath: String { "/api/v1/ai-analysis" }
    static var aiAnalysisHistoryPath: String { "/api/v1/ai-analysis/history" }
}
