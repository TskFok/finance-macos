# 记账系统 macOS 客户端

基于 `doc.json` 接口文档的 Swift macOS 应用，支持登录、支出/收入管理、消费统计、AI 聊天与数据分析。

## 技术栈

- **平台**: macOS 14+
- **语言**: Swift 5
- **UI**: SwiftUI
- **图表**: Swift Charts
- **接口**: 与后端 REST API 通信（见 `doc.json`）

---

## 项目结构

```
finance-swift/
├── FinanceSwift.xcodeproj     # Xcode 工程
├── doc.json                   # 接口文档
├── README.md
├── .gitignore
│
└── FinanceSwift/              # 应用源码
    ├── FinanceSwiftApp.swift  # 应用入口
    ├── ContentView.swift      # 根视图（未登录→登录页，已登录→主界面侧栏+详情）
    ├── FinanceSwift.entitlements
    │
    ├── Config/
    │   ├── APIConfig.swift           # API 路径与 baseURL 读取逻辑
    │   ├── API-Secrets.example.plist # 示例配置（BaseURL 默认 localhost）
    │   ├── AppTheme.swift            # 统一设计系统（颜色、按钮、卡片等）
    │   └── DateHelpers.swift        # 日期格式化等
    │
    ├── Models/
    │   ├── User.swift, LoginRequest.swift, LoginResponse.swift, APIResponse.swift
    │   ├── Expense.swift, ExpenseCategory.swift, CreateExpenseRequest.swift
    │   ├── Income.swift, CreateIncomeRequest.swift
    │   ├── PageResponse.swift, DetailedStatisticsResponse.swift
    │   ├── AIModel.swift, AIChatRequest.swift, AIChatHistoryItem.swift
    │   ├── AnalysisRequest.swift, AIAnalysisHistoryItem.swift
    │   └── ...
    │
    ├── Services/
    │   ├── APIClient.swift    # HTTP 封装、Token 注入
    │   ├── AuthService.swift  # 登录/登出、用户持久化
    │   ├── ExpenseService.swift
    │   ├── IncomeService.swift
    │   ├── AIChatService.swift
    │   └── AIAnalysisService.swift
    │
    ├── ViewModels/
    │   ├── LoginViewModel.swift, ExpenseListViewModel.swift, AddExpenseViewModel.swift
    │   ├── IncomeListViewModel.swift, AddIncomeViewModel.swift
    │   ├── StatisticsViewModel.swift
    │   ├── AIChatViewModel.swift, AIAnalysisViewModel.swift
    │   └── ...
    │
    ├── Views/
    │   ├── LoginView.swift
    │   ├── ExpenseListView.swift, AddExpenseView.swift
    │   ├── IncomeListView.swift, AddIncomeView.swift
    │   ├── StatisticsView.swift
    │   ├── AIChatView.swift, AIAnalysisView.swift
    │   └── ...
    │
    └── Assets.xcassets        # 图标与配色
```

---

## 如何测试项目

当前无独立单元测试 target，通过**运行应用**进行功能验证。

### 1. 用 Xcode 运行（推荐）

1. 用 **Xcode** 打开 `FinanceSwift.xcodeproj`。
2. 选择 scheme **FinanceSwift**，目标 **My Mac**。
3. 点击 **Run**（⌘R）或菜单 **Product → Run**。
4. 确保后端已启动（默认 `http://localhost:8080`），登录后逐项验证：
   - 支出列表、添加/删除支出
   - 收入列表、添加/删除收入
   - 统计（时间筛选、饼图/柱状图）
   - AI 聊天、AI 数据分析

### 2. 指定 API 环境测试

- **本地**：不配置即使用 `API-Secrets.example.plist` 的 `http://localhost:8080`。
- **其他环境**：在 Xcode 中 **Edit Scheme → Run → Arguments**，在 **Environment Variables** 里添加 `API_BASE_URL` = `https://你的测试域名`，再 Run。

### 3. 后续可增加测试

- 在 Xcode 中 **File → New → Target**，选择 **Unit Testing Bundle**，可对 ViewModel、Service 等做单元测试。
- 测试通过 **Product → Test**（⌘U）运行。

---

## 如何 Build 与打包

### 方式一：Xcode 图形界面

1. **仅编译**：**Product → Build**（⌘B）。
2. **归档（用于分发）**：
   - 选择 **Any Mac (Apple Silicon, Intel)** 或当前 Mac 架构。
   - **Product → Archive**。
   - 归档完成后在 **Organizer** 中可 **Distribute App**，导出为：
     - **Copy App**：得到 `.app`，可直接拖到「应用程序」或打包成 DMG。
     - **Developer ID**：签名后用于非 App Store 分发。

### 方式二：命令行 Build

在项目根目录（`finance-swift/`）下执行：

```bash
# 编译（Debug）
xcodebuild -scheme FinanceSwift -configuration Debug -destination 'platform=macOS' build

# 编译（Release）
xcodebuild -scheme FinanceSwift -configuration Release -destination 'platform=macOS' build
```

生成的 `.app` 在：

`DerivedData/.../Build/Products/Release/FinanceSwift.app`

### 方式三：命令行归档并导出 .app

```bash
# 1. 归档（生成 .xcarchive）
xcodebuild -scheme FinanceSwift -configuration Release -destination 'generic/platform=macOS' \
  -archivePath build/FinanceSwift.xcarchive archive

# 2. 导出 .app（需先有 ExportOptions.plist，见下）
xcodebuild -exportArchive -archivePath build/FinanceSwift.xcarchive \
  -exportPath build/export -exportOptionsPlist ExportOptions.plist
```

**ExportOptions.plist** 示例（导出为可拷贝的 .app，不签名）：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>copy</string>
  <key>destination</key>
  <string>export</string>
</dict>
</plist>
```

若需 **Developer ID 签名** 分发，将 `method` 改为 `developer-id`，并确保证书与描述文件已配置。

---

## 修改 API 地址（避免生产内容提交到 GitHub）

baseURL **不写死在代码中**，按以下优先级读取：

1. **环境变量** `API_BASE_URL`（如 `export API_BASE_URL=https://your-api.com`）
2. **API-Secrets.plist**（不提交）：复制 `FinanceSwift/Config/API-Secrets.example.plist` 为 `API-Secrets.plist`，修改其中的 `BaseURL`。该文件已加入工程的 **Copy Bundle Resources**，打包/归档时会一并打进 .app，运行时优先使用。
3. **API-Secrets.example.plist**（已提交）：默认 `BaseURL = http://localhost:8080`
4. 若以上都未配置，则使用 `http://localhost:8080`

生产环境请使用 1 或 2，切勿将生产地址写入仓库。

> **若修改 API-Secrets.plist 后打包未生效**：确认 `API-Secrets.plist` 已存在于 `FinanceSwift/Config/` 且已被加入 Xcode 工程的 Copy Bundle Resources（当前工程已配置，重新 Build/Archive 即可）。
