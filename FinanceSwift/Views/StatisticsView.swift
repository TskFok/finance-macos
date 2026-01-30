import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            filterBar
            if let msg = viewModel.errorMessage {
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(.red)
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
                            pieChartSection(stats.categoryStats)
                            barChartSection(stats.categoryStats)
                        } else {
                            Text("该条件下暂无消费数据")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(AppTheme.paddingL)
                        }
                    }
                    .padding(AppTheme.paddingM)
                }
            } else {
                Text("暂无数据，可修改时间或类别后点击「查询」")
                    .foregroundStyle(.secondary)
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
                Picker("时间范围", selection: $viewModel.rangeType) {
                    Text("按月").tag(StatisticsRangeType.month)
                    Text("按年").tag(StatisticsRangeType.year)
                    Text("自定义").tag(StatisticsRangeType.custom)
                }
                .pickerStyle(.segmented)
                .frame(width: 220)

                switch viewModel.rangeType {
                case .month:
                    TextField("年月", text: $viewModel.yearMonth, prompt: Text("2024-01"))
                        .textFieldStyle(.plain)
                        .padding(6)
                        .frame(width: 88)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                case .year:
                    TextField("年份", text: $viewModel.year, prompt: Text("2024"))
                        .textFieldStyle(.plain)
                        .padding(6)
                        .frame(width: 68)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                case .custom:
                    TextField("开始", text: $viewModel.startTime, prompt: Text("2024-01-01"))
                        .textFieldStyle(.plain)
                        .padding(6)
                        .frame(width: 98)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                    Text("至")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    TextField("结束", text: $viewModel.endTime, prompt: Text("2024-12-31"))
                        .textFieldStyle(.plain)
                        .padding(6)
                        .frame(width: 98)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                }

                Button("查询") {
                    Task { await viewModel.loadStatistics() }
                }
                .buttonStyle(AppTheme.PrimaryButtonStyle())
                .frame(width: 72)
            }

            HStack(alignment: .top, spacing: AppTheme.spacingS) {
                Text("类别筛选：")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
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
    }

    private func summarySection(_ stats: DetailedStatisticsResponse) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text("汇总")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(spacing: AppTheme.spacingL) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("总金额")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(String(format: "¥%.2f", stats.totalAmount))
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("总笔数")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text("\(stats.totalCount)")
                        .font(.title2.weight(.semibold))
                }
                Spacer()
            }
        }
        .appCard()
    }

    private func pieChartSection(_ categoryStats: [CategoryStat]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text("按类别占比（饼图）")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Chart(categoryStats) { stat in
                SectorMark(
                    angle: .value("金额", stat.total),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("类别", stat.category))
            }
            .chartLegend(position: .bottom, spacing: 8)
            .frame(height: 260)
        }
        .appCard()
    }

    private func barChartSection(_ categoryStats: [CategoryStat]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text("按类别金额（柱状图）")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Chart(categoryStats) { stat in
                BarMark(
                    x: .value("类别", stat.category),
                    y: .value("金额", stat.total)
                )
                .foregroundStyle(by: .value("类别", stat.category))
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .chartLegend(position: .bottom, spacing: 8)
            .frame(height: 260)
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
