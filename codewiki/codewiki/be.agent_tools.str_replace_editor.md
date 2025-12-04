# be.agent_tools.str_replace_editor 模块文档

## 简介

`be.agent_tools.str_replace_editor` 模块是 CodeWiki 系统的核心文件编辑工具，提供了强大的文件查看、创建和编辑功能。该模块基于 SWE-agent 项目开发，专为 AI 代理设计，支持智能代码编辑和文档管理。

## 核心功能

该模块提供了以下主要功能：

- **文件查看**：支持查看文件和目录内容，提供行号显示和范围查看
- **文件创建**：创建新文件并写入内容
- **字符串替换**：精确替换文件中的特定字符串
- **内容插入**：在指定行插入新内容
- **编辑撤销**：支持撤销最近的编辑操作
- **语法检查**：集成 flake8 进行 Python 代码语法检查
- **智能窗口扩展**：自动扩展查看范围以包含完整的函数或类
- **文件映射**：为大型文件提供缩略图视图

## 架构设计

### 组件结构图

```mermaid
graph TB
    subgraph "be.agent_tools.str_replace_editor"
        ET[EditTool]
        WE[WindowExpander]
        FM[Filemap]
        SRE[str_replace_editor函数]
        
        ET --> WE
        ET --> FM
        SRE --> ET
    end
    
    subgraph "外部依赖"
        CD[CodeWikiDeps]
        VM[validate_mermaid_diagrams]
        F8[flake8]
        TS[tree-sitter]
    end
    
    SRE --> CD
    SRE --> VM
    ET --> F8
    FM --> TS
```

### 数据流图

```mermaid
sequenceDiagram
    participant User
    participant str_replace_editor
    participant EditTool
    participant FileSystem
    participant Linter
    
    User->>str_replace_editor: 调用编辑命令
    str_replace_editor->>EditTool: 创建工具实例
    EditTool->>FileSystem: 验证路径
    EditTool->>FileSystem: 执行文件操作
    EditTool->>Linter: 语法检查(可选)
    EditTool->>str_replace_editor: 返回操作结果
    str_replace_editor->>User: 显示结果和日志
```

## 核心组件详解

### 1. EditTool 类

`EditTool` 是模块的核心类，提供了完整的文件操作功能。

#### 主要属性

- `REGISTRY`: 用于存储文件历史记录
- `absolute_docs_path`: 文档目录的绝对路径
- `logs`: 操作日志列表
- `_file_history`: 文件编辑历史

#### 核心方法

```mermaid
graph LR
    subgraph "EditTool方法"
        VF[view] --> |查看文件| FO[格式化输出]
        CF[create_file] --> |创建文件| WF[写入文件]
        SR[str_replace] --> |字符串替换| UR[唯一性检查]
        IN[insert] --> |插入内容| VL[验证行号]
        UE[undo_edit] --> |撤销编辑| RH[历史记录]
        
        UR --> |语法检查| FL[flake8]
        WF --> FH[文件历史]
    end
```

#### 路径验证机制

```mermaid
flowchart TD
    Start[接收路径] --> IsAbsolute{是否为绝对路径?}
    IsAbsolute -->|否| SuggestPath[建议绝对路径]
    IsAbsolute -->|是| CheckExists{检查路径存在}
    CheckExists -->|不存在| CheckCommand{检查命令类型}
    CheckCommand -->|非create| ErrorNotExist[路径不存在错误]
    CheckCommand -->|create| CheckParent{检查父目录}
    CheckExists -->|存在| CheckDir{是否为目录}
    CheckDir -->|是| CheckDirCommand{检查目录命令}
    CheckDirCommand -->|非view| ErrorDir[目录只能使用view命令]
    CheckDirCommand -->|view| Success[验证通过]
    CheckParent -->|存在| Success
    CheckParent -->|不存在| ErrorParent[父目录不存在错误]
```

### 2. WindowExpander 类

`WindowExpander` 提供智能窗口扩展功能，自动调整查看范围以包含完整的代码结构。

#### 扩展算法

```mermaid
flowchart LR
    Start[输入窗口范围] --> FindBreakpoints[查找断点]
    FindBreakpoints --> ScoreLines[行评分机制]
    ScoreLines --> ExpandUp[向上扩展]
    ScoreLines --> ExpandDown[向下扩展]
    ExpandUp --> MergeRange[合并范围]
    ExpandDown --> MergeRange
    MergeRange --> ReturnNewRange[返回新范围]
```

#### 评分规则

- **空行**: 1分，连续空行2分
- **Python定义**: 3分（函数、类、装饰器）
- **文件边界**: 3分（首行或末行）

### 3. Filemap 类

`Filemap` 为大型 Python 文件提供缩略图视图，通过 tree-sitter 解析语法结构。

#### 处理流程

