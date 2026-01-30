import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

/// 统一设计系统：颜色、圆角、间距、按钮样式
enum AppTheme {
    // MARK: - 颜色
    static let accentStart = Color(red: 0.2, green: 0.7, blue: 0.65)
    static let accentEnd = Color(red: 0.15, green: 0.55, blue: 0.7)
    static var accentGradient: LinearGradient {
        LinearGradient(colors: [accentStart, accentEnd], startPoint: .leading, endPoint: .trailing)
    }
    static let accent = Color(red: 0.2, green: 0.65, blue: 0.6)
    static let cardBackground: Color = {
        #if os(macOS)
        return Color(nsColor: .windowBackgroundColor).opacity(0.85)
        #else
        return Color(uiColor: .systemBackground).opacity(0.85)
        #endif
    }()
    static let destructive = Color.red

    // MARK: - 圆角与阴影
    static let cornerRadius: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowY: CGFloat = 2

    // MARK: - 间距
    static let paddingS: CGFloat = 8
    static let paddingM: CGFloat = 16
    static let paddingL: CGFloat = 24
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24

    // MARK: - 按钮样式
    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(AppTheme.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                .opacity(configuration.isPressed ? 0.9 : 1)
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }

    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.accent)
                .padding(.horizontal, AppTheme.paddingM)
                .padding(.vertical, 8)
                .background(AppTheme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(AppTheme.accent.opacity(0.3), lineWidth: 1)
                )
                .opacity(configuration.isPressed ? 0.85 : 1)
        }
    }

    // MARK: - 卡片容器
    struct CardModifier: ViewModifier {
        var padding: CGFloat = AppTheme.paddingM
        func body(content: Content) -> some View {
            content
                .padding(padding)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
                .shadow(color: .black.opacity(0.06), radius: AppTheme.cardShadowRadius, x: 0, y: AppTheme.cardShadowY)
        }
    }

    struct FilterBarModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(AppTheme.paddingM)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
        }
    }
}

extension View {
    func appCard(padding: CGFloat = AppTheme.paddingM) -> some View {
        modifier(AppTheme.CardModifier(padding: padding))
    }
    func appFilterBar() -> some View {
        modifier(AppTheme.FilterBarModifier())
    }
}
