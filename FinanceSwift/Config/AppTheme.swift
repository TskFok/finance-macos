import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Neo-Tech 深色科技风
// 参考：Arc / Warp / ChatGPT Desktop / TradingView / Raycast Pro
// 深色背景 + 高对比色 + 微光边框 + 模糊材质 + 模块化卡片 + 数据密度高但不压迫

enum AppTheme {
    // MARK: - 基底色（深色背景）
    /// 主背景：窗口、详情区
    static let backgroundPrimary = Color(red: 0.06, green: 0.06, blue: 0.07)
    /// 次级背景：略抬升区域
    static let backgroundSecondary = Color(red: 0.09, green: 0.09, blue: 0.10)
    /// 卡片/面板表面（模块化）
    static let surface = Color(red: 0.11, green: 0.11, blue: 0.13)
    /// 更高层级（下拉、浮层）
    static let surfaceElevated = Color(red: 0.14, green: 0.14, blue: 0.16)

    // MARK: - 边框（微光 / 高对比）
    /// 默认边框：极细、低对比
    static let border = Color.white.opacity(0.06)
    /// 聚焦/强调边框：accent 微光
    static let borderFocus = Color(red: 0.13, green: 0.83, blue: 0.67)
    /// 边框渐变（按钮等）
    static var borderGradient: LinearGradient {
        LinearGradient(
            colors: [borderFocus.opacity(0.8), Color(red: 0.2, green: 0.6, blue: 1).opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - 文字（高对比、层次清晰）
    static let textPrimary = Color(red: 0.95, green: 0.95, blue: 0.96)
    static let textSecondary = Color(red: 0.58, green: 0.58, blue: 0.60)
    static let textTertiary = Color(red: 0.40, green: 0.40, blue: 0.43)

    // MARK: - 强调色（高对比、克制使用）
    /// 主强调：青/ Teal，用于关键操作与数据
    static let accent = Color(red: 0.13, green: 0.83, blue: 0.67)
    static let accentMuted = accent.opacity(0.45)
    /// 渐变（图标、主按钮）
    static var accentGradient: LinearGradient {
        LinearGradient(colors: [accent, Color(red: 0.2, green: 0.65, blue: 1)], startPoint: .leading, endPoint: .trailing)
    }
    static let destructive = Color(red: 0.98, green: 0.45, blue: 0.45)

    // MARK: - 材质（模糊）
    static let materialThin: Material = .thinMaterial
    static let materialUltraThin: Material = .ultraThinMaterial

    // MARK: - 圆角与阴影（模块化、不压迫）
    static let cornerRadius: CGFloat = 10
    static let cornerRadiusLarge: CGFloat = 14
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowY: CGFloat = 2
    static let glowRadius: CGFloat = 4
    static let glowOpacity: Double = 0.25

    // MARK: - 间距
    /// 列表/顶部栏与左右边缘的距离（约 3mm）
    static let listHorizontalInset: CGFloat = 9
    static let paddingS: CGFloat = 8
    static let paddingM: CGFloat = 16
    static let paddingL: CGFloat = 24
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24

    // MARK: - 字体（比系统默认大约 2pt，统一易读）
    static let fontSizeCaption2: CGFloat = 13
    static let fontSizeCaption: CGFloat = 14
    static let fontSizeSubheadline: CGFloat = 16
    static let fontSizeBody: CGFloat = 18
    static let fontSizeHeadline: CGFloat = 19
    static let fontSizeTitle3: CGFloat = 21
    static let fontSizeTitle2: CGFloat = 24
    static let fontSizeTitle: CGFloat = 30

    struct Font {
        static func caption2(_ weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font { .system(size: AppTheme.fontSizeCaption2, weight: weight) }
        static func caption(_ weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font { .system(size: AppTheme.fontSizeCaption, weight: weight) }
        static func subheadline(_ weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font { .system(size: AppTheme.fontSizeSubheadline, weight: weight) }
        static func body(_ weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font { .system(size: AppTheme.fontSizeBody, weight: weight) }
        static func headline(_ weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font { .system(size: AppTheme.fontSizeHeadline, weight: weight) }
        static func title3(_ weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font { .system(size: AppTheme.fontSizeTitle3, weight: weight) }
        static func title2(_ weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font { .system(size: AppTheme.fontSizeTitle2, weight: weight) }
        static func title(_ weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font { .system(size: AppTheme.fontSizeTitle, weight: weight) }
    }

    // MARK: - 按钮
    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(AppTheme.Font.subheadline(.semibold))
                .foregroundStyle(backgroundPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(accent)
                        .opacity(configuration.isPressed ? 0.9 : 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(border, lineWidth: 0.5)
                )
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }

    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(AppTheme.Font.subheadline(.medium))
                .foregroundStyle(textSecondary)
                .padding(.horizontal, AppTheme.paddingM)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(border, lineWidth: 1)
                )
                .opacity(configuration.isPressed ? 0.8 : 1)
        }
    }

    // MARK: - 卡片（模块化：圆角 + 微光边框 + 轻投影）
    struct CardModifier: ViewModifier {
        var padding: CGFloat = AppTheme.paddingM
        func body(content: Content) -> some View {
            content
                .padding(padding)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                        .fill(surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                        .stroke(border, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: cardShadowRadius, x: 0, y: cardShadowY)
        }
    }

    /// 筛选条 / 工具栏：模糊材质 + 圆角
    struct FilterBarModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(AppTheme.paddingM)
                .background(materialUltraThin)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                        .stroke(border, lineWidth: 1)
                )
        }
    }

    /// 输入框：暗色表面 + 微光边框（聚焦时 accent）
    struct TechInputModifier: ViewModifier {
        var focused: Bool = false
        func body(content: Content) -> some View {
            content
                .padding(.horizontal, AppTheme.paddingS + 2)
                .padding(.vertical, AppTheme.paddingS)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(backgroundSecondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(focused ? borderFocus.opacity(0.7) : border, lineWidth: focused ? 1.5 : 1)
                )
        }
    }

    /// 图表：高对比、易读（TradingView 风格）
    static let chartPalette: [Color] = [
        accent,
        Color(red: 0.35, green: 0.85, blue: 0.55),
        Color(red: 1, green: 0.75, blue: 0.25),
        Color(red: 1, green: 0.45, blue: 0.35),
        Color(red: 0.85, green: 0.45, blue: 1),
        Color(red: 0.35, green: 0.65, blue: 1),
        Color(red: 0.5, green: 0.9, blue: 0.85),
    ]
}

extension View {
    func appCard(padding: CGFloat = AppTheme.paddingM) -> some View {
        modifier(AppTheme.CardModifier(padding: padding))
    }
    func appFilterBar() -> some View {
        modifier(AppTheme.FilterBarModifier())
    }
    func appTechInput(focused: Bool = false) -> some View {
        modifier(AppTheme.TechInputModifier(focused: focused))
    }
}
