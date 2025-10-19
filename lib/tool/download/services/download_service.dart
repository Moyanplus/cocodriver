import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import '../../../core/services/base/debug_service.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 下载状态回调函数类型
typedef DownloadCallback =
    void Function(String taskId, DownloadTaskStatus status, int progress);

/// flutter_downloader 的顶层回调函数 - 运行在后台isolate
@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  DebugService.log('📡 收到下载状态更新: ID=$id, 状态=$status, 进度=$progress');

  // 将 status 转换为 DownloadTaskStatus
  // 根据 flutter_downloader 实际状态定义：
  // 0: undefined, 1: enqueued, 2: running, 3: complete, 4: failed, 5: canceled, 6: paused
  int taskStatus;
  switch (status) {
    case 0:
      taskStatus = 0; // DownloadTaskStatus.undefined
      DebugService.log('🔄 状态0 -> undefined');
      break;
    case 1:
      taskStatus = 1; // DownloadTaskStatus.enqueued
      DebugService.log('🔄 状态1 -> enqueued');
      break;
    case 2:
      taskStatus = 2; // DownloadTaskStatus.running
      DebugService.log('🔄 状态2 -> running');
      break;
    case 3:
      taskStatus = 3; // DownloadTaskStatus.complete
      DebugService.log('🔄 状态3 -> complete');
      break;
    case 4:
      taskStatus = 4; // DownloadTaskStatus.failed
      DebugService.log('🔄 状态4 -> failed');
      break;
    case 5:
      taskStatus = 5; // DownloadTaskStatus.canceled
      DebugService.log('🔄 状态5 -> canceled');
      break;
    case 6:
      taskStatus = 6; // DownloadTaskStatus.paused
      DebugService.log('🔄 状态6 -> paused');
      break;
    default:
      taskStatus = 0; // DownloadTaskStatus.undefined
      DebugService.log('🔄 状态$status -> undefined (默认) - 未知状态');
  }

  DebugService.log('🔄 状态转换: $status -> $taskStatus');

  // 通过IsolateNameServer发送消息到主isolate
  // 添加重试机制，确保能找到主isolate的SendPort
  SendPort? send;
  int retryCount = 0;
  const maxRetries = 10;

  while (send == null && retryCount < maxRetries) {
    send = IsolateNameServer.lookupPortByName('downloader_send_port');
    if (send == null) {
      retryCount++;
      DebugService.log('🔄 尝试查找SendPort，第$retryCount次重试...');
      // 简单的延迟，不使用Future.delayed
      for (int i = 0; i < 1000000; i++) {
        // 简单的循环延迟
      }
    }
  }

  if (send != null) {
    send.send([id, taskStatus, progress]);
    DebugService.log('📤 消息已发送到主isolate');
  } else {
    DebugService.error('❌ 找不到主isolate的SendPort，已重试$maxRetries次', null);
  }
}

