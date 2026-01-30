import SwiftUI

struct ContentView: View {
    @ObservedObject private var auth = AuthService.shared

    var body: some View {
        Group {
            if auth.isLoggedIn {
                MainView()
            } else {
                LoginView()
            }
        }
        .frame(minWidth: 480, minHeight: 420)
        .background(AppTheme.backgroundPrimary)
    }
}

/// 登录后的主界面
struct MainView: View {
    @ObservedObject private var auth = AuthService.shared
    @State private var selectedItem: SidebarItem? = .expenses

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedItem) {
                Section {
                    NavigationLink(value: SidebarItem.expenses) {
                        Label("支出", systemImage: "list.bullet")
                            .font(AppTheme.Font.subheadline(.medium))
                    }
                    NavigationLink(value: SidebarItem.incomes) {
                        Label("收入", systemImage: "banknote")
                            .font(AppTheme.Font.subheadline(.medium))
                    }
                    NavigationLink(value: SidebarItem.statistics) {
                        Label("统计", systemImage: "chart.pie")
                            .font(AppTheme.Font.subheadline(.medium))
                    }
                } header: {
                    Text("记账")
                        .font(AppTheme.Font.caption(.semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Section {
                    NavigationLink(value: SidebarItem.aiChat) {
                        Label("AI 聊天", systemImage: "bubble.left.and.bubble.right")
                            .font(AppTheme.Font.subheadline(.medium))
                    }
                    NavigationLink(value: SidebarItem.aiAnalysis) {
                        Label("AI 数据分析", systemImage: "chart.bar.doc.horizontal")
                            .font(AppTheme.Font.subheadline(.medium))
                    }
                } header: {
                    Text("AI")
                        .font(AppTheme.Font.caption(.semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Section {
                    if let user = auth.currentUser {
                        HStack(spacing: 6) {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(AppTheme.accent)
                            Text(user.username)
                                .font(AppTheme.Font.caption(.medium))
                        }
                    }
                    Button {
                        auth.logout()
                    } label: {
                        Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(AppTheme.Font.subheadline(.medium))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .background(AppTheme.backgroundPrimary)
            .background(AppTheme.materialUltraThin)
            .navigationTitle("记账")
            .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 260)
        } detail: {
            Group {
                switch selectedItem {
                case .expenses:
                    ExpenseListView()
                case .incomes:
                    IncomeListView()
                case .statistics:
                    StatisticsView()
                case .aiChat:
                    AIChatView()
                case .aiAnalysis:
                    AIAnalysisView()
                case .none:
                    ExpenseListView()
                }
            }
            .frame(minWidth: 400, minHeight: 300)
            .background(AppTheme.backgroundPrimary)
        }
    }
}

private enum SidebarItem: Hashable {
    case expenses
    case incomes
    case statistics
    case aiChat
    case aiAnalysis
}

#Preview("未登录") {
    ContentView()
}
