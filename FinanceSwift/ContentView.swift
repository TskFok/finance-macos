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
                            .font(.subheadline.weight(.medium))
                    }
                    NavigationLink(value: SidebarItem.incomes) {
                        Label("收入", systemImage: "banknote")
                            .font(.subheadline.weight(.medium))
                    }
                    NavigationLink(value: SidebarItem.statistics) {
                        Label("统计", systemImage: "chart.pie")
                            .font(.subheadline.weight(.medium))
                    }
                } header: {
                    Text("记账")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Section {
                    NavigationLink(value: SidebarItem.aiChat) {
                        Label("AI 聊天", systemImage: "bubble.left.and.bubble.right")
                            .font(.subheadline.weight(.medium))
                    }
                    NavigationLink(value: SidebarItem.aiAnalysis) {
                        Label("AI 数据分析", systemImage: "chart.bar.doc.horizontal")
                            .font(.subheadline.weight(.medium))
                    }
                } header: {
                    Text("AI")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Section {
                    if let user = auth.currentUser {
                        HStack(spacing: 6) {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(AppTheme.accent)
                            Text(user.username)
                                .font(.caption.weight(.medium))
                        }
                    }
                    Button {
                        auth.logout()
                    } label: {
                        Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.subheadline.weight(.medium))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
            }
            .listStyle(.sidebar)
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
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
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
