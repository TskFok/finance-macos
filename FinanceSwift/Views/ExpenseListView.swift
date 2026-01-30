import SwiftUI

struct ExpenseListView: View {
    @StateObject private var viewModel = ExpenseListViewModel()
    @State private var showAddExpense = false

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
                Text("暂无支出记录")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                listContent
            }
            paginationBar
        }
        .navigationTitle("支出列表")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("添加支出") {
                    showAddExpense = true
                }
            }
        }
        .task {
            await viewModel.loadCategories()
            await viewModel.loadPage()
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView(categories: viewModel.categories) {
                showAddExpense = false
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
            Picker("类别", selection: $viewModel.categoryFilter) {
                Text("全部").tag("")
                ForEach(viewModel.categories) { cat in
                    Text(cat.name).tag(cat.name)
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
                ExpenseRowView(expense: item) {
                    Task {
                        await viewModel.deleteExpense(id: item.id)
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

struct ExpenseRowView: View {
    let expense: Expense
    let onDelete: () -> Void
    @State private var showDeleteConfirm = false

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category)
                    .font(.subheadline.weight(.semibold))
                if let d = expense.description, !d.isEmpty {
                    Text(d)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let t = expense.expenseTime {
                    Text(t)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
            Text(String(format: "¥%.2f", expense.amount))
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
        .confirmationDialog("删除支出", isPresented: $showDeleteConfirm) {
            Button("删除", role: .destructive, action: onDelete)
            Button("取消", role: .cancel) {}
        } message: {
            Text("确定删除该条支出记录？")
        }
    }
}

#Preview {
    ExpenseListView()
        .frame(width: 500, height: 400)
}
