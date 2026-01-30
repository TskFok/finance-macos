import Foundation

/// AI 数据分析：模型列表、分析历史（分页）、发起分析（SSE 流式）
@MainActor
final class AIAnalysisService: ObservableObject {
    private let client = APIClient()
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    private var token: String? { AuthService.shared.token }

    /// GET /api/v1/ai-models
    func fetchAIModels() async throws -> [AIModel] {
        let res: APIResponse<[AIModel]> = try await client.get(
            path: APIConfig.aiModelsPath,
            token: token
        )
        return res.data ?? []
    }

    /// GET /api/v1/ai-analysis/history?model_id=&page=&page_size=
    func fetchAnalysisHistory(modelId: Int, page: Int = 1, pageSize: Int = 20) async throws -> PageResponse<AIAnalysisHistoryItem> {
        let items: [URLQueryItem] = [
            URLQueryItem(name: "model_id", value: "\(modelId)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "page_size", value: "\(pageSize)")
        ]
        let res: APIResponse<PageResponse<AIAnalysisHistoryItem>> = try await client.get(
            path: APIConfig.aiAnalysisHistoryPath,
            queryItems: items,
            token: token
        )
        guard let data = res.data else {
            return PageResponse(list: [], page: page, pageSize: pageSize, total: 0)
        }
        return data
    }

    /// DELETE /api/v1/ai-analysis/history/{id}
    func deleteAnalysisHistory(id: Int) async throws {
        _ = try await client.delete(
            path: "\(APIConfig.aiAnalysisHistoryPath)/\(id)",
            token: token
        )
    }

    /// POST /api/v1/ai-analysis，SSE 流式返回，逐段产出 content
    func sendAnalysisStream(modelId: Int, startTime: String, endTime: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task { @MainActor in
                guard let url = makeURL(path: APIConfig.aiAnalysisPath) else {
                    continuation.finish(throwing: APIError.invalidResponse)
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                if let t = token {
                    request.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
                }
                let body = AnalysisRequest(startTime: startTime, endTime: endTime, modelId: modelId)
                request.httpBody = try? encoder.encode(body)

                do {
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                        let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                        continuation.finish(throwing: APIError.httpStatus(code, "请求失败"))
                        return
                    }
                    var dataBuffer = Data()
                    for try await byte in bytes {
                        dataBuffer.append(byte)
                        if byte == 0x0a {
                            guard let line = String(data: dataBuffer, encoding: .utf8)?
                                .trimmingCharacters(in: .whitespacesAndNewlines) else {
                                dataBuffer = Data()
                                continue
                            }
                            dataBuffer = Data()
                            if line.hasPrefix("data: ") {
                                let jsonStr = String(line.dropFirst(6))
                                if jsonStr == "[DONE]" || jsonStr.isEmpty { continue }
                                if let data = jsonStr.data(using: .utf8),
                                   let frame = try? decoder.decode(SSEDataFrame.self, from: data),
                                   frame.type == "delta", let content = frame.content, !content.isEmpty {
                                    continuation.yield(content)
                                }
                                if jsonStr.contains("\"type\":\"done\"") || jsonStr.contains("\"type\":\"error\"") {
                                    break
                                }
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func makeURL(path: String) -> URL? {
        let base = APIConfig.baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let pathNorm = path.hasPrefix("/") ? path : "/" + path
        return URL(string: base + pathNorm)
    }
}

private struct SSEDataFrame: Decodable {
    let type: String?
    let content: String?
}
