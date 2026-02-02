import SwiftUI

/// 时间范围预设
enum TimeRangePreset: String, CaseIterable {
    case today = "今天"
    case last7 = "近7天"
    case last30 = "近30天"
    case thisMonth = "本月"
    case lastMonth = "上月"
    case custom = "自定义"

    var range: (start: String, end: String) {
        switch self {
        case .today: return DateHelpers.todayRange
        case .last7: return DateHelpers.last7DaysRange
        case .last30: return DateHelpers.last30DaysRange
        case .thisMonth: return DateHelpers.thisMonthRange
        case .lastMonth: return DateHelpers.lastMonthRange
        case .custom: return (DateHelpers.defaultStartTime, DateHelpers.defaultEndTime)
        }
    }
}

/// 现代化时间筛选：预设快捷 + 自定义日期选择
struct TimeRangeFilterView: View {
    @Binding var startTime: String
    @Binding var endTime: String
    var onApply: (() -> Void)? = nil
    var showQueryButton: Bool = true

    @State private var selectedPreset: TimeRangePreset = .thisMonth
    @State private var customStartDate: Date = DateHelpers.startOfCurrentMonth
    @State private var customEndDate: Date = DateHelpers.endOfCurrentMonth
    @State private var showStartPicker = false
    @State private var showEndPicker = false

    private var presetChips: [TimeRangePreset] {
        [.today, .last7, .last30, .thisMonth, .lastMonth, .custom]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            HStack(spacing: AppTheme.spacingS) {
                Text("时间")
                    .font(AppTheme.Font.subheadline(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 32, alignment: .leading)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.spacingS) {
                        ForEach(presetChips, id: \.rawValue) { preset in
                            presetChip(preset)
                        }
                    }
                    .padding(.vertical, 2)
                }

                if showQueryButton, let onApply = onApply {
                    Button("查询") {
                        syncCustomDatesFromStrings()
                        onApply()
                    }
                    .buttonStyle(AppTheme.PrimaryButtonStyle())
                    .frame(width: 72)
                }
            }

            if selectedPreset == .custom {
                customRangeRow
            }
        }
        .onAppear {
            updatePresetFromStrings()
            syncCustomDatesFromStrings()
        }
        .onChange(of: startTime) { _, _ in updatePresetFromStrings() }
        .onChange(of: endTime) { _, _ in updatePresetFromStrings() }
    }

    private func presetChip(_ preset: TimeRangePreset) -> some View {
        let isSelected = selectedPreset == preset
        return Button {
            selectedPreset = preset
            if preset != .custom {
                let r = preset.range
                startTime = r.start
                endTime = r.end
                onApply?()
            } else {
                syncCustomDatesFromStrings()
            }
        } label: {
            Text(preset.rawValue)
                .font(AppTheme.Font.caption(.medium))
                .foregroundStyle(isSelected ? AppTheme.backgroundPrimary : AppTheme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(isSelected ? AppTheme.accent : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(isSelected ? AppTheme.accent : AppTheme.border, lineWidth: 1)
                )
        )
    }

    private var customRangeRow: some View {
        HStack(spacing: AppTheme.spacingM) {
            dateField(
                value: startTime,
                label: "开始",
                date: customStartDate,
                isPresented: $showStartPicker
            ) { newDate in
                customStartDate = newDate
                startTime = DateHelpers.formatDate(newDate)
                if customEndDate < newDate {
                    customEndDate = newDate
                    endTime = startTime
                }
            }

            Text("至")
                .font(AppTheme.Font.subheadline(.medium))
                .foregroundStyle(AppTheme.textSecondary)

            dateField(
                value: endTime,
                label: "结束",
                date: customEndDate,
                isPresented: $showEndPicker
            ) { newDate in
                customEndDate = newDate
                endTime = DateHelpers.formatDate(newDate)
                if customStartDate > newDate {
                    customStartDate = newDate
                    startTime = endTime
                }
            }
        }
        .padding(.top, 4)
    }

    private func dateField(
        value: String,
        label: String,
        date: Date,
        isPresented: Binding<Bool>,
        onSelect: @escaping (Date) -> Void
    ) -> some View {
        HStack(spacing: AppTheme.spacingS) {
            Text(label)
                .font(AppTheme.Font.caption(.medium))
                .foregroundStyle(AppTheme.textSecondary)
            Button {
                isPresented.wrappedValue = true
            } label: {
                HStack(spacing: 6) {
                    Text(value)
                        .font(AppTheme.Font.subheadline())
                        .foregroundStyle(AppTheme.textPrimary)
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textTertiary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(AppTheme.backgroundSecondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .popover(isPresented: isPresented) {
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                DatePicker(
                    label,
                    selection: Binding(
                        get: { date },
                        set: { newDate in
                            onSelect(newDate)
                            isPresented.wrappedValue = false
                        }
                    ),
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                Button("确定") {
                    isPresented.wrappedValue = false
                }
                .buttonStyle(AppTheme.PrimaryButtonStyle())
                .padding(.top, 4)
            }
            .padding(AppTheme.paddingM)
            .frame(width: 320)
        }
    }

    private func updatePresetFromStrings() {
        let presets: [TimeRangePreset] = [.today, .last7, .last30, .thisMonth, .lastMonth]
        for p in presets {
            let r = p.range
            if r.start == startTime && r.end == endTime {
                selectedPreset = p
                return
            }
        }
        selectedPreset = .custom
    }

    private func syncCustomDatesFromStrings() {
        customStartDate = DateHelpers.parseDate(startTime) ?? DateHelpers.startOfCurrentMonth
        customEndDate = DateHelpers.parseDate(endTime) ?? DateHelpers.endOfCurrentMonth
    }
}

// MARK: - 仅时间范围的紧凑条（用于与其它筛选器并排）

/// 仅包含时间筛选的横条，可与类别/类型 Picker 等并排使用
struct TimeRangeFilterBar: View {
    @Binding var startTime: String
    @Binding var endTime: String
    var onApply: (() -> Void)?

    var body: some View {
        TimeRangeFilterView(
            startTime: $startTime,
            endTime: $endTime,
            onApply: onApply,
            showQueryButton: true
        )
    }
}

#Preview("时间筛选") {
    struct PreviewWrapper: View {
        @State var start = DateHelpers.defaultStartTime
        @State var end = DateHelpers.defaultEndTime
        var body: some View {
            VStack {
                TimeRangeFilterView(
                    startTime: $start,
                    endTime: $end,
                    onApply: { print("apply") },
                    showQueryButton: true
                )
                Text("\(start) ~ \(end)")
                    .font(.caption)
            }
            .padding()
            .frame(width: 520)
        }
    }
    return PreviewWrapper()
}
