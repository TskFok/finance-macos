import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: AppTheme.spacingS) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(AppTheme.accentGradient)
                Text("记账系统")
                    .font(.title.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            .padding(.bottom, AppTheme.paddingL)

            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                Text("用户名")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                TextField("请输入用户名", text: $viewModel.username)
                    .textFieldStyle(.plain)
                    .padding(AppTheme.paddingS + 4)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                    .onChange(of: viewModel.username) { _, _ in viewModel.clearError() }
            }

            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                Text("密码")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                SecureField("请输入密码", text: $viewModel.password)
                    .textFieldStyle(.plain)
                    .padding(AppTheme.paddingS + 4)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                    .onChange(of: viewModel.password) { _, _ in viewModel.clearError() }
            }

            if let msg = viewModel.errorMessage {
                Text(msg)
                    .font(.caption)
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
                            .tint(.white)
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
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
    }
}

#Preview {
    LoginView()
}
