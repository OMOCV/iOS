# ABB Robot Reader - 技术文档

## 架构概述

### 应用架构

ABB Robot Reader 采用现代 iOS 开发架构：

```
┌─────────────────────────────────────────┐
│           SwiftUI Views                 │
│  (ContentView, CodeEditorView, etc.)    │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│          View Models                    │
│      (State Management)                 │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│           Models                        │
│  (ABBModule, ABBRoutine, ABBFile)       │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│          Parsers                        │
│  (ABBFileParser, SyntaxHighlighter)     │
└─────────────────────────────────────────┘
```

### 设计模式

1. **MVVM (Model-View-ViewModel)**
   - Models: 数据结构定义
   - Views: SwiftUI 视图
   - ViewModels: 通过 @State 和 @Binding 管理

2. **Coordinator Pattern**
   - DocumentPicker 协调文件选择和导入

3. **Parser Pattern**
   - ABBFileParser 负责解析文件
   - SyntaxHighlighter 负责语法高亮

## 核心组件

### 1. Models (数据模型)

#### ABBModule
表示 ABB RAPID 模块。

```swift
struct ABBModule {
    var name: String              // 模块名称
    var type: ModuleType          // 模块类型
    var routines: [ABBRoutine]    // 例行程序列表
    var declarations: [String]    // 变量声明
    var content: String           // 完整内容
    
    enum ModuleType {
        case program    // MODULE
        case system     // SYSMODULE
        case user       // USERMODULE
    }
}
```

#### ABBRoutine
表示 ABB RAPID 例行程序（过程、函数、陷阱）。

```swift
struct ABBRoutine {
    var name: String              // 例行程序名称
    var type: RoutineType         // 类型
    var parameters: [String]      // 参数列表
    var content: String           // 代码内容
    var lineNumber: Int           // 起始行号
    
    enum RoutineType {
        case proc   // PROC (过程)
        case func   // FUNC (函数)
        case trap   // TRAP (陷阱)
    }
}
```

#### ABBFile
表示完整的 ABB 文件。

```swift
struct ABBFile {
    var name: String              // 文件名
    var url: URL                  // 文件位置
    var modules: [ABBModule]      // 模块列表
    var rawContent: String        // 原始内容
}
```

### 2. Parsers (解析器)

#### ABBFileParser

负责解析 ABB RAPID 文件，识别模块、例行程序和声明。

**解析流程**:

```
读取文件 → 按行解析 → 识别模块 → 识别例行程序 → 提取声明 → 构建数据结构
```

**关键功能**:

1. **模块识别**
   - 匹配 `MODULE`, `SYSMODULE`, `USERMODULE` 关键字
   - 提取模块名称
   - 确定模块边界 (`ENDMODULE`)

2. **例行程序识别**
   - 匹配 `PROC`, `FUNC`, `TRAP` 关键字
   - 提取例行程序名称和参数
   - 确定例行程序边界 (`ENDPROC`, `ENDFUNC`, `ENDTRAP`)

3. **声明提取**
   - 识别 `VAR`, `PERS`, `CONST` 声明
   - 过滤注释行

**代码示例**:

```swift
static func parse(fileURL: URL) throws -> ABBFile {
    let content = try String(contentsOf: fileURL, encoding: .utf8)
    let lines = content.components(separatedBy: .newlines)
    
    // 逐行解析
    for line in lines {
        if line.hasPrefix("MODULE") {
            // 处理模块
        } else if line.hasPrefix("PROC") {
            // 处理过程
        }
        // ... 更多解析逻辑
    }
    
    return ABBFile(...)
}
```

#### SyntaxHighlighter

负责为 ABB RAPID 代码提供语法高亮。

**高亮规则**:

| 元素 | 颜色 | 样式 |
|------|------|------|
| 关键字 | Purple | Bold |
| 数据类型 | Blue | Normal |
| 指令 | Orange | Normal |
| 注释 | Green | Normal |
| 字符串 | Red | Normal |
| 数字 | Cyan | Normal |

**实现原理**:

1. 使用 `AttributedString` 存储带格式的文本
2. 使用正则表达式匹配不同类型的语法元素
3. 为匹配的元素设置颜色和样式

**代码示例**:

```swift
static func highlight(_ text: String) -> AttributedString {
    var attributedString = AttributedString(text)
    
    // 高亮注释
    if line.hasPrefix("!") {
        attributedString[lineRange].foregroundColor = .green
    }
    
    // 高亮关键字
    if keywords.contains(word) {
        attributedString[wordRange].foregroundColor = .purple
        attributedString[wordRange].font = .bold()
    }
    
    return attributedString
}
```

### 3. Views (视图)

#### ContentView
主视图，应用的入口点。

**功能**:
- 显示欢迎屏幕（无文件时）
- 显示文件列表（有文件时）
- 管理文件导入
- 文件清除功能

**状态管理**:
```swift
@State private var files: [ABBFile] = []
@State private var selectedFile: ABBFile?
@State private var showDocumentPicker = false
```

#### FileListView
显示已导入文件的列表。

**功能**:
- 显示文件名和模块数量
- 显示每个模块的例行程序数量
- 支持选择文件查看详情

