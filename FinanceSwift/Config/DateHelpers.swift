import Foundation

/// 时间筛选与格式：接口要求 start_time/end_time 格式 2024-01-01
enum DateHelpers {
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        return f
    }()

    static func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    /// 当前月份第一天 00:00 的日期
    static var startOfCurrentMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()
    }

    /// 当前月份最后一天
    static var endOfCurrentMonth: Date {
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfCurrentMonth),
              let last = Calendar.current.date(byAdding: .day, value: -1, to: nextMonth) else {
            return Date()
        }
        return last
    }

    /// 默认展示当前月份：开始、结束（yyyy-MM-dd）
    static var defaultStartTime: String { formatDate(startOfCurrentMonth) }
    static var defaultEndTime: String { formatDate(endOfCurrentMonth) }

    /// 当前年月（yyyy-MM），用于 range_type=month
    static var currentYearMonth: String {
        let c = Calendar.current
        let comp = c.dateComponents([.year, .month], from: Date())
        return String(format: "%04d-%02d", comp.year ?? 0, comp.month ?? 1)
    }

    /// 当前年份（yyyy），用于 range_type=year
    static var currentYear: String {
        String(Calendar.current.component(.year, from: Date()))
    }
}
