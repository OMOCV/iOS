# 构建和部署指南

## 开发环境设置

### 必需软件

1. **macOS**: 需要 macOS 12 (Monterey) 或更高版本
2. **Xcode**: 需要 Xcode 15.0 或更高版本
   - 从 Mac App Store 下载安装
   - 或从 [Apple Developer](https://developer.apple.com/download/) 下载

3. **命令行工具**: 
   ```bash
   xcode-select --install
   ```

### 克隆项目

```bash
git clone https://github.com/OMOCV/iOS.git
cd iOS
```

## 在 Xcode 中开发

### 打开项目

```bash
open ABBRobotReader.xcodeproj
```

或在 Xcode 中选择 File > Open，然后选择 `ABBRobotReader.xcodeproj`。

### 选择目标设备

1. 在 Xcode 顶部工具栏中，点击设备选择器
2. 选择：
   - 物理设备（需要连接 iPhone 或 iPad）
   - 模拟器（推荐使用 iPhone 14 或 iPhone 15）

### 运行应用

- 点击 ▶️ (Play) 按钮
- 或使用快捷键 `⌘R`

### 调试

- 设置断点：点击代码行号左侧
- 查看控制台：View > Debug Area > Show Debug Area
- 查看变量：鼠标悬停在变量上

## 命令行构建

### 构建用于模拟器

```bash
xcodebuild build \
    -project ABBRobotReader.xcodeproj \
    -scheme ABBRobotReader \
    -destination 'platform=iOS Simulator,name=iPhone 14,OS=latest'
```

### 构建用于真机

```bash
xcodebuild build \
    -project ABBRobotReader.xcodeproj \
    -scheme ABBRobotReader \
    -destination 'generic/platform=iOS'
```

### 清理构建

```bash
xcodebuild clean \
    -project ABBRobotReader.xcodeproj \
    -scheme ABBRobotReader
```

## 创建 IPA 文件

### 使用自动脚本

项目包含一个自动化构建脚本：

```bash
./build_ipa.sh
```

这个脚本会：
1. 清理之前的构建
2. 创建归档 (Archive)
3. 导出 IPA 文件
4. 将 IPA 保存到 `build/ipa/` 目录

使用前请确认：

- 必须在 **macOS** 上执行，并安装好 Xcode 及其命令行工具（`xcodebuild`）。
- 请在项目根目录运行脚本，否则会提示找不到 `ABBRobotReader.xcodeproj`。
- 如需带签名的 IPA，请根据团队证书调整脚本中的导出选项或在 Xcode 中手动分发。

### 在 GitHub Actions 中构建 IPA

仓库提供了 CI 工作流（`.github/workflows/build-ipa.yml`）用于在 macOS Runner 上构建 IPA。

触发方式：

- 向 `main` 分支推送
- 打开 Pull Request
- 手动执行 `Run workflow`（workflow_dispatch）

CI 构建完成后，IPA 会作为名为 `ABBRobotReader-IPA` 的工件 (artifact) 发布，可从 Actions 页面下载。

### 手动创建 Archive

1. 在 Xcode 中选择设备为 "Any iOS Device (arm64)"
2. Product > Archive
3. 等待构建完成
4. 在 Organizer 窗口中选择刚创建的 Archive
5. 点击 "Distribute App"

### 导出选项

根据用途选择不同的导出方式：

#### 1. 开发版本 (Development)
- 用于开发团队内部测试
- 需要在设备上安装开发证书

#### 2. Ad Hoc
- 用于有限设备的测试
- 设备需要在 provisioning profile 中注册

#### 3. Enterprise
- 用于企业内部分发
- 需要企业开发者账号

#### 4. App Store
- 用于提交到 App Store
- 需要完整的 App Store Connect 配置

## 代码签名

### 自动签名（推荐）

1. 在 Xcode 中打开项目
2. 选择 ABBRobotReader target
3. 在 "Signing & Capabilities" 标签页
4. 勾选 "Automatically manage signing"
5. 选择你的开发团队

### 手动签名

如果需要手动配置：

1. 创建 App ID（在 Apple Developer Portal）
2. 创建 Provisioning Profile
3. 在 Xcode 中导入证书和 Profile
4. 在项目设置中选择对应的 Profile

## 安装到设备

### 方法 1: 通过 Xcode

1. 连接 iOS 设备到 Mac
2. 信任设备（首次连接需要）
3. 在 Xcode 中选择连接的设备
4. 点击运行按钮

### 方法 2: 通过 IPA 文件

1. 构建 IPA 文件
2. 打开 Xcode > Window > Devices and Simulators
3. 选择你的设备
4. 将 IPA 文件拖放到 "Installed Apps" 区域

### 方法 3: 通过 Apple Configurator

1. 在 Mac 上安装 Apple Configurator 2
2. 连接 iOS 设备
3. 将 IPA 文件拖放到 Apple Configurator 中的设备图标上

### 方法 4: 通过 TestFlight

如果要通过 TestFlight 分发：

1. 将 IPA 上传到 App Store Connect
2. 添加测试用户
3. 测试用户通过 TestFlight app 安装

## 版本管理

### 更新版本号

在 Xcode 中：

1. 选择项目 > General 标签
2. 更新 "Version" (对外版本号，如 1.0.0)
3. 更新 "Build" (内部构建号，如 1)

或者在 `Info.plist` 中：

- `CFBundleShortVersionString`: 版本号
- `CFBundleVersion`: 构建号

### 创建发布标签

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## 持续集成 (CI/CD)

### GitHub Actions

项目包含 GitHub Actions 配置文件 (`.github/workflows/ios.yml`)，包含两个独立的工作流作业：

**1. Build and Test (构建和测试)**
- 在所有分支上运行（main, develop）
- 在所有 Pull Request 中运行
- 为 iOS 模拟器构建应用
- 验证代码可以正常编译

**2. Build IPA for Release (构建发布 IPA)**
- 仅在 Push 到 main 分支时运行
- 依赖于 Build and Test 作业成功完成
- 包含以下步骤：
  1. 为 iOS 设备创建 Release 归档 (Archive)
  2. 验证归档文件创建成功
  3. 导出 IPA 文件
  4. 验证 IPA 文件导出成功
  5. 上传 IPA 和归档文件为 Artifacts

构建产物可以在 GitHub Actions 页面的 Artifacts 部分下载：
- `ABBRobotReader-IPA-{commit-sha}`: IPA 文件（保留 30 天）
- `ABBRobotReader-Archive-{commit-sha}`: Xcode 归档文件（保留 7 天）

工作流包含完整的验证步骤，确保 IPA 构建成功。如果任何步骤失败，工作流将立即停止并报告错误。

### 本地 CI 测试

模拟 CI 环境运行：

```bash
# 清理
xcodebuild clean -project ABBRobotReader.xcodeproj -scheme ABBRobotReader

# 构建
xcodebuild build \
    -project ABBRobotReader.xcodeproj \
    -scheme ABBRobotReader \
    -destination 'platform=iOS Simulator,name=iPhone 14,OS=latest'
```

## 性能优化

### 编译优化

Release 构建会自动启用以下优化：

- Swift 编译器优化级别：`-O` (速度优化)
- 去除调试符号
- 代码压缩

### 资源优化

1. **图片资源**：使用 Asset Catalog
2. **启动时间**：懒加载非必要资源
3. **内存使用**：及时释放不需要的对象

## 故障排除

### 构建失败

#### 签名错误
```
error: Signing for "ABBRobotReader" requires a development team.
```

解决方案：
- 在 Xcode 中设置开发团队
- 或使用 `CODE_SIGNING_REQUIRED=NO` 构建

#### 找不到模拟器
```
error: Unable to find a destination matching the provided destination specifier
```

解决方案：
```bash
# 列出可用的模拟器
xcrun simctl list devices

# 使用实际可用的模拟器名称
xcodebuild ... -destination 'platform=iOS Simulator,name=iPhone 15'
```

#### 命令行工具未安装
```
xcode-select: error: tool 'xcodebuild' requires Xcode
```

解决方案：
```bash
xcode-select --install
sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
```

### 运行时问题

#### 应用闪退
- 查看设备日志：Window > Devices and Simulators > Open Console
- 检查崩溃报告

#### 文件导入失败
- 检查文件格式是否正确
- 确认文件权限
- 查看 Xcode 控制台的错误信息

## 发布到 App Store

### 准备工作

1. **Apple Developer 账号**
   - 个人或组织账号（$99/年）
   - 企业账号（$299/年）

2. **App Store Connect 设置**
   - 创建 App 记录
   - 填写 App 信息
   - 上传截图和描述

3. **隐私政策**
   - 如果使用用户数据，需要提供隐私政策 URL

### 提交流程

1. **创建 Archive**
   ```bash
   Product > Archive (在 Xcode 中)
   ```

2. **验证 Archive**
   - 在 Organizer 中选择 Archive
   - 点击 "Validate App"
   - 解决所有问题

3. **上传到 App Store Connect**
   - 点击 "Distribute App"
   - 选择 "App Store Connect"
   - 按照向导完成上传

4. **在 App Store Connect 中提交审核**
   - 登录 App Store Connect
   - 选择应用
   - 创建新版本
   - 填写更新说明
   - 选择上传的构建
   - 提交审核

### 审核准备

- 确保应用功能完整
- 准备测试账号（如果需要）
- 准备演示视频（如果需要）
- 检查 App Store 审核指南

## 维护和更新

### 定期维护

- 更新 Swift 版本
- 更新 iOS SDK 版本
- 检查废弃 API
- 性能优化

### 发布更新

1. 修改代码
2. 更新版本号
3. 测试所有功能
4. 创建 Archive
5. 提交到 App Store

## 资源链接

- [Xcode 文档](https://developer.apple.com/documentation/xcode)
- [Swift 文档](https://docs.swift.org/)
- [SwiftUI 教程](https://developer.apple.com/tutorials/swiftui)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Apple Developer Portal](https://developer.apple.com/)