#### CodeEditorView
显示文件的详细内容。

**功能**:
- 模块列表展示
- 声明列表（可折叠）
- 例行程序列表（可折叠）
- 代码查看器（带语法高亮）

**层次结构**:
```
CodeEditorView
├── NavigationView
│   └── List
│       └── Section (每个模块)
│           ├── DisclosureGroup (声明)
│           ├── DisclosureGroup (例行程序)
│           └── Button (查看完整模块)
└── Sheet (RoutineDetailView)
```

#### DocumentPicker
文档选择器，用于导入文件。

**功能**:
- 支持多文件选择
- 支持 .mod, .prg, .sys, .cfg 格式
- 自动解析选中的文件
- 错误处理

**实现**:
- 使用 `UIViewControllerRepresentable` 包装 `UIDocumentPickerViewController`
- 使用 Coordinator 模式处理回调

## 文件格式支持

### 支持的文件类型

应用在 `Info.plist` 中声明了对以下文件类型的支持：

```xml
<key>UTImportedTypeDeclarations</key>
<array>
    <dict>
        <key>UTTypeIdentifier</key>
        <string>com.abb.rapid.module</string>
        <key>UTTypeTagSpecification</key>
        <dict>
            <key>public.filename-extension</key>
            <array>
                <string>mod</string>
                <string>MOD</string>
            </array>
        </dict>
    </dict>
    <!-- 更多类型... -->
</array>
```

### ABB RAPID 语法参考

#### 模块结构
```rapid
MODULE ModuleName
    ! 声明
    VAR num myVar;
    PERS robtarget myTarget;
    CONST num PI := 3.14;
    
    ! 例行程序
    PROC MyProc()
        ! 代码
    ENDPROC
    
ENDMODULE
```

#### 例行程序类型

1. **PROC (过程)**
   - 不返回值
   - 用于执行操作

2. **FUNC (函数)**
   - 返回值
   - 用于计算

3. **TRAP (陷阱)**
   - 中断处理程序
   - 响应事件

## 性能考虑

### 解析优化

1. **流式解析**: 逐行读取，不需要一次加载整个文件到内存
2. **惰性加载**: 只在需要时解析例行程序内容
3. **缓存**: 解析结果存储在内存中，避免重复解析

### UI 优化

1. **懒加载列表**: 使用 SwiftUI `List` 自动优化大列表渲染
2. **异步加载**: 文件导入在后台线程进行
3. **视图复用**: SwiftUI 自动复用视图

### 内存管理

1. **弱引用**: 避免循环引用
2. **及时释放**: 清除文件时释放所有相关数据
3. **文件访问**: 使用 `startAccessingSecurityScopedResource` 正确管理文件访问

## 安全考虑

### 文件访问

```swift
if url.startAccessingSecurityScopedResource() {
    defer { url.stopAccessingSecurityScopedResource() }
    // 访问文件
}
```

### 错误处理

```swift
do {
    let file = try ABBFileParser.parse(fileURL: url)
} catch {
    print("Error: \(error)")
    // 显示错误给用户
}
```

### 沙盒限制

- 应用只能访问用户明确选择的文件
- 使用 document picker 确保用户知情

## 测试策略

### 单元测试

建议测试：

1. **ABBFileParser**
   - 测试各种 RAPID 语法
   - 测试边界情况
   - 测试错误处理

2. **SyntaxHighlighter**
   - 测试高亮准确性
   - 测试性能

### UI 测试

建议测试：

1. **文件导入流程**
2. **文件列表显示**
3. **代码查看器**

### 集成测试

使用提供的示例文件进行端到端测试。

## 扩展可能性

### 未来功能

1. **搜索功能**
   - 在代码中搜索文本
   - 搜索例行程序名称

2. **导出功能**
   - 导出高亮后的代码为 PDF
   - 分享功能

3. **编辑功能**
   - 简单的代码编辑
   - 保存修改

4. **语法检查**
   - 检测常见语法错误
   - 提供修复建议

5. **代码分析**
   - 依赖关系图
   - 调用链分析

### 扩展架构

```swift
// 插件系统
protocol ABBPlugin {
    func process(file: ABBFile) -> ABBFile
}

// 示例插件
class SyntaxCheckerPlugin: ABBPlugin {
    func process(file: ABBFile) -> ABBFile {
        // 检查语法
    }
}
```

## 依赖管理

当前应用不使用外部依赖，完全使用 iOS SDK。

如果需要添加依赖，可以使用：

1. **Swift Package Manager** (推荐)
2. **CocoaPods**
3. **Carthage**

## 版本历史

### v1.0.0 (当前)

- ✅ 基本文件解析
- ✅ 语法高亮
- ✅ 模块和例行程序识别
- ✅ 文件导入导出
- ✅ SwiftUI 界面

## 贡献指南

### 代码风格

- 使用 Swift 标准命名约定
- 添加注释说明复杂逻辑
- 保持函数简短和单一职责

### 提交流程

1. Fork 项目
2. 创建功能分支
3. 提交代码
4. 创建 Pull Request

## 许可证

请参考项目根目录的 LICENSE 文件。