/// 下载服务类 - 负责所有下载相关的业务逻辑
///
/// TODO: 功能完善清单
/// ===================
/// ✅ 已实现的功能:
/// - 下载位置设置 (downloadDirectory)
/// - 显示下载通知 (showNotification)
/// - 下载完成后自动打开 (openFileFromNotification)
/// - 自定义请求头 (customHeaders) - 新增支持
///
/// ⚠️ 部分实现的功能:
/// - 自动重试 (autoRetry, retryCount, retryDelay) - 配置已保存但重试逻辑需要完善
/// - 下载超时 (downloadTimeout) - 需要确认 flutter_downloader 是否支持
/// - 速度限制 (enableSpeedLimit, speedLimit) - 需要确认 flutter_downloader 是否支持速度限制
///
/// ❌ 未实现的功能:
/// - 仅WiFi下载 (downloadOnWifiOnly) - 需要添加网络类型检查逻辑
/// - 移动网络下载 (downloadOnMobileNetwork) - 需要添加网络类型检查逻辑
/// - 最大并发下载数 (maxConcurrentDownloads) - flutter_downloader 有自己的并发控制机制
/// - 断点续传 (enableResume) - flutter_downloader 自动处理续传
///
/// 待完善的功能:
/// 1. 网络类型检查: 使用 connectivity_plus 包检查网络类型
/// 2. 重试逻辑: 在下载失败时使用配置的重试参数
/// 3. 超时控制: 确认 flutter_downloader 是否支持超时设置
/// 4. 速度限制: 确认 flutter_downloader 是否支持速度限制
/// 5. 并发控制: 实现基于配置的并发下载控制
///
/// 自定义请求头使用说明:
/// - 在下载配置页面可以添加自定义HTTP请求头
/// - 支持常见的认证头，如 Authorization: Bearer token
/// - 自定义头会与默认头合并，自定义头优先级更高
/// - 默认头包括: User-Agent, Accept, Accept-Encoding, Connection
class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  // 标记是否已经初始化
  bool _isInitialized = false;

  // 回调列表
  final List<DownloadCallback> _callbacks = [];

  // ReceivePort用于接收后台isolate的消息
  ReceivePort? _receivePort;

  /// 初始化下载监听器
  Future<void> initializeDownloadListener() async {
    try {
      // 避免重复初始化
      if (_isInitialized) {
        DebugService.log('🔄 下载监听器已经初始化，跳过重复初始化');
        return;
      }

      DebugService.log('🔄 开始初始化下载监听器');

      // 创建ReceivePort并注册到IsolateNameServer
      _receivePort = ReceivePort();
      IsolateNameServer.registerPortWithName(
        _receivePort!.sendPort,
        'downloader_send_port',
      );

      DebugService.log('📡 IsolateNameServer注册完成，端口名称: downloader_send_port');

      // 验证注册是否成功
      final registeredPort = IsolateNameServer.lookupPortByName(
        'downloader_send_port',
      );
      if (registeredPort != null) {
        DebugService.log('✅ IsolateNameServer注册验证成功');
      } else {
        DebugService.error('❌ IsolateNameServer注册验证失败', null);
      }

      // 监听来自后台isolate的消息
      _receivePort!.listen((data) {
        if (data is List && data.length == 3) {
          final taskId = data[0] as String;
          final statusIndex = data[1] as int;
          final progress = data[2] as int;

          DebugService.log('🔍 收到状态索引: $statusIndex');

          // 转换状态索引为DownloadTaskStatus
          DownloadTaskStatus status;
          switch (statusIndex) {
            case 0:
              status = DownloadTaskStatus.undefined; // 状态索引0对应undefined
              break;
            case 1:
              status = DownloadTaskStatus.enqueued; // 状态索引1对应enqueued
              break;
            case 2:
              status = DownloadTaskStatus.running; // 状态索引2对应running
              break;
            case 3:
              status = DownloadTaskStatus.complete; // 状态索引3对应complete
              break;
            case 4:
              status = DownloadTaskStatus.failed; // 状态索引4对应failed
              break;
            case 5:
              status = DownloadTaskStatus.canceled; // 状态索引5对应canceled
              break;
            case 6:
              status = DownloadTaskStatus.paused; // 状态索引6对应paused
              break;
            default:
              status = DownloadTaskStatus.undefined;
          }

          DebugService.log('📥 收到主isolate消息: $taskId, $status, $progress%');
          DebugService.log('🔍 状态索引 $statusIndex 转换为 $status');

          // 通知所有注册的回调
          _notifyCallbacks(taskId, status, progress);
        }
      });

      // 注册 flutter_downloader 的回调（使用顶层函数）
      FlutterDownloader.registerCallback(downloadCallback);

      DebugService.log('🔄 下载监听器注册完成，当前回调数量: ${_callbacks.length}');

      _isInitialized = true;
      DebugService.success('✅ 下载监听器初始化完成');
    } catch (e) {
      DebugService.error('❌ 初始化下载监听器失败', e);
    }
  }

  /// 注册下载状态回调
  void registerCallback(DownloadCallback callback) {
    // 检查回调是否已经存在
    if (!_callbacks.contains(callback)) {
      _callbacks.add(callback);
      DebugService.log('📝 注册下载状态回调，当前回调数量: ${_callbacks.length}');
      DebugService.log('📝 回调函数地址: ${callback.hashCode}');
    } else {
      DebugService.log('📝 回调已存在，跳过注册，当前回调数量: ${_callbacks.length}');
    }
  }

  /// 移除下载状态回调
  void unregisterCallback(DownloadCallback callback) {
    final removed = _callbacks.remove(callback);
    DebugService.log('📝 移除下载状态回调，当前回调数量: ${_callbacks.length}');
    DebugService.log('📝 回调函数地址: ${callback.hashCode}');
    DebugService.log('📝 是否成功移除: $removed');
  }

  /// 通知所有回调
  void _notifyCallbacks(
    String taskId,
    DownloadTaskStatus status,
    int progress,
  ) {
    DebugService.log('📢 通知回调，当前回调数量: ${_callbacks.length}');

    // 如果回调列表为空，记录警告
    if (_callbacks.isEmpty) {
      DebugService.error('⚠️ 警告：回调列表为空，可能回调被意外清空', null);
    }

    for (final callback in _callbacks) {
      try {
        callback(taskId, status, progress);
        DebugService.log('✅ 回调执行成功');
      } catch (e) {
        DebugService.error('❌ 回调执行失败', e);
      }
    }
  }

  /// 销毁时清理资源
  void dispose() {
    if (_receivePort != null) {
      IsolateNameServer.removePortNameMapping('downloader_send_port');
      _receivePort!.close();
      _receivePort = null;
    }
    _callbacks.clear();
    DebugService.log('🗑️ DownloadService已销毁');
  }

  /// 加载所有下载任务
  Future<List<DownloadTask>?> loadTasks() async {
    try {
      DebugService.log('🔄 开始加载下载任务');
      final tasks = await FlutterDownloader.loadTasks();
      DebugService.log('📊 加载到 ${tasks?.length ?? 0} 个下载任务');
      return tasks;
    } catch (e) {
      DebugService.error('❌ 加载下载任务失败', e);
      return null;
    }
  }

  /// 创建下载任务
  Future<String?> createDownloadTask({
    required String url,
    String? fileName,
    required String downloadDir,
    required bool showNotification,
    required bool openFileFromNotification,
    required bool isExternalStorage,
    Map<String, String>? customHeaders, // TODO: 新增 - 支持自定义请求头
  }) async {
    try {
      DebugService.log('🚀 开始创建下载任务');
      DebugService.log('🔗 URL: $url');
      DebugService.log('📄 文件名: $fileName');
      DebugService.log('📁 下载目录: $downloadDir');
      DebugService.log('📁 是否外部存储: $isExternalStorage');
      DebugService.log('📋 自定义请求头: ${customHeaders?.length ?? 0} 个');

      // 确保目录存在
      await _ensureDirectoryExists(downloadDir);

      // 处理文件名
      final processedFileName = _processFileName(fileName, url);

      // 构建请求头 - 支持自定义请求头
      final headers = <String, String>{
        'User-Agent': 'Cocobox/1.0',
        'Accept': '*/*',
        'Accept-Encoding': 'identity', // 避免压缩，便于续传
        'Connection': 'keep-alive',
      };

      // 如果提供了自定义请求头，合并到默认请求头中
      if (customHeaders != null && customHeaders.isNotEmpty) {
        headers.addAll(customHeaders);
        DebugService.log('📋 合并自定义请求头: ${customHeaders.keys.join(', ')}');
      }

      DebugService.log('📋 最终请求头: ${headers.keys.join(', ')}');

      // 处理外部存储的目录路径 - 简化处理
      String finalSavedDir = downloadDir;
      bool finalSaveInPublicStorage = isExternalStorage;
      String finalProcessedFileName = processedFileName ?? '';

      DebugService.log('📁 路径处理:');
      DebugService.log('  - 配置目录: $downloadDir');
      DebugService.log('  - 保存目录: $finalSavedDir');
      DebugService.log('  - 文件名: $finalProcessedFileName');
      DebugService.log('  - 是否外部存储: $finalSaveInPublicStorage');

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: finalSavedDir,
        fileName: finalProcessedFileName,
        showNotification: showNotification,
        openFileFromNotification: openFileFromNotification,
        saveInPublicStorage: finalSaveInPublicStorage,
        headers: headers, // 添加请求头支持续传
      );

      DebugService.success('✅ 下载任务创建成功: $taskId');
      return taskId;
    } catch (e) {
      DebugService.error('❌ 创建下载任务失败', e);
      return null;
    }
  }

  /// 暂停下载任务
  Future<bool> pauseTask(String taskId) async {
    try {
      DebugService.log('⏸️ 暂停任务: $taskId');

      // 先检查任务状态
      final tasks = await FlutterDownloader.loadTasks();
      final task = tasks?.firstWhere(
        (t) => t.taskId == taskId,
        orElse: () => throw Exception('任务不存在'),
      );

      if (task == null) {
        DebugService.error('❌ 任务不存在: $taskId', null);
        return false;
      }

      DebugService.log('🔍 当前任务状态: ${task.status}, 进度: ${task.progress}%');

      // 如果任务已经完成，无需暂停
      if (task.status == DownloadTaskStatus.complete) {
        DebugService.log('⚠️ 任务已完成，无需暂停');
        return true;
      }

      // 如果任务已经失败，无法暂停
      if (task.status == DownloadTaskStatus.failed) {
        DebugService.log('⚠️ 任务失败，无法暂停');
        return false;
      }

      // 如果任务已经暂停，无需重复暂停
      if (task.status == DownloadTaskStatus.paused) {
        DebugService.log('⚠️ 任务已经暂停，无需重复操作');
        return true;
      }

      // 如果任务已经取消，无法暂停
      if (task.status == DownloadTaskStatus.canceled) {
        DebugService.log('⚠️ 任务已经取消，无法暂停');
        return false;
      }

      // 只有运行中的任务才能暂停
      if (task.status != DownloadTaskStatus.running) {
        DebugService.log('⚠️ 任务状态为 ${task.status}，无法暂停');
        return false;
      }

      DebugService.log('🔄 尝试暂停运行中的任务...');
      DebugService.log('📊 暂停前进度: ${task.progress}%');

      // 尝试暂停任务
      await FlutterDownloader.pause(taskId: taskId);
      DebugService.success('✅ 暂停命令已发送');

      // 等待一小段时间检查暂停是否成功
      await Future.delayed(const Duration(milliseconds: 1000));

      // 再次检查任务状态
      final updatedTasks = await FlutterDownloader.loadTasks();
      final updatedTask = updatedTasks?.firstWhere(
        (t) => t.taskId == taskId,
        orElse: () => throw Exception('任务不存在'),
      );

      if (updatedTask != null) {
        DebugService.log(
          '🔍 暂停后任务状态: ${updatedTask.status}, 进度: ${updatedTask.progress}%',
        );

        if (updatedTask.status == DownloadTaskStatus.paused) {
          DebugService.success('✅ 任务暂停成功');
          return true;
        } else if (updatedTask.status == DownloadTaskStatus.canceled) {
          DebugService.error('❌ 暂停操作意外取消了任务', null);
          DebugService.log('🔍 可能的原因：服务器不支持Range请求或文件已损坏');
          return false;
        } else if (updatedTask.status == DownloadTaskStatus.failed) {
          DebugService.error('❌ 暂停操作导致任务失败', null);
          return false;
        } else if (updatedTask.status == DownloadTaskStatus.running) {
          DebugService.log('⚠️ 暂停操作后任务仍在运行，可能服务器不支持暂停');
          return true; // 即使没暂停成功，也认为操作成功
        } else {
          DebugService.log('⚠️ 暂停操作后任务状态为 ${updatedTask.status}');
          return true;
        }
      } else {
        DebugService.error('❌ 暂停后找不到任务，可能已被删除', null);
        return false;
      }
    } catch (e) {
      DebugService.error('❌ 暂停任务失败', e);

      // 检查错误信息
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('canceled') ||
          errorMessage.contains('cancelled')) {
        DebugService.error('❌ 暂停操作意外取消了任务', null);
      } else if (errorMessage.contains('not found')) {
        DebugService.error('❌ 任务不存在或已被删除', null);
      }

      return false;
    }
  }

  /// 检查任务是否可以恢复
  Future<bool> canResumeTask(String taskId) async {
    try {
      DebugService.log('🔍 检查任务是否可以恢复: $taskId');

      final tasks = await FlutterDownloader.loadTasks();
      final task = tasks?.firstWhere(
        (t) => t.taskId == taskId,
        orElse: () => throw Exception('任务不存在'),
      );

      if (task == null) {
        DebugService.log('❌ 任务不存在: $taskId');
        return false;
      }

      // 只有暂停状态的任务才有可能恢复
      if (task.status == DownloadTaskStatus.paused) {
        DebugService.log('✅ 任务状态为暂停，理论上可以恢复');
        return true;
      }

      // 失败的任务通常需要重新创建
      if (task.status == DownloadTaskStatus.failed) {
        DebugService.log('⚠️ 任务状态为失败，通常需要重新创建');
        return false;
      }

      // 其他状态的任务
      DebugService.log('⚠️ 任务状态为 ${task.status}，恢复可能性未知');
      return false;
    } catch (e) {
      DebugService.error('❌ 检查任务恢复状态失败', e);
      return false;
    }
  }

  /// 恢复下载任务
  Future<bool> resumeTask(String taskId) async {
    try {
      DebugService.log('▶️ 恢复任务: $taskId');

      // 先检查任务状态
      final tasks = await FlutterDownloader.loadTasks();
      final task = tasks?.firstWhere(
        (t) => t.taskId == taskId,
        orElse: () => throw Exception('任务不存在'),
      );

      if (task == null) {
        DebugService.error('❌ 任务不存在: $taskId', null);
        return false;
      }

      DebugService.log('🔍 当前任务状态: ${task.status}, 进度: ${task.progress}%');

      // 如果任务已经完成，无需恢复
      if (task.status == DownloadTaskStatus.complete) {
        DebugService.log('⚠️ 任务已完成，无需恢复');
        return true;
      }

      // 如果任务正在运行，无需恢复
      if (task.status == DownloadTaskStatus.running) {
        DebugService.log('⚠️ 任务正在运行，无需恢复');
        return true;
      }

      // 如果任务已取消，无法恢复
      if (task.status == DownloadTaskStatus.canceled) {
        DebugService.log('⚠️ 任务已取消，无法恢复');
        return false;
      }

      // 尝试恢复暂停或失败的任务
      if (task.status == DownloadTaskStatus.paused ||
          task.status == DownloadTaskStatus.failed) {
        DebugService.log(
          '🔄 尝试恢复${task.status == DownloadTaskStatus.failed ? "失败" : "暂停"}的任务',
        );

        try {
          // 尝试恢复任务
          await FlutterDownloader.resume(taskId: taskId);
          DebugService.success('✅ 恢复命令已发送');

          // 等待一小段时间检查是否真的恢复了
          await Future.delayed(const Duration(milliseconds: 1000));

          // 再次检查任务状态
          final updatedTasks = await FlutterDownloader.loadTasks();
          final updatedTask = updatedTasks?.firstWhere(
            (t) => t.taskId == taskId,
            orElse: () => throw Exception('任务不存在'),
          );

          if (updatedTask != null) {
            DebugService.log(
              '🔍 恢复后任务状态: ${updatedTask.status}, 进度: ${updatedTask.progress}%',
            );

            if (updatedTask.status == DownloadTaskStatus.running) {
              DebugService.success('✅ 任务恢复成功，正在继续下载');
              return true;
            } else if (updatedTask.status == DownloadTaskStatus.paused) {
              DebugService.log('⚠️ 恢复后任务仍为暂停状态，可能服务器不支持续传或部分数据丢失');
              return false;
            } else if (updatedTask.status == DownloadTaskStatus.failed) {
              DebugService.log('⚠️ 恢复后任务失败，可能需要重新下载');
              return false;
            } else {
              DebugService.log('⚠️ 恢复后任务状态为 ${updatedTask.status}');
              return false;
            }
          } else {
            DebugService.error('❌ 恢复后找不到任务，可能已被删除', null);
            return false;
          }
        } catch (resumeError) {
          DebugService.error('❌ 恢复任务失败', resumeError);

          // 检查错误信息
          final errorMessage = resumeError.toString().toLowerCase();
          if (errorMessage.contains('partial downloaded data') ||
              errorMessage.contains('cannot be resumed') ||
              errorMessage.contains('range not supported') ||
              errorMessage.contains('not found partial downloaded data')) {
            DebugService.log('⚠️ 部分下载数据丢失或服务器不支持续传，需要重新下载');
          }

          return false;
        }
      }

      // 其他状态的任务
      DebugService.log('⚠️ 任务状态为 ${task.status}，尝试直接恢复');
      try {
        await FlutterDownloader.resume(taskId: taskId);
        DebugService.success('✅ 恢复命令已发送');
        return true;
      } catch (e) {
        DebugService.error('❌ 直接恢复失败', e);
        return false;
      }
    } catch (e) {
      DebugService.error('❌ 恢复任务失败', e);
      return false;
    }
  }

  /// 删除下载任务
  Future<bool> removeTask(String taskId) async {
    try {
      DebugService.log('🗑️ 删除任务: $taskId');
      await FlutterDownloader.remove(taskId: taskId);
      DebugService.success('✅ 删除命令已发送');
      return true;
    } catch (e) {
      DebugService.error('❌ 删除任务失败', e);
      return false;
    }
  }

  /// 获取有效的下载目录
  Future<String> getValidDownloadDirectory(String preferredDir) async {
    DebugService.log('🔍 开始验证下载目录: $preferredDir');

    // 检查存储权限
    final storageStatus = await Permission.storage.status;
    final manageStorageStatus = await Permission.manageExternalStorage.status;

    DebugService.log('📱 存储权限状态: $storageStatus');
    DebugService.log('📱 管理外部存储权限状态: $manageStorageStatus');

    // 优先尝试使用外部存储目录
    if (preferredDir.startsWith('/storage/emulated/0/')) {
      DebugService.log('📁 检测到外部存储路径，开始验证...');
      try {
        await _ensureDirectoryExists(preferredDir);
        await _testWritePermission(preferredDir);
        DebugService.success('✅ 外部存储目录可用: $preferredDir');
        return preferredDir;
      } catch (e) {
        DebugService.error('❌ 外部存储目录不可用，错误: $e', null);
        DebugService.log('⚠️ 将切换到内部存储目录');
      }
    }

    // 如果外部存储权限不足或不可用，使用应用内部存储
    if (storageStatus.isDenied || storageStatus.isPermanentlyDenied) {
      DebugService.log('⚠️ 外部存储权限不足，切换到内部存储');
      final appDir = await getApplicationDocumentsDirectory();
      final internalDir = '${appDir.path}/downloads';
      DebugService.log('📁 权限不足，使用应用内部存储: $internalDir');
      await _ensureDirectoryExists(internalDir);
      return internalDir;
    }

    // 如果已经是内部存储路径，确保目录存在
    DebugService.log('📁 使用内部存储路径: $preferredDir');
    await _ensureDirectoryExists(preferredDir);
    return preferredDir;
  }

  /// 请求存储权限
  Future<bool> requestStoragePermissions() async {
    DebugService.log('🔐 开始检查存储权限');

    try {
      // 检查存储权限状态
      var status = await Permission.storage.status;
      DebugService.log('📱 存储权限状态: $status');

      if (status.isDenied) {
        DebugService.log('⚠️ 存储权限被拒绝，正在请求...');
        status = await Permission.storage.request();
        DebugService.log('📱 请求存储权限结果: $status');
      }

      if (status.isPermanentlyDenied) {
        DebugService.error('❌ 存储权限被永久拒绝', null);
        return false;
      }

      // 对于 Android 11+，还需要请求管理外部存储权限
      final manageStorageStatus = await Permission.manageExternalStorage.status;
      DebugService.log('📱 管理外部存储权限状态: $manageStorageStatus');

      if (manageStorageStatus.isDenied) {
        DebugService.log('⚠️ 管理外部存储权限被拒绝，正在请求...');
        await Permission.manageExternalStorage.request();
        final newStatus = await Permission.manageExternalStorage.status;
        DebugService.log('📱 请求管理外部存储权限结果: $newStatus');
      }

      DebugService.success('✅ 权限检查完成');
      return true;
    } catch (e) {
      DebugService.error('❌ 权限请求失败', e);
      return false;
    }
  }

  /// 保存任务配置
  Future<void> saveTaskConfig(
    String taskId,
    Map<String, dynamic> config,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configKey = 'task_config_$taskId';
      final configJson = {
        'autoRetry': config['autoRetry'],
        'retryCount': config['retryCount'],
        'retryDelay': config['retryDelay'],
        'enableResume': config['enableResume'],
        'downloadTimeout': config['downloadTimeout'],
        'enableSpeedLimit': config['enableSpeedLimit'],
        'speedLimit': config['speedLimit'],
      };

      await prefs.setString(configKey, jsonEncode(configJson));
      DebugService.log('💾 保存任务配置: $taskId');
    } catch (e) {
      DebugService.error('❌ 保存任务配置失败', e);
    }
  }

  /// 加载任务配置
  Future<Map<String, dynamic>> loadTaskConfig(String? taskId) async {
    if (taskId == null) {
      return _getDefaultConfig();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final configKey = 'task_config_$taskId';
      final configJsonString = prefs.getString(configKey);

      if (configJsonString == null) {
        return _getDefaultConfig();
      }

      final configJson = jsonDecode(configJsonString) as Map<String, dynamic>;
      return configJson;
    } catch (e) {
      DebugService.error('❌ 加载任务配置失败', e);
      return _getDefaultConfig();
    }
  }

  /// 获取默认配置
  Map<String, dynamic> _getDefaultConfig() => {
    'autoRetry': true, // ⚠️ 部分实现 - 配置已保存但重试逻辑需要完善
    'retryCount': 3, // ⚠️ 部分实现 - 配置已保存但重试逻辑需要完善
    'retryDelay': 5, // ⚠️ 部分实现 - 配置已保存但重试逻辑需要完善
    'enableResume': true, // TODO: 未实现 - flutter_downloader 自动处理续传
    'downloadTimeout': 30, // ⚠️ 部分实现 - 需要确认 flutter_downloader 是否支持
    'enableSpeedLimit': false, // ⚠️ 部分实现 - 需要确认 flutter_downloader 是否支持速度限制
    'speedLimit': 1024 * 1024, // ⚠️ 部分实现 - 需要确认 flutter_downloader 是否支持速度限制
  };

  /// 确保目录存在
  Future<void> _ensureDirectoryExists(String dirPath) async {
    DebugService.log('📁 检查目录是否存在: $dirPath');

    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        DebugService.log('📁 目录不存在，正在创建: $dirPath');
        await dir.create(recursive: true);
        DebugService.log('✅ 目录创建完成: $dirPath');
      } else {
        DebugService.log('✅ 目录已存在: $dirPath');
      }

      // 验证目录是否真的存在
      if (!await dir.exists()) {
        DebugService.error('❌ 目录创建失败: $dirPath', null);
        throw Exception('目录创建失败: $dirPath');
      }

      DebugService.success('✅ 目录确认存在: $dirPath');
    } catch (e) {
      DebugService.error('❌ 目录创建失败: $dirPath', e);
      throw Exception('无法创建或访问目录: $dirPath');
    }
  }

  /// 测试写入权限
  Future<void> _testWritePermission(String dirPath) async {
    DebugService.log('📝 测试写入权限: $dirPath');
    final testFile = File('$dirPath/test_write.tmp');
    await testFile.writeAsString('test');
    await testFile.delete();
    DebugService.success('✅ 写入权限测试通过');
  }

  /// 处理文件名
  String? _processFileName(String? fileName, String url) {
    if (fileName != null && fileName.isNotEmpty) {
      return fileName;
    }

    DebugService.log('📄 未指定文件名，从URL提取...');
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;

    if (pathSegments.isNotEmpty) {
      String extractedFileName = pathSegments.last;
      DebugService.log('📄 从URL提取的文件名: $extractedFileName');

      // 如果文件名仍然包含参数，只取问号前的部分
      if (extractedFileName.contains('?')) {
        extractedFileName = extractedFileName.split('?')[0];
        DebugService.log('📄 移除URL参数后的文件名: $extractedFileName');
      }

      // 如果文件名过长，截断它
      if (extractedFileName.length > 100) {
        DebugService.log('📄 文件名过长，正在截断...');
        final extension = extractedFileName.split('.').last;
        final nameWithoutExt = extractedFileName.substring(
          0,
          extractedFileName.lastIndexOf('.'),
        );
        extractedFileName = '${nameWithoutExt.substring(0, 80)}.$extension';
        DebugService.log('📄 截断后的文件名: $extractedFileName');
      }

      return extractedFileName;
    }

    return null;
  }

  /// 获取显示用的下载目录路径（包含子目录）
  String getDisplayDownloadDirectory(String configuredDir) {
    // 直接返回配置的目录，保持显示一致性
    return configuredDir;
  }

  /// 获取实际保存目录（用于 flutter_downloader）
  String getActualSaveDirectory(String configuredDir) {
    // 直接返回配置的目录，让 flutter_downloader 处理路径
    return configuredDir;
  }

  /// 获取处理后的文件名（不包含路径）
  String getProcessedFileName(String originalFileName, String configuredDir) {
    // 直接返回原始文件名，不添加路径前缀
    return originalFileName;
  }
}
