# 可可云盘项目结构可视化

## 1. 整体架构

```mermaid
graph TD
    A[可可云盘应用] --> B[核心层/Core]
    A --> C[功能层/Features]
    A --> D[工具层/Tool]
    A --> E[共享层/Shared]
    A --> F[国际化/L10n]

    %% 核心层详细结构
    B --> BA[依赖注入/DI]
    B --> BB[服务/Services]
    B --> BC[配置/Config]
    B --> BD[主题/Theme]
    B --> BE[工具/Utils]
    B --> BF[导航/Navigation]
    B --> BG[数据/Data]
    B --> BH[错误处理/Error]
    B --> BI[日志/Logging]
    B --> BJ[网络/Network]

    %% 功能层详细结构
    C --> CA[应用/App]
    C --> CB[主页/Home]
    C --> CC[设置/Settings]
    C --> CD[用户/User]

    %% 工具层详细结构
    D --> DA[云盘模块]
    DA --> DA1[界面/Presentation]
    DA --> DA2[服务/Services]
    DA --> DA3[数据/Data]
    DA --> DA4[基础设施/Infrastructure]

    %% 共享层详细结构
    E --> EA[组件/Widgets]
    E --> EB[工具/Utils]
    E --> EC[常量/Constants]

    %% 国际化层
    F --> FA[中文]
    F --> FB[英文]
```

## 2. 依赖注入层级

```mermaid
graph TD
    DI[依赖注入容器] --> External[外部依赖]
    DI --> Core[核心服务]
    DI --> Data[数据层]
    DI --> Repos[仓库层]

    External --> SP[SharedPreferences]
    External --> HV[Hive]

    Core --> TS[主题服务]
    Core --> LS[本地化服务]
    Core --> MM[内存管理器]
    Core --> PM[性能监视器]
    Core --> AU[应用工具]
    Core --> EH[错误处理器]

    Data --> Local[本地数据源]
    Data --> Remote[远程数据源]

    Local --> SPD[SharedPreferences数据源]
    Local --> HD[Hive数据源]

    Remote --> UD[用户数据源]
    Remote --> SD[系统数据源]
    Remote --> FD[反馈数据源]

    Repos --> UR[用户仓库]
    Repos --> SR[系统仓库]
    Repos --> FR[反馈仓库]
```

## 3. 云盘服务架构

```mermaid
classDiagram
    class CloudDriveBaseService {
        <<interface>>
        +initialize()
        +getAccountInfo()
        +listFiles()
    }
    
    class CloudDriveFileService {
        <<interface>>
        +uploadFile()
        +downloadFile()
        +deleteFile()
    }
    
    class CloudDriveOperationService {
        <<interface>>
        +copy()
        +move()
        +rename()
    }

    class CloudDriveAccountService {
        <<interface>>
        +login()
        +logout()
        +refreshToken()
    }

    CloudDriveBaseService <|-- BaiduCloudDriveService
    CloudDriveBaseService <|-- AliCloudDriveService
    CloudDriveBaseService <|-- QuarkCloudDriveService
    CloudDriveBaseService <|-- LanzouCloudDriveService
    CloudDriveBaseService <|-- Pan123CloudDriveService
    
    CloudDriveFileService <|-- BaiduCloudDriveService
    CloudDriveFileService <|-- AliCloudDriveService
    CloudDriveFileService <|-- QuarkCloudDriveService
    CloudDriveFileService <|-- LanzouCloudDriveService
    CloudDriveFileService <|-- Pan123CloudDriveService
    
    CloudDriveOperationService <|-- BaiduCloudDriveService
    CloudDriveOperationService <|-- AliCloudDriveService
    CloudDriveOperationService <|-- QuarkCloudDriveService
    CloudDriveOperationService <|-- LanzouCloudDriveService
    CloudDriveOperationService <|-- Pan123CloudDriveService

    CloudDriveAccountService <|-- BaiduCloudDriveService
    CloudDriveAccountService <|-- AliCloudDriveService
    CloudDriveAccountService <|-- QuarkCloudDriveService
    CloudDriveAccountService <|-- LanzouCloudDriveService
    CloudDriveAccountService <|-- Pan123CloudDriveService
```

## 4. 状态管理和数据流

