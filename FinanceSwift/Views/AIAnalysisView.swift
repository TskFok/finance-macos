import SwiftUI

struct AIAnalysisView: View {
    @StateObject private var viewModel = AIAnalysisViewModel()

    var body: some View {
        VStack(spacing: 0) {
            modelAndTimeBar
            if let msg = viewModel.errorMessage {
                Text(msg)
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(AppTheme.destructive)
                    .padding(.horizontal)
            }
            Divider()
            resultSection
            analysisButton
            Divider()
            historySection
        }
        .navigationTitle("AI 数据分析")
        .task {
            await viewModel.loadModels()
        }
        .onChange(of: viewModel.selectedModelId) { _, _ in
            viewModel.historyPage = 1
            Task { await viewModel.loadHistory() }
        }
    }

    private var modelAndTimeBar: some View {
        HStack(spacing: AppTheme.spacingM) {
            Picker("AI 模型", selection: Binding(
                get: { viewModel.selectedModelId ?? 0 },
                set: { viewModel.selectedModelId = $0 == 0 ? nil : $0 }
            )) {
                Text("请选择模型").tag(0)
                ForEach(viewModel.models) { model in
                    Text(model.name).tag(model.id)
                }
            }
            .pickerStyle(.menu)
            .frame(minWidth: 140)
            .disabled(viewModel.isLoadingModels)

            Text("时间范围")
                .font(AppTheme.Font.subheadline(.medium))
                .foregroundStyle(AppTheme.textSecondary)
            TextField("开始", text: $viewModel.startTime, prompt: Text("2024-01-01"))
                .textFieldStyle(.plain)
                .foregroundStyle(AppTheme.textPrimary)
                .frame(width: 98)
                .appTechInput()
            Text("至")
                .font(AppTheme.Font.subheadline(.medium))
                .foregroundStyle(AppTheme.textSecondary)
            TextField("结束", text: $viewModel.endTime, prompt: Text("2024-12-31"))
                .textFieldStyle(.plain)
                .foregroundStyle(AppTheme.textPrimary)
                .frame(width: 98)
                .appTechInput()

            if viewModel.isLoadingModels {
                ProgressView()
                    .scaleEffect(0.8)
            }
            Button("加载历史") {
                Task { await viewModel.loadHistory() }
            }
            .buttonStyle(AppTheme.SecondaryButtonStyle())
            .disabled(viewModel.selectedModelId == nil || viewModel.isLoadingHistory)
            Spacer()
        }
        .padding(AppTheme.paddingM)
        .appFilterBar()
        .padding(.top, AppTheme.listHorizontalInset)
        .padding(.horizontal, AppTheme.listHorizontalInset)
        .padding(.bottom, AppTheme.spacingM)
    }

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text("分析结果")
                .font(AppTheme.Font.subheadline(.semibold))
                .foregroundStyle(AppTheme.textSecondary)
            ScrollViewReader { proxy in
                ScrollView {
                    Text(viewModel.currentResult.isEmpty ? "…" : viewModel.currentResult)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(AppTheme.paddingM)
                        .id("result")
                }
                .onChange(of: viewModel.currentResult) { _, _ in
                    withAnimation(.easeOut(duration: 0.1)) {
                        proxy.scrollTo("result", anchor: .bottom)
                    }
                }
            }
            .frame(minHeight: 80, maxHeight: 240)
        }
        .appCard()
        .padding(.top, AppTheme.listHorizontalInset)
        .padding(.horizontal, AppTheme.paddingM)
    }

    private var analysisButton: some View {
        HStack {
            Button("开始分析") {
                Task { await viewModel.startAnalysis() }
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .frame(width: 100)
            .disabled(viewModel.selectedModelId == nil || viewModel.isStreaming)
            if viewModel.isStreaming {
                ProgressView()
                    .scaleEffect(0.8)
                    .padding(.leading, AppTheme.paddingS)
            }
            Spacer()
        }
        .padding(AppTheme.paddingM)
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("分析历史")
                    .font(AppTheme.Font.headline(.semibold))
                Spacer()
                Text("共 \(viewModel.historyTotal) 条")
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(.horizontal, AppTheme.paddingM)
            .padding(.vertical, AppTheme.paddingS)

            Group {
                if viewModel.isLoadingHistory && viewModel.history.isEmpty {
                    ProgressView("加载中…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.history.isEmpty {
                    Text("暂无历史，选择模型与时间后点击「开始分析」或「加载历史」")
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.history) { item in
                            AIAnalysisHistoryRowView(item: item) {
                                Task { await viewModel.deleteHistory(id: item.id) }
                            }
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .frame(height: 200)

            HStack(spacing: AppTheme.spacingM) {
                Button("上一页") {
                    if viewModel.historyPage > 1 {
                        viewModel.historyPage -= 1
                        Task { await viewModel.loadHistory() }
                    }
                }
                .buttonStyle(AppTheme.SecondaryButtonStyle())
                .disabled(viewModel.historyPage <= 1)
                Text("第 \(viewModel.historyPage) / \(max(1, viewModel.totalPages)) 页")
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(AppTheme.textSecondary)
                Button("下一页") {
                    if viewModel.historyPage < viewModel.totalPages {
                        viewModel.historyPage += 1
                        Task { await viewModel.loadHistory() }
                    }
                }
                .buttonStyle(AppTheme.SecondaryButtonStyle())
                .disabled(viewModel.historyPage >= viewModel.totalPages)
            }
            .padding(AppTheme.paddingM)
        }
        .frame(minHeight: 120)
    }
}

struct AIAnalysisHistoryRowView: View {
    let item: AIAnalysisHistoryItem
    let onDelete: () -> Void
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let start = item.startDate, let end = item.endDate {
                Text("\(start) 至 \(end)")
                    .font(AppTheme.Font.subheadline())
            }
            if let result = item.result, !result.isEmpty {
                Text(result)
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(3)
            }
            if let created = item.createdAt {
                Text(created)
                    .font(AppTheme.Font.caption2())
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: {
                showDeleteConfirm = true
            }) {
                Label("删除", systemImage: "trash")
            }
        }
        .confirmationDialog("删除记录", isPresented: $showDeleteConfirm) {
            Button("删除", role: .destructive, action: onDelete)
            Button("取消", role: .cancel) {}
        } message: {
            Text("确定删除这条分析记录？")
        }
    }
}

#Preview {
    AIAnalysisView()
        .frame(width: 520, height: 560)
}
