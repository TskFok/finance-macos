import SwiftUI

struct AIChatView: View {
    @StateObject private var viewModel = AIChatViewModel()

    var body: some View {
        VStack(spacing: 0) {
            modelBar
            if let msg = viewModel.errorMessage {
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
            Divider()
            if viewModel.isStreaming || !viewModel.currentReply.isEmpty {
                currentReplySection
            }
            inputBar
            Divider()
            historySection
        }
        .navigationTitle("AI 聊天")
        .task {
            await viewModel.loadModels()
        }
        .onChange(of: viewModel.selectedModelId) { _, _ in
            viewModel.historyPage = 1
            Task { await viewModel.loadHistory() }
        }
    }

    private var modelBar: some View {
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
            .frame(minWidth: 160)
            .disabled(viewModel.isLoadingModels)

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
    }

    private var currentReplySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text("AI 回复")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            ScrollViewReader { proxy in
                ScrollView {
                    Text(viewModel.currentReply.isEmpty ? "…" : viewModel.currentReply)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(AppTheme.paddingM)
                        .id("reply")
                }
                .onChange(of: viewModel.currentReply) { _, _ in
                    withAnimation(.easeOut(duration: 0.1)) {
                        proxy.scrollTo("reply", anchor: .bottom)
                    }
                }
            }
            .frame(minHeight: 80, maxHeight: 220)
        }
        .appCard()
        .padding(.horizontal, AppTheme.paddingM)
    }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: AppTheme.spacingM) {
            TextField("输入消息…", text: $viewModel.inputMessage, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(8)
                .lineLimit(2...6)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            Button("发送") {
                Task { await viewModel.sendMessage() }
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .frame(width: 72)
            .disabled(viewModel.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || viewModel.selectedModelId == nil
                || viewModel.isStreaming)
        }
        .padding(AppTheme.paddingM)
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("聊天历史")
                    .font(.headline.weight(.semibold))
                Spacer()
                Text("共 \(viewModel.historyTotal) 条")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, AppTheme.paddingM)
            .padding(.vertical, AppTheme.paddingS)

            if viewModel.isLoadingHistory && viewModel.history.isEmpty {
                ProgressView("加载中…")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.history.isEmpty {
                Text("暂无历史，选择模型后发送消息或点击「加载历史」")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.history) { item in
                        AIChatHistoryRowView(item: item) {
                            Task { await viewModel.deleteHistory(id: item.id) }
                        }
                    }
                }
                .listStyle(.inset)

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
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
        }
        .frame(minHeight: 120)
    }
}

struct AIChatHistoryRowView: View {
    let item: AIChatHistoryItem
    let onDelete: () -> Void
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let user = item.userText, !user.isEmpty {
                Text(user)
                    .font(.subheadline)
                    .lineLimit(2)
            }
            if let reply = item.aiText, !reply.isEmpty {
                Text(reply)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            if let created = item.createdAt {
                Text(created)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
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
            Text("确定删除这条聊天记录？")
        }
    }
}

#Preview {
    AIChatView()
        .frame(width: 500, height: 560)
}
