import SwiftUI

struct AddExpenseView: View {
    let categories: [ExpenseCategory]
    let onDismiss: () -> Void

    @StateObject private var viewModel = AddExpenseViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: AppTheme.spacingL) {
            HStack(spacing: AppTheme.spacingS) {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.accentGradient)
                Text("添加支出")
                    .font(.title2.weight(.semibold))
            }
            .padding(.bottom, 4)

            Form {
                TextField("金额", text: $viewModel.amountText)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                Picker("类别", selection: $viewModel.category) {
                    Text("请选择").tag("")
                    ForEach(categories) { cat in
                        Text(cat.name).tag(cat.name)
                    }
                }
                .pickerStyle(.menu)
                DatePicker("时间", selection: $viewModel.expenseTime, displayedComponents: [.date, .hourAndMinute])
                TextField("备注（选填）", text: $viewModel.descriptionText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .lineLimit(2...4)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            }
            .formStyle(.grouped)

            if let msg = viewModel.errorMessage {
                Text(msg)
                    .font(.caption)
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
        .background(.ultraThinMaterial)
        .onChange(of: viewModel.didCreate) { _, done in
            if done {
                dismiss()
                onDismiss()
            }
        }
    }
}

#Preview {
    AddExpenseView(categories: [
        ExpenseCategory(id: 1, name: "餐饮", sort: 0, color: nil, createdAt: nil, updatedAt: nil),
        ExpenseCategory(id: 2, name: "交通", sort: 1, color: nil, createdAt: nil, updatedAt: nil)
    ], onDismiss: {})
}
