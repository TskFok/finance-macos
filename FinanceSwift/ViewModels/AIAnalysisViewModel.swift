import Foundation

@MainActor
final class AIAnalysisViewModel: ObservableObject {
    @Published var models: [AIModel] = []
    @Published var selectedModelId: Int?
    @Published var startTime: String = DateHelpers.defaultStartTime
    @Published var endTime: String = DateHelpers.defaultEndTime
    @Published var currentResult: String = ""
    @Published var isStreaming = false
    @Published var history: [AIAnalysisHistoryItem] = []
    @Published var historyPage: Int = 1
    @Published var historyPageSize: Int = 20
    @Published var historyTotal: Int = 0
    @Published var isLoadingHistory = false
    @Published var isLoadingModels = false
    @Published var errorMessage: String?

    private let service = AIAnalysisService()

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
            let res = try await service.fetchAnalysisHistory(modelId: modelId, page: historyPage, pageSize: historyPageSize)
            history = res.list
            historyTotal = res.total ?? 0
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            history = []
        }
    }

    func startAnalysis() async {
        guard selectedModelId != nil else { return }
        currentResult = ""
        isStreaming = true
        errorMessage = nil
        defer { isStreaming = false }
        do {
            guard let modelId = selectedModelId else { return }
            for try await chunk in service.sendAnalysisStream(modelId: modelId, startTime: startTime, endTime: endTime) {
                currentResult += chunk
            }
            await loadHistory()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func deleteHistory(id: Int) async {
        do {
            try await service.deleteAnalysisHistory(id: id)
            await loadHistory()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