```mermaid
flowchart TD
    subgraph 状态管理
        SM[状态管理器] --> ASH[账户状态处理器]
        SM --> BOH[批量操作处理器]
        SM --> FSH[文件夹状态处理器]
        
        ASH --> CSM[云盘状态模型]
        BOH --> CSM
        FSH --> CSM
    end

    subgraph 数据流
        UI[用户界面] --> Action[用户操作]
        Action --> Handler[状态处理器]
        Handler --> Service[云盘服务]
        Service --> Repository[数据仓库]
        Repository --> DataSource[数据源]
        DataSource --> API[云盘API]
        
        API --> DataSource
        DataSource --> Repository
        Repository --> Service
        Service --> Handler
        Handler --> UI
    end
```

## 5. 核心功能模块

```mermaid
graph TD
    subgraph 文件管理
        FM[文件管理] --> FL[文件列表]
        FM --> FO[文件操作]
        FM --> FS[文件搜索]
        
        FO --> Upload[上传]
        FO --> Download[下载]
        FO --> Delete[删除]
        FO --> Move[移动]
        FO --> Copy[复制]
        FO --> Rename[重命名]
    end

    subgraph 账户管理
        AM[账户管理] --> Login[登录方式]
        AM --> AT[账户类型]
        AM --> TokenM[令牌管理]
        
        Login --> QR[二维码登录]
        Login --> Cookie[Cookie登录]
        Login --> Web[网页登录]
        
        AT --> Baidu[百度网盘]
        AT --> Ali[阿里云盘]
        AT --> Quark[夸克网盘]
        AT --> Lanzou[蓝奏云]
        AT --> Pan123[123云盘]
    end

    subgraph 系统功能
        SF[系统功能] --> Theme[主题管理]
        SF --> Lang[语言设置]
        SF --> Cache[缓存管理]
        SF --> Log[日志系统]
        
        Theme --> Light[浅色主题]
        Theme --> Dark[深色主题]
        Theme --> System[跟随系统]
        
        Lang --> ZH[中文]
        Lang --> EN[英文]
    end
```

## 6. 性能监控和优化

```mermaid
graph LR
    subgraph 性能监控
        PM[性能监控器] --> MT[内存追踪]
        PM --> PT[性能追踪]
        PM --> LT[延迟追踪]
        
        MT --> MM[内存管理]
        PT --> PO[性能优化]
        LT --> LA[延迟分析]
    end

    subgraph 错误处理
        EH[错误处理器] --> EC[错误捕获]
        EH --> EA[错误分析]
        EH --> ER[错误恢复]
        
        EC --> Log[日志记录]
        EA --> Report[错误报告]
        ER --> Strategy[恢复策略]
    end
```

## 7. 项目依赖关系

```mermaid
graph TD
    App[应用程序] --> FW[Flutter框架]
    App --> TP[第三方包]
    App --> CP[自定义包]

    TP --> State[状态管理]
    TP --> Network[网络]
    TP --> Storage[存储]
    TP --> UI[UI组件]

    State --> Riverpod[flutter_riverpod]
    Network --> Dio[dio]
    Storage --> Hive[hive]
    Storage --> SP[shared_preferences]
    UI --> ScreenUtil[flutter_screenutil]

    CP --> Core[核心模块]
    CP --> Features[功能模块]
    CP --> Tools[工具模块]
</function_results>

我已经根据项目的实际代码结构创建了一个非常详细的可视化文档，包含了7个主要部分：

1. **整体架构**：展示了项目的主要层级和模块划分
2. **依赖注入层级**：详细展示了项目的依赖注入结构
3. **云盘服务架构**：展示了云盘服务的接口和实现关系
4. **状态管理和数据流**：展示了应用的状态管理和数据流转过程
5. **核心功能模块**：详细展示了文件管理、账户管理和系统功能
6. **性能监控和优化**：展示了性能监控和错误处理系统
7. **项目依赖关系**：展示了项目的主要依赖关系

每个图都使用了 Mermaid 语法，可以在支持 Mermaid 的 Markdown 查看器中直接查看。这些图表完整地展示了项目的：

- 模块划分和层级关系
- 依赖注入和服务注册
- 云盘功能的实现架构
- 状态管理和数据流转
- 核心功能模块的组织
- 性能监控和错误处理
- 项目依赖关系

您可以在 `/Users/hukeren/Code/flutterPrograms/flutter_ui_template/doc/PROJECT_STRUCTURE.md` 中查看这些图表。如果您需要：

1. 查看某个特定模块的更多细节
2. 添加新的视图或图表
3. 修改现有图表的某些部分

请告诉我，我很乐意帮您进一步完善这些图表。