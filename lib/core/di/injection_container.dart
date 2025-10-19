import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../services/theme_service.dart';
import '../services/localization_service.dart';
import '../utils/memory_manager.dart';
import '../utils/performance_monitor.dart';
import '../utils/app_utils.dart';
import '../network/api_client.dart';
import '../data/data_sources/local/local_data_source.dart';
import '../data/data_sources/remote/remote_data_source.dart';
import '../data/repositories/base_repository.dart';
import '../error/error_handler.dart';
import '../logging/log_manager.dart';
import '../logging/log_config.dart';
import '../logging/log_formatter.dart';

/// 依赖注入容器
/// 使用GetIt管理应用的所有依赖
final GetIt sl = GetIt.instance;

/// 初始化依赖注入容器
Future<void> init() async {
  // ==================== 外部依赖 ====================
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Hive数据库
  await Hive.initFlutter();
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final hiveBox = await Hive.openBox('app_data');
  sl.registerLazySingleton<Box>(() => hiveBox);

  // ==================== 核心服务 ====================
  // 主题服务
  sl.registerLazySingleton<ThemeService>(() => ThemeService());

  // 本地化服务
  sl.registerLazySingleton<LocalizationService>(() => LocalizationService());

  // 内存管理器
  sl.registerLazySingleton<MemoryManager>(() => MemoryManager());

  // 性能监控器
  sl.registerLazySingleton<PerformanceMonitor>(() => PerformanceMonitor());

  // 工具类
  sl.registerLazySingleton<AppUtils>(() => AppUtils());

  // 错误处理器
  sl.registerLazySingleton<ErrorHandler>(() => ErrorHandler());

  // ==================== 日志系统 ====================
  // 日志配置
  sl.registerLazySingleton<LogConfig>(() => LogConfig());

  // 日志管理器
  sl.registerLazySingleton<LogManager>(() => LogManager());

  // 日志格式化器
  sl.registerLazySingleton<LogFormatter>(() => LogFormatter());

  // ==================== 数据源 ====================
  // 本地数据源
  sl.registerLazySingleton<SharedPreferencesDataSource>(
    () => SharedPreferencesDataSource(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<HiveDataSource>(() => HiveDataSource(sl<Box>()));

  // 远程数据源
  sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSource());
  sl.registerLazySingleton<SystemRemoteDataSource>(
    () => SystemRemoteDataSource(),
  );
  sl.registerLazySingleton<FeedbackRemoteDataSource>(
    () => FeedbackRemoteDataSource(),
  );

  // ==================== 仓库 ====================
  // 用户仓库
  sl.registerLazySingleton<UserRepository>(
    () => UserRepository(
      localDataSource: sl<SharedPreferencesDataSource>(),
      remoteDataSource: sl<UserRemoteDataSource>(),
    ),
  );

  // 系统仓库
  sl.registerLazySingleton<SystemRepository>(
    () => SystemRepository(
      localDataSource: sl<SharedPreferencesDataSource>(),
      remoteDataSource: sl<SystemRemoteDataSource>(),
    ),
  );

  // 反馈仓库
  sl.registerLazySingleton<FeedbackRepository>(
    () => FeedbackRepository(
      localDataSource: sl<SharedPreferencesDataSource>(),
      remoteDataSource: sl<FeedbackRemoteDataSource>(),
    ),
  );

  // ==================== 其他服务 ====================
  // 可以在这里添加其他需要依赖注入的服务

  // ==================== 初始化日志系统 ====================
  await sl<LogManager>().initialize();
}

/// 重置依赖注入容器
Future<void> reset() async {
  await sl.reset();
  await init();
}

/// 获取依赖
T get<T extends Object>() => sl.get<T>();

/// 获取可选依赖
T? getOrNull<T extends Object>() {
  try {
    return sl.get<T>();
  } catch (e) {
    return null;
  }
}

/// 检查依赖是否已注册
bool isRegistered<T extends Object>() => sl.isRegistered<T>();
