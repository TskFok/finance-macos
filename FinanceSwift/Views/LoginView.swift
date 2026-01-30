import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: AppTheme.spacingS) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(AppTheme.accentGradient)
                Text("记账系统")
                    .font(AppTheme.Font.title(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(.bottom, AppTheme.paddingL)

            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                Text("用户名")
                    .font(AppTheme.Font.subheadline(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                TextField("请输入用户名", text: $viewModel.username)
                    .textFieldStyle(.plain)
                    .foregroundStyle(AppTheme.textPrimary)
                    .appTechInput()
                    .onChange(of: viewModel.username) { _, _ in viewModel.clearError() }
            }

            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                Text("密码")
                    .font(AppTheme.Font.subheadline(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                SecureField("请输入密码", text: $viewModel.password)
                    .textFieldStyle(.plain)
                    .foregroundStyle(AppTheme.textPrimary)
                    .appTechInput()
                    .onChange(of: viewModel.password) { _, _ in viewModel.clearError() }
            }

            if let msg = viewModel.errorMessage {
                Text(msg)
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(AppTheme.destructive)
                    .padding(.top, 4)
            }

            Button {
                Task { await viewModel.login() }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.85)
                            .tint(AppTheme.backgroundPrimary)
                    } else {
                        Text("登录")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .disabled(!viewModel.canSubmit || viewModel.isLoading)
            .padding(.top, 8)
        }
        .padding(AppTheme.paddingL + 8)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                .fill(AppTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 20, x: 0, y: 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundPrimary)
    }
}

#Preview {
    LoginView()
}
