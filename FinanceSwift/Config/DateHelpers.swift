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

    /// 将 yyyy-MM-dd 字符串解析为 Date
    static func parseDate(_ string: String) -> Date? {
        dateFormatter.date(from: string)
    }

    /// 将接口返回的 ISO8601 时间（如 2026-02-02T11:24:12+08:00）格式化为展示用字符串，支出/收入列表共用
    static func formatISO8601Time(_ iso8601: String?) -> String? {
        guard let s = iso8601, !s.isEmpty else { return nil }
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = parser.date(from: s) {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd HH:mm"
            f.locale = Locale(identifier: "en_US_POSIX")
            f.timeZone = TimeZone.current
            return f.string(from: date)
        }
        parser.formatOptions = [.withInternetDateTime]
        if let date = parser.date(from: s) {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd HH:mm"
            f.locale = Locale(identifier: "en_US_POSIX")
            f.timeZone = TimeZone.current
            return f.string(from: date)
        }
        return s
    }

    // MARK: - 预设时间范围（用于现代化时间筛选）

    /// 今天
    static var todayRange: (start: String, end: String) {
        let d = Date()
        let s = formatDate(d)
        return (s, s)
    }

    /// 近 7 天（含今天）
    static var last7DaysRange: (start: String, end: String) {
        let cal = Calendar.current
        let end = Date()
        guard let start = cal.date(byAdding: .day, value: -6, to: end) else { return (formatDate(end), formatDate(end)) }
        return (formatDate(start), formatDate(end))
    }

    /// 近 30 天（含今天）
    static var last30DaysRange: (start: String, end: String) {
        let cal = Calendar.current
        let end = Date()
        guard let start = cal.date(byAdding: .day, value: -29, to: end) else { return (formatDate(end), formatDate(end)) }
        return (formatDate(start), formatDate(end))
    }

    /// 本月
    static var thisMonthRange: (start: String, end: String) {
        (defaultStartTime, defaultEndTime)
    }

    /// 上月
    static var lastMonthRange: (start: String, end: String) {
        let cal = Calendar.current
        guard let prevMonth = cal.date(byAdding: .month, value: -1, to: startOfCurrentMonth),
              let start = cal.date(from: cal.dateComponents([.year, .month], from: prevMonth)),
              let next = cal.date(byAdding: .month, value: 1, to: start),
              let end = cal.date(byAdding: .day, value: -1, to: next) else {
            return (defaultStartTime, defaultEndTime)
        }
        return (formatDate(start), formatDate(end))
    }
}
