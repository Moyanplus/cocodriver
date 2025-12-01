/// 依赖注入容器管理
///
/// 使用GetIt作为依赖注入框架，统一管理应用程序的所有依赖关系
/// 包括服务、数据源、仓库等组件的注册和获取
///
/// 主要功能：
/// - 注册和获取各种服务实例
/// - 管理外部依赖（SharedPreferences、Hive等）
/// - 提供单例模式的服务管理
/// - 支持懒加载和工厂模式
///
/// 作者: Flutter开发团队
/// 版本: 1.0.0
/// 创建时间: 2024年
library;

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

// 核心服务导入
import '../services/theme_service.dart';
import '../services/localization_service.dart';
import '../utils/memory_manager.dart';
import '../utils/performance_monitor.dart';
import '../utils/app_utils.dart';

// 网络和数据层导入
import '../data/data_sources/local/local_data_source.dart';
import '../data/data_sources/remote/remote_data_source.dart';
import '../data/repositories/base_repository.dart';

// 错误处理和日志系统导入
import '../error/error_handler.dart';
import '../logging/log_manager.dart';
import '../logging/log_config.dart';
import '../logging/log_formatter.dart';

/// 全局依赖注入容器实例
/// 使用GetIt框架管理应用程序的所有依赖关系
final GetIt sl = GetIt.instance;

/// 初始化依赖注入容器
///
/// 按照依赖关系顺序注册所有服务：
/// 1. 外部依赖（SharedPreferences、Hive等）
/// 2. 核心服务（主题、本地化、内存管理等）
/// 3. 日志系统
/// 4. 数据源（本地和远程）
/// 5. 仓库层
///
/// 使用懒加载模式，只有在第一次使用时才创建实例
Future<void> init() async {
  // ==================== 外部依赖注册 ====================
  // SharedPreferences - 用于存储简单的键值对数据
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Hive数据库 - 用于存储复杂对象数据
  await Hive.initFlutter();
  await getApplicationDocumentsDirectory();
  final hiveBox = await Hive.openBox('app_data');
  sl.registerLazySingleton<Box>(() => hiveBox);

  // ==================== 核心服务注册 ====================
  // 主题服务 - 管理应用主题切换
  sl.registerLazySingleton<ThemeService>(() => ThemeService());

  // 本地化服务 - 管理多语言支持
  sl.registerLazySingleton<LocalizationService>(() => LocalizationService());

  // 内存管理器 - 监控和管理内存使用
  sl.registerLazySingleton<MemoryManager>(() => MemoryManager());

  // 性能监控器 - 监控应用性能指标
  sl.registerLazySingleton<PerformanceMonitor>(() => PerformanceMonitor());

  // 应用工具类 - 提供通用工具方法
  sl.registerLazySingleton<AppUtils>(() => AppUtils());

  // 错误处理器 - 统一处理应用错误
  sl.registerLazySingleton<ErrorHandler>(() => ErrorHandler());

  // ==================== 日志系统注册 ====================
  // 日志配置 - 管理日志输出配置
  sl.registerLazySingleton<LogConfig>(() => LogConfig());

  // 日志管理器 - 统一管理日志输出
  sl.registerLazySingleton<LogManager>(() => LogManager());

  // 日志格式化器 - 格式化日志输出
  sl.registerLazySingleton<LogFormatter>(() => LogFormatter());

  // ==================== 数据源注册 ====================
  // 本地数据源 - SharedPreferences数据源
  sl.registerLazySingleton<SharedPreferencesDataSource>(
    () => SharedPreferencesDataSource(sl<SharedPreferences>()),
  );

  // 本地数据源 - Hive数据源
  sl.registerLazySingleton<HiveDataSource>(() => HiveDataSource(sl<Box>()));

  // 远程数据源 - 用户相关API
  sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSource());

  // 远程数据源 - 系统相关API
  sl.registerLazySingleton<SystemRemoteDataSource>(
    () => SystemRemoteDataSource(),
  );

  // 远程数据源 - 反馈相关API
  sl.registerLazySingleton<FeedbackRemoteDataSource>(
    () => FeedbackRemoteDataSource(),
  );

  // ==================== 仓库层注册 ====================
  // 用户仓库 - 管理用户相关数据
  sl.registerLazySingleton<UserRepository>(
    () => UserRepository(
      localDataSource: sl<SharedPreferencesDataSource>(),
      remoteDataSource: sl<UserRemoteDataSource>(),
    ),
  );

  // 系统仓库 - 管理系统相关数据
  sl.registerLazySingleton<SystemRepository>(
    () => SystemRepository(
      localDataSource: sl<SharedPreferencesDataSource>(),
      remoteDataSource: sl<SystemRemoteDataSource>(),
    ),
  );

  // 反馈仓库 - 管理反馈相关数据
  sl.registerLazySingleton<FeedbackRepository>(
    () => FeedbackRepository(
      localDataSource: sl<SharedPreferencesDataSource>(),
      remoteDataSource: sl<FeedbackRemoteDataSource>(),
    ),
  );

  // ==================== 其他服务注册 ====================
  // 可以在这里添加其他需要依赖注入的服务

  // ==================== 初始化日志系统 ====================
  await sl<LogManager>().initialize();
}

/// 重置依赖注入容器
///
/// 清空所有已注册的依赖，然后重新初始化
/// 主要用于测试环境或需要重新加载配置的场景
Future<void> reset() async {
  await sl.reset();
  await init();
}

/// 获取指定类型的依赖实例
///
/// [T] 依赖的类型
/// 返回已注册的依赖实例
///
/// 如果依赖未注册，会抛出异常
T get<T extends Object>() => sl.get<T>();

/// 获取指定类型的依赖实例（可选）
///
/// [T] 依赖的类型
/// 返回已注册的依赖实例，如果未注册则返回null
///
/// 不会抛出异常，适合用于可选依赖的场景
T? getOrNull<T extends Object>() {
  try {
    return sl.get<T>();
  } catch (e) {
    return null;
  }
}

/// 检查指定类型的依赖是否已注册
///
/// [T] 依赖的类型
/// 返回true表示已注册，false表示未注册
bool isRegistered<T extends Object>() => sl.isRegistered<T>();
