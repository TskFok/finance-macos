import Foundation

/// 接口返回 401 时发送，AuthService 监听后执行登出并退回登录页
extension Notification.Name {
    static let apiUnauthorized = Notification.Name("APIUnauthorized")
}

/// 封装 HTTP 请求，对应 doc 中 POST /api/v1/auth/login 等
final class APIClient: Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()

    init(baseURL: URL = APIConfig.baseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    /// 构建绝对 URL，避免相对 URL 导致「不支持的URL」
    private func makeURL(path: String, queryItems: [URLQueryItem] = []) -> URL? {
        let pathNorm = path.hasPrefix("/") ? path : "/" + path
        let baseStr = baseURL.absoluteString.hasSuffix("/") ? String(baseURL.absoluteString.dropLast()) : baseURL.absoluteString
        let fullStr = baseStr + pathNorm
        guard var components = URLComponents(string: fullStr) else { return nil }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        return components.url
    }

    /// 发起 JSON POST，解析为 APIResponse<T>
    /// 接口文档：200 成功，400 参数错误，401 用户名或密码错误
    func post<T: Decodable>(
        path: String,
        body: some Encodable,
        token: String? = nil
    ) async throws -> APIResponse<T> {
        guard let url = makeURL(path: path) else {
            throw APIError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if http.statusCode == 401 {
            DispatchQueue.main.async { NotificationCenter.default.post(name: .apiUnauthorized, object: nil) }
        }

        let decoded: APIResponse<T>
        do {
            decoded = try decoder.decode(APIResponse<T>.self, from: data)
        } catch {
            if http.statusCode != 200 {
                throw APIError.httpStatus(http.statusCode, "请求失败")
            }
            throw error
        }

        if http.statusCode != 200 {
            throw APIError.httpStatus(http.statusCode, decoded.message ?? "请求失败")
        }
        return decoded
    }

    /// GET 请求，带 query 参数，解析为 APIResponse<T>
    func get<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        token: String? = nil
    ) async throws -> APIResponse<T> {
        guard let url = makeURL(path: path, queryItems: queryItems) else {
            throw APIError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if http.statusCode == 401 {
            DispatchQueue.main.async { NotificationCenter.default.post(name: .apiUnauthorized, object: nil) }
        }

        let decoded: APIResponse<T>
        do {
            decoded = try decoder.decode(APIResponse<T>.self, from: data)
        } catch {
            if http.statusCode != 200 {
                throw APIError.httpStatus(http.statusCode, "请求失败")
            }
            throw error
        }

        if http.statusCode != 200 {
            throw APIError.httpStatus(http.statusCode, decoded.message ?? "请求失败")
        }
        return decoded
    }

    /// DELETE 请求，path 需包含 id，如 /api/v1/expenses/123
    func delete(path: String, token: String? = nil) async throws -> APIResponse<EmptyData> {
        guard let url = makeURL(path: path) else {
            throw APIError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if http.statusCode == 401 {
            DispatchQueue.main.async { NotificationCenter.default.post(name: .apiUnauthorized, object: nil) }
        }

        let decoded: APIResponse<EmptyData>
        do {
            decoded = try decoder.decode(APIResponse<EmptyData>.self, from: data)
        } catch {
            if http.statusCode != 200 {
                throw APIError.httpStatus(http.statusCode, "请求失败")
            }
            throw error
        }

        if http.statusCode != 200 {
            throw APIError.httpStatus(http.statusCode, decoded.message ?? "请求失败")
        }
        return decoded
    }
}

/// 无 data 的响应体（如删除成功）
struct EmptyData: Codable {}

enum APIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int, String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "无效的响应"
        case .httpStatus(let code, let msg): return "\(code): \(msg)"
        }
    }
}
