import SwiftUI

struct AddIncomeView: View {
    let incomeTypes: [String]
    let onDismiss: () -> Void

    @StateObject private var viewModel = AddIncomeViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: AppTheme.spacingL) {
            HStack(spacing: AppTheme.spacingS) {
                Image(systemName: "plus.circle.fill")
                    .font(AppTheme.Font.title2())
                    .foregroundStyle(AppTheme.accentGradient)
                Text("添加收入")
                    .font(AppTheme.Font.title2(.semibold))
            }
            .padding(.bottom, 4)

            Form {
                TextField("金额", text: $viewModel.amountText)
                    .textFieldStyle(.plain)
                    .foregroundStyle(AppTheme.textPrimary)
                    .appTechInput()
                Picker("类型", selection: $viewModel.type) {
                    Text("请选择").tag("")
                    ForEach(incomeTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.menu)
                DatePicker("时间", selection: $viewModel.incomeTime, displayedComponents: [.date, .hourAndMinute])
            }
            .formStyle(.grouped)

            if let msg = viewModel.errorMessage {
                Text(msg)
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(AppTheme.destructive)
            }
            HStack(spacing: AppTheme.spacingM) {
                Button("取消") {
                    dismiss()
                    onDismiss()
                }
                .keyboardShortcut(.cancelAction)
                .buttonStyle(AppTheme.SecondaryButtonStyle())
                Button("保存") {
                    Task {
                        await viewModel.submit()
                        if viewModel.didCreate {
                            dismiss()
                            onDismiss()
                        }
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!viewModel.canSubmit || viewModel.isLoading)
                .buttonStyle(AppTheme.PrimaryButtonStyle())
            }
        }
        .padding(AppTheme.paddingL)
        .frame(width: 380)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                .fill(AppTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .onChange(of: viewModel.didCreate) { _, done in
            if done {
                dismiss()
                onDismiss()
            }
        }
    }
}

#Preview {
    AddIncomeView(incomeTypes: ["工资", "奖金", "兼职", "理财", "其他"], onDismiss: {})
}
