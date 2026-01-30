import SwiftUI

/// 收入类型选项（API 无类别列表，使用固定选项）
private let incomeTypeOptions = ["工资", "奖金", "兼职", "理财", "其他"]

struct IncomeListView: View {
    @StateObject private var viewModel = IncomeListViewModel()
    @State private var showAddIncome = false

    var body: some View {
        VStack(spacing: 0) {
            timeFilterBar
            if let msg = viewModel.errorMessage {
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
            if viewModel.isLoading && viewModel.list.isEmpty {
                ProgressView("加载中…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.list.isEmpty {
                Text("暂无收入记录")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                listContent
            }
            paginationBar
        }
        .navigationTitle("收入列表")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("添加收入") {
                    showAddIncome = true
                }
            }
        }
        .task {
            await viewModel.loadPage()
        }
        .sheet(isPresented: $showAddIncome) {
            AddIncomeView(incomeTypes: incomeTypeOptions) {
                showAddIncome = false
                Task { await viewModel.loadPage() }
            }
        }
    }

    private var timeFilterBar: some View {
        HStack(spacing: AppTheme.spacingM) {
            Text("开始")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            TextField("2024-01-01", text: $viewModel.startTime)
                .textFieldStyle(.plain)
                .padding(6)
                .frame(width: 108)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            Text("结束")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            TextField("2024-01-31", text: $viewModel.endTime)
                .textFieldStyle(.plain)
                .padding(6)
                .frame(width: 108)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            Picker("类型", selection: $viewModel.typeFilter) {
                Text("全部").tag("")
                ForEach(incomeTypeOptions, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 100)
            Button("查询") {
                Task { await viewModel.applyTimeFilterAndReload() }
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .frame(width: 72)
        }
        .padding(AppTheme.paddingM)
        .appFilterBar()
    }

    private var listContent: some View {
        List {
            ForEach(viewModel.list) { item in
                IncomeRowView(income: item) {
                    Task {
                        await viewModel.deleteIncome(id: item.id)
                    }
                }
                .listRowInsets(EdgeInsets(top: 6, leading: AppTheme.paddingM, bottom: 6, trailing: AppTheme.paddingM))
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
    }

    private var paginationBar: some View {
        HStack(spacing: AppTheme.spacingM) {
            Button("上一页") {
                viewModel.previousPage()
            }
            .buttonStyle(AppTheme.SecondaryButtonStyle())
            .disabled(!viewModel.canPreviousPage)
            Text("第 \(viewModel.page) / \(max(1, viewModel.totalPages)) 页，共 \(viewModel.total) 条")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("下一页") {
                viewModel.nextPage()
            }
            .buttonStyle(AppTheme.SecondaryButtonStyle())
            .disabled(!viewModel.canNextPage)
        }
        .padding(AppTheme.paddingM)
    }
}

struct IncomeRowView: View {
    let income: Income
    let onDelete: () -> Void
    @State private var showDeleteConfirm = false

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            VStack(alignment: .leading, spacing: 4) {
                Text(income.type)
                    .font(.subheadline.weight(.semibold))
                if let t = income.incomeTime {
                    Text(t)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
            Text(String(format: "¥%.2f", income.amount))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
        }
        .padding(AppTheme.paddingM)
        .background(Color(nsColor: .windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .confirmationDialog("删除收入", isPresented: $showDeleteConfirm) {
            Button("删除", role: .destructive, action: onDelete)
            Button("取消", role: .cancel) {}
        } message: {
            Text("确定删除该条收入记录？")
        }
    }
}

#Preview {
    IncomeListView()
        .frame(width: 500, height: 400)
}
