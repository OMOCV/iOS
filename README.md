# ABB Robot Program Reader - iOS App

一个用于读取和查看 ABB 机器人程序文件的 iOS 应用程序。

## 功能特性

### ✨ 核心功能

1. **多格式支持**
   - 支持 `.mod` (模块文件)
   - 支持 `.prg` (程序文件)
   - 支持 `.sys` (系统文件)
   - 支持 `.cfg` (配置文件)

2. **智能解析**
   - 自动识别程序模块 (MODULE, SYSMODULE, USERMODULE)
   - 识别例行程序 (PROC, FUNC, TRAP)
   - 解析变量声明 (VAR, PERS, CONST)
   - 提取程序参数

3. **语法高亮**
   - ABB RAPID 关键字高亮（紫色加粗）
   - 数据类型高亮（蓝色）
   - 指令高亮（橙色）
   - 注释高亮（绿色）
   - 字符串高亮（红色）
   - 数字高亮（青色）

4. **用户界面**
   - 现代化 SwiftUI 界面
   - 文件列表视图
   - 模块和例行程序浏览
   - 代码查看器支持文本选择和复制
   - 支持多文件导入

## 系统要求

- iOS 15.0 或更高版本
- iPhone 和 iPad 兼容
- Xcode 15.0 或更高版本（用于构建）

## 构建说明

### 使用 Xcode 构建

1. 打开项目：
   ```bash
   open ABBRobotReader.xcodeproj
   ```

2. 在 Xcode 中：
   - 选择目标设备或模拟器
   - 点击 Run (⌘R) 进行调试运行
   - 或选择 Product > Archive 创建发布版本

### 构建 IPA 文件

#### 方法 1：使用自动化脚本

使用提供的脚本自动构建 IPA：

```bash
DEVELOPMENT_TEAM=你的TeamID ./build_ipa.sh
```

构建完成后，IPA 文件将位于 `build/ipa/` 目录中。

> 提示：`DEVELOPMENT_TEAM` 为 Apple 开发者账号的 Team ID，用于自动签名。CI 环境下可在仓库 Secrets 中配置同名变量供工作流使用。

#### 方法 2：通过 GitHub Actions（CI/CD）

当代码 Push 到 `main` 分支时，GitHub Actions 会自动构建 IPA 文件。
构建完成后，可以在 GitHub Actions 的 Artifacts 中下载：
- `ABBRobotReader-IPA-{commit-sha}`: 生成的 IPA 文件（保留 30 天）
- `ABBRobotReader-Archive-{commit-sha}`: Xcode 归档文件（保留 7 天）

CI 环境需要配置以下 Secrets（推荐使用 Base64 编码后的证书/描述文件内容）：
- `IOS_P12` / `IOS_P12_PASSWORD`：用于签名的 `.p12` 证书及其密码
- `IOS_MOBILEPROVISION`：移动设备描述文件（`.mobileprovision`）
- `KEYCHAIN_PASSWORD`：工作流临时钥匙串的访问密码
- `DEVELOPMENT_TEAM`：Apple 开发者账号的 Team ID

#### 方法 3：手动构建步骤

```bash
# 1. 清理构建
rm -rf build

# 2. 创建归档
xcodebuild archive \
    -project ABBRobotReader.xcodeproj \
    -scheme ABBRobotReader \
    -configuration Release \
    -archivePath build/ABBRobotReader.xcarchive \
    -destination 'generic/platform=iOS'

# 3. 导出 IPA
xcodebuild -exportArchive \
    -archivePath build/ABBRobotReader.xcarchive \
    -exportPath build/ipa \
    -exportOptionsPlist ExportOptions.plist
```

## 使用方法

1. **导入文件**
   - 点击右上角的 "+" 按钮
   - 选择 ABB 机器人程序文件（.mod, .prg, .sys, .cfg）
   - 支持同时导入多个文件

2. **浏览程序**
   - 在文件列表中点击文件查看详情
   - 查看模块和例行程序列表
   - 展开声明和例行程序组

3. **查看代码**
   - 点击例行程序查看具体代码
   - 点击 "View Full Module" 查看完整模块
   - 支持文本选择和复制

4. **管理文件**
   - 点击左上角的垃圾桶图标清除所有文件
   - 使用 "Import" 按钮添加更多文件

## 项目结构

```
ABBRobotReader/
├── ABBRobotReaderApp.swift      # 应用入口
├── Info.plist                   # 应用配置和文件类型支持
├── Models/
│   └── ABBModule.swift          # 数据模型（模块、例行程序、文件）
├── Parsers/
│   ├── ABBFileParser.swift      # ABB 文件解析器
│   └── SyntaxHighlighter.swift  # 语法高亮引擎
├── Views/
│   ├── ContentView.swift        # 主视图
│   ├── FileListView.swift       # 文件列表视图
│   ├── CodeEditorView.swift     # 代码编辑器视图
│   └── DocumentPicker.swift     # 文档选择器
└── Assets.xcassets/             # 应用资源
```

## ABB RAPID 语法支持

### 支持的关键字
- 模块: MODULE, ENDMODULE, SYSMODULE, USERMODULE
- 例行程序: PROC, ENDPROC, FUNC, ENDFUNC, TRAP, ENDTRAP
- 变量: VAR, PERS, CONST, ALIAS
- 控制流: IF, THEN, ELSE, FOR, WHILE, TEST, CASE, GOTO, RETURN
- 逻辑: AND, OR, NOT, XOR

### 支持的数据类型
- 基础类型: num, bool, string, byte
- 位置类型: pos, orient, pose, robtarget, jointtarget
- 运动类型: speeddata, zonedata, tooldata, wobjdata
- 其他: loaddata, mechanicalunitdata, clock, dionum

### 支持的指令
- 运动: MoveL, MoveJ, MoveC, MoveAbsJ
- I/O: SetDO, SetAO, SetGO, WaitDI
- 配置: AccSet, VelSet, ConfL, ConfJ
- 其他: TPWrite, WaitTime, Stop, TriggIO

## 技术实现

- **语言**: Swift 5.0
- **框架**: SwiftUI
- **最低部署**: iOS 15.0
- **架构**: MVVM 模式
- **文件处理**: 使用 UniformTypeIdentifiers 和文档选择器

## 安装到设备

### 通过 Xcode
1. 连接 iOS 设备到电脑
2. 在 Xcode 中选择你的设备
3. 点击 Run 安装并运行

### 通过 IPA 文件
1. 构建 IPA 文件
2. 打开 Xcode > Window > Devices and Simulators
3. 选择你的设备
4. 将 IPA 文件拖放到应用列表中

## 注意事项

1. 首次使用时，应用会请求访问文件的权限
2. 支持从 iCloud Drive、Files 等位置导入文件
3. 应用支持文件共享，可以通过 iTunes 或 Finder 传输文件
4. 代码查看器支持横屏和竖屏模式

## 开发者信息

- 支持 iOS 15.0+
- 使用现代 SwiftUI 开发
- 遵循苹果人机界面指南
- 支持深色模式和浅色模式

## 许可证

请参考项目根目录的 LICENSE 文件。
