import SwiftUI

struct ExpenseListView: View {
    @StateObject private var viewModel = ExpenseListViewModel()
    @State private var showAddExpense = false

    var body: some View {
        VStack(spacing: 0) {
            timeFilterBar
            if let msg = viewModel.errorMessage {
                Text(msg)
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(AppTheme.destructive)
                    .padding(.horizontal)
            }
            if viewModel.isLoading && viewModel.list.isEmpty {
                ProgressView("加载中…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.list.isEmpty {
                Text("暂无支出记录")
                    .foregroundStyle(AppTheme.textSecondary)
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
                .font(AppTheme.Font.subheadline(.medium))
                .foregroundStyle(AppTheme.textSecondary)
            TextField("2024-01-01", text: $viewModel.startTime)
                .textFieldStyle(.plain)
                .foregroundStyle(AppTheme.textPrimary)
                .frame(width: 108)
                .appTechInput()
            Text("结束")
                .font(AppTheme.Font.subheadline(.medium))
                .foregroundStyle(AppTheme.textSecondary)
            TextField("2024-01-31", text: $viewModel.endTime)
                .textFieldStyle(.plain)
                .foregroundStyle(AppTheme.textPrimary)
                .frame(width: 108)
                .appTechInput()
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
            Spacer()
        }
        .padding(AppTheme.paddingM)
        .appFilterBar()
        .padding(.top, AppTheme.listHorizontalInset)
        .padding(.horizontal, AppTheme.listHorizontalInset)
        .padding(.bottom, AppTheme.spacingM)
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
        .padding(.horizontal, AppTheme.listHorizontalInset)
    }

    private var paginationBar: some View {
        HStack(spacing: AppTheme.spacingM) {
            Button("上一页") {
                viewModel.previousPage()
            }
            .buttonStyle(AppTheme.SecondaryButtonStyle())
            .disabled(!viewModel.canPreviousPage)
            Text("第 \(viewModel.page) / \(max(1, viewModel.totalPages)) 页，共 \(viewModel.total) 条")
                .font(AppTheme.Font.caption())
                .foregroundStyle(AppTheme.textSecondary)
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
                    .font(AppTheme.Font.subheadline(.semibold))
                if let d = expense.description, !d.isEmpty {
                    Text(d)
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(AppTheme.textSecondary)
                }
                if let t = expense.expenseTime {
                    Text(t)
                        .font(AppTheme.Font.caption2())
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }
            Spacer()
            Text(String(format: "¥%.2f", expense.amount))
                .font(AppTheme.Font.subheadline(.semibold))
                .foregroundStyle(AppTheme.accent)
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
        }
        .appCard(padding: AppTheme.paddingM)
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
