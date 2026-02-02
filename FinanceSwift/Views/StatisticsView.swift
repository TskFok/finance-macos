import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            filterBar
            if let msg = viewModel.errorMessage {
                Text(msg)
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(AppTheme.destructive)
                    .padding(.horizontal)
            }
            if viewModel.isLoading && viewModel.statistics == nil {
                ProgressView("加载中…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let stats = viewModel.statistics {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                        summarySection(stats)
                        if !stats.categoryStats.isEmpty {
                            EChartsWebView(stats: stats)
                                .appCard()
                        } else {
                            Text("该条件下暂无消费数据")
                                .font(AppTheme.Font.subheadline())
                                .foregroundStyle(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(AppTheme.paddingL)
                        }
                    }
                    .padding(AppTheme.paddingM)
                }
            } else {
                Text("暂无数据，可修改时间或类别后点击「查询」")
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("消费统计")
        .task {
            await viewModel.loadCategories()
            await viewModel.loadStatistics()
        }
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            HStack(spacing: AppTheme.spacingM) {
                TimeRangeFilterView(
                    startTime: $viewModel.startTime,
                    endTime: $viewModel.endTime,
                    onApply: { Task { await viewModel.loadStatistics() } },
                    showQueryButton: true
                )
                Spacer()
            }

            HStack(alignment: .top, spacing: AppTheme.spacingS) {
                Text("类别筛选：")
                    .font(AppTheme.Font.caption(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                FlowLayout(spacing: 6) {
                    ForEach(viewModel.categories) { cat in
                        Toggle(cat.name, isOn: Binding(
                            get: { viewModel.selectedCategoryNames.contains(cat.name) },
                            set: { _ in viewModel.toggleCategory(cat.name) }
                        ))
                        .toggleStyle(.button)
                    }
                }
            }
        }
        .padding(AppTheme.paddingM)
        .appFilterBar()
        .padding(.top, AppTheme.listHorizontalInset)
        .padding(.horizontal, AppTheme.listHorizontalInset)
        .padding(.bottom, AppTheme.spacingM)
    }

    private func summarySection(_ stats: DetailedStatisticsResponse) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text("汇总")
                .font(AppTheme.Font.subheadline(.semibold))
                .foregroundStyle(AppTheme.textSecondary)
            HStack(spacing: AppTheme.spacingL) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("总金额")
                        .font(AppTheme.Font.caption(.medium))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(String(format: "¥%.2f", stats.totalAmount))
                        .font(AppTheme.Font.title2(.semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("总笔数")
                        .font(AppTheme.Font.caption(.medium))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("\(stats.totalCount)")
                        .font(AppTheme.Font.title2(.semibold))
                }
                Spacer()
            }
        }
        .appCard()
    }
}

/// 简单流式布局，用于类别多选
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var positions: [CGPoint] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        let totalHeight = y + rowHeight
        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}

#Preview {
    StatisticsView()
        .frame(width: 560, height: 500)
}
