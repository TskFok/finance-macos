import Foundation

@MainActor
final class AIChatViewModel: ObservableObject {
    @Published var models: [AIModel] = []
    @Published var selectedModelId: Int?
    @Published var inputMessage: String = ""
    @Published var currentReply: String = ""
    @Published var isStreaming = false
    @Published var history: [AIChatHistoryItem] = []
    @Published var historyPage: Int = 1
    @Published var historyPageSize: Int = 20
    @Published var historyTotal: Int = 0
    @Published var isLoadingHistory = false
    @Published var isLoadingModels = false
    @Published var errorMessage: String?

    private let service = AIChatService()

    var totalPages: Int {
        guard historyPageSize > 0 else { return 0 }
        return (historyTotal + historyPageSize - 1) / historyPageSize
    }

    func loadModels() async {
        isLoadingModels = true
        errorMessage = nil
        defer { isLoadingModels = false }
        do {
            models = try await service.fetchAIModels()
            if selectedModelId == nil, let first = models.first {
                selectedModelId = first.id
            }
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func loadHistory() async {
        guard let modelId = selectedModelId else { return }
        isLoadingHistory = true
        errorMessage = nil
        defer { isLoadingHistory = false }
        do {
            let res = try await service.fetchChatHistory(modelId: modelId, page: historyPage, pageSize: historyPageSize)
            history = res.list
            historyTotal = res.total ?? 0
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            history = []
        }
    }

    func sendMessage() async {
        let text = inputMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let modelId = selectedModelId else { return }
        inputMessage = ""
        currentReply = ""
        isStreaming = true
        errorMessage = nil
        defer { isStreaming = false }
        do {
            for try await chunk in service.sendChatStream(modelId: modelId, message: text) {
                currentReply += chunk
            }
            await loadHistory()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func deleteHistory(id: Int) async {
        do {
            try await service.deleteChatHistory(id: id)
            await loadHistory()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