```mermaid
sequenceDiagram
    participant FM as Filemap
    participant TS as tree-sitter
    participant Q as 查询函数定义
    participant EL as 计算省略行
    participant GL as 生成行号
    participant OF as 格式化输出
    
    FM->>TS: 解析代码结构
    TS->>Q: 查询函数定义
    Q->>EL: 计算省略行范围
    EL->>GL: 生成行号映射
    GL->>OF: 格式化输出结果
    OF->>FM: 返回文件映射
```

### 4. 语法检查集成

模块集成了 flake8 进行 Python 代码语法检查，支持错误过滤和行号调整。

#### 错误处理流程

```mermaid
flowchart TD
    PreLint[编辑前检查] --> SaveErrors[保存错误列表]
    SaveErrors --> Edit[执行编辑]
    Edit --> PostLint[编辑后检查]
    PostLint --> FilterErrors[过滤已有错误]
    FilterErrors --> UpdateLines[更新行号]
    UpdateLines --> FormatOutput[格式化输出]
    FormatOutput --> ShowWarning[显示警告]
```

## 使用模式

### 1. 文件查看模式

```mermaid
stateDiagram-v2
    [*] --> ViewFile
    ViewFile --> ViewRange: 指定范围
    ViewRange --> ExpandWindow: 智能扩展
    ExpandWindow --> TruncateLarge: 大文件截断
    TruncateLarge --> UseFilemap: 使用文件映射
    UseFilemap --> DisplayOutput
    ViewRange --> DisplayOutput
    DisplayOutput --> [*]
```

### 2. 文件编辑模式

```mermaid
stateDiagram-v2
    [*] --> ValidatePath
    ValidatePath --> CheckUnique: 字符串替换
    CheckUnique --> PreLint: 编辑前检查
    PreLint --> ApplyEdit: 应用编辑
    ApplyEdit --> PostLint: 编辑后检查
    PostLint --> UpdateHistory: 更新历史
    UpdateHistory --> ShowSnippet: 显示片段
    ShowSnippet --> [*]
```

## 配置选项

模块提供了多个配置常量来控制行为：

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `MAX_RESPONSE_LEN` | 16000 | 最大响应长度，超出则截断 |
| `MAX_WINDOW_EXPANSION_VIEW` | 0 | 查看模式下的最大窗口扩展 |
| `MAX_WINDOW_EXPANSION_EDIT_CONFIRM` | 0 | 编辑确认模式下的最大窗口扩展 |
| `USE_FILEMAP` | False | 是否启用文件映射功能 |
| `USE_LINTER` | False | 是否启用语法检查 |
| `SNIPPET_LINES` | 4 | 编辑后显示的代码片段行数 |

## 错误处理

模块实现了完善的错误处理机制：

### 路径相关错误
- 非绝对路径错误
- 路径不存在错误
- 文件已存在错误
- 目录操作限制

### 编辑相关错误
- 字符串不唯一错误
- 插入行号无效错误
- 查看范围无效错误

### 编码相关错误
- Unicode 解码错误处理
- 多编码格式尝试
- 编码回退机制

## 与系统集成

### 依赖关系

```mermaid
graph TB
    subgraph "当前模块"
        SRE[str_replace_editor]
    end
    
    subgraph "直接依赖"
        CD[CodeWikiDeps]
        VM[validate_mermaid_diagrams]
    end
    
    subgraph "系统模块"
        AO[be.agent_orchestrator]
        DG[be.documentation_generator]
    end
    
    SRE --> CD
    SRE --> VM
    AO --> SRE
    DG --> SRE
```

### 使用场景

1. **文档生成**: 在文档生成过程中编辑和查看文件
2. **代码分析**: 为代码分析工具提供文件操作能力
3. **AI代理**: 作为 AI 代理的文件系统接口
4. **语法验证**: 集成到文档验证流程中

## 最佳实践

### 1. 路径使用
- 始终使用绝对路径
- 利用 `working_dir` 参数区分 repo 和 docs 目录
- 验证路径存在性

### 2. 编辑操作
- 确保替换字符串的唯一性
- 利用窗口扩展功能查看完整上下文
- 关注语法检查警告

### 3. 大文件处理
- 使用 `view_range` 参数查看特定范围
- 启用文件映射功能获取概览
- 注意响应长度限制

### 4. 错误恢复
- 利用撤销功能恢复错误编辑
- 检查编辑历史记录
- 验证编辑结果

## 相关模块

- [be.agent_orchestrator](be.agent_orchestrator.md): 代理协调器，调用文件编辑工具
- [be.agent_tools.deps](be.agent_tools.deps.md): 依赖管理，提供路径配置
- [be.documentation_generator](be.documentation_generator.md): 文档生成器，使用文件编辑功能
- [utils](utils.md): 工具函数，包含 Mermaid 图表验证等功能