import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';
import '../../core/result.dart';

/// 大文件处理器 - 优化大文件上传下载性能
class LargeFileProcessor {
  static const int _defaultChunkSize = 1024 * 1024; // 1MB
  static const int _maxConcurrentChunks = 3;
  static const int _retryAttempts = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  final Dio _dio;
  final int chunkSize;
  final int maxConcurrentChunks;
  final int retryAttempts;
  final Duration retryDelay;

  LargeFileProcessor({
    Dio? dio,
    this.chunkSize = _defaultChunkSize,
    this.maxConcurrentChunks = _maxConcurrentChunks,
    this.retryAttempts = _retryAttempts,
    this.retryDelay = _retryDelay,
  }) : _dio = dio ?? Dio();

  /// 分块上传大文件
  Future<Result<String>> uploadLargeFile({
    required String filePath,
    required String uploadUrl,
    required CloudDriveAccount account,
    required String fileName,
    String? folderId,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Failure('文件不存在: $filePath');
      }

      final fileSize = await file.length();
      LogManager().cloudDrive(
        '开始分块上传大文件: $fileName (${_formatFileSize(fileSize)})',
      );

      // 获取上传会话
      final sessionResult = await _initiateUploadSession(
        uploadUrl: uploadUrl,
        account: account,
        fileName: fileName,
        fileSize: fileSize,
        folderId: folderId,
      );

      if (sessionResult.isFailure) {
        return sessionResult;
      }

      final sessionId = sessionResult.data!;

      // 分块上传
      final uploadResult = await _uploadChunks(
        file: file,
        sessionId: sessionId,
        uploadUrl: uploadUrl,
        account: account,
        onProgress: onProgress,
        cancelToken: cancelToken,
      );

      if (uploadResult.isFailure) {
        return Failure(uploadResult.error ?? '上传失败');
      }

      // 完成上传
      final completeResult = await _completeUpload(
        sessionId: sessionId,
        uploadUrl: uploadUrl,
        account: account,
      );

      if (completeResult.isFailure) {
        return completeResult;
      }

      LogManager().cloudDrive('大文件上传完成: $fileName');
      return Success(completeResult.data!);
    } catch (e) {
      LogManager().error('大文件上传失败: $e');
      return Failure('上传失败: $e');
    }
  }

  /// 分块下载大文件
  Future<Result<String>> downloadLargeFile({
    required String downloadUrl,
    required String savePath,
    required CloudDriveAccount account,
    required String fileName,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      LogManager().cloudDrive('开始分块下载大文件: $fileName');

      // 获取文件大小
      final sizeResult = await _getFileSize(downloadUrl, account);
      if (sizeResult.isFailure) {
        return Failure(sizeResult.error ?? '获取文件大小失败');
      }

      final fileSize = sizeResult.data!;
      LogManager().cloudDrive('文件大小: ${_formatFileSize(fileSize)}');

      // 创建目标文件
      final file = File(savePath);
      await file.create(recursive: true);

      // 分块下载
      final downloadResult = await _downloadChunks(
        downloadUrl: downloadUrl,
        file: file,
        fileSize: fileSize,
        account: account,
        onProgress: onProgress,
        cancelToken: cancelToken,
      );

      if (downloadResult.isFailure) {
        await file.delete();
        return Failure(downloadResult.error ?? '下载失败');
      }

      LogManager().cloudDrive('大文件下载完成: $fileName');
      return Success(savePath);
    } catch (e) {
      LogManager().error('大文件下载失败: $e');
      return Failure('下载失败: $e');
    }
  }

  /// 初始化上传会话
  Future<Result<String>> _initiateUploadSession({
    required String uploadUrl,
    required CloudDriveAccount account,
    required String fileName,
    required int fileSize,
    String? folderId,
  }) async {
    try {
      final response = await _dio.post(
        '$uploadUrl/initiate',
        data: {
          'fileName': fileName,
          'fileSize': fileSize,
          'folderId': folderId,
          'chunkSize': chunkSize,
        },
        options: Options(
          headers: _buildHeaders(account),
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      if (response.statusCode == 200) {
        final sessionId = response.data['sessionId'] as String;
        return Success(sessionId);
      } else {
        return Failure('初始化上传会话失败: ${response.statusCode}');
      }
    } catch (e) {
      return Failure('初始化上传会话失败: $e');
    }
  }

  /// 分块上传
  Future<Result<void>> _uploadChunks({
    required File file,
    required String sessionId,
    required String uploadUrl,
    required CloudDriveAccount account,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final fileSize = await file.length();
      final totalChunks = (fileSize / chunkSize).ceil();

      LogManager().cloudDrive('📦 开始上传 $totalChunks 个分块');

      final semaphore = Semaphore(maxConcurrentChunks);
      final futures = <Future<void>>[];

      for (int chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
        final future = semaphore.acquire().then((_) async {
          try {
            await _uploadChunk(
              file: file,
              chunkIndex: chunkIndex,
              sessionId: sessionId,
              uploadUrl: uploadUrl,
              account: account,
              onProgress: onProgress,
              cancelToken: cancelToken,
            );
          } finally {
            semaphore.release();
          }
        });
        futures.add(future);
      }

      await Future.wait(futures);
      return Success(null);
    } catch (e) {
      return Failure('分块上传失败: $e');
    }
  }

  /// 上传单个分块
  Future<void> _uploadChunk({
    required File file,
    required int chunkIndex,
    required String sessionId,
    required String uploadUrl,
    required CloudDriveAccount account,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    final start = chunkIndex * chunkSize;
    final end = (start + chunkSize).clamp(0, await file.length());
    final chunkData = await file.openRead(start, end).toList();
    final chunkBytes = Uint8List.fromList(chunkData.expand((x) => x).toList());

    for (int attempt = 0; attempt < retryAttempts; attempt++) {
      try {
        final response = await _dio.post(
          '$uploadUrl/chunk',
          data: FormData.fromMap({
            'sessionId': sessionId,
            'chunkIndex': chunkIndex,
            'chunkData': MultipartFile.fromBytes(
              chunkBytes,
              filename: 'chunk_$chunkIndex',
            ),
          }),
          options: Options(
            headers: _buildHeaders(account),
            sendTimeout: const Duration(minutes: 10),
            receiveTimeout: const Duration(minutes: 5),
          ),
          cancelToken: cancelToken,
        );

        if (response.statusCode == 200) {
          LogManager().cloudDrive('分块 $chunkIndex 上传成功');
          return;
        } else {
          throw Exception('分块上传失败: ${response.statusCode}');
        }
      } catch (e) {
        if (attempt == retryAttempts - 1) {
          rethrow;
        }
        LogManager().cloudDrive(
          '分块 $chunkIndex 上传失败，重试中... (${attempt + 1}/$retryAttempts)',
        );
        await Future.delayed(retryDelay);
      }
    }
  }

  /// 完成上传
  Future<Result<String>> _completeUpload({
    required String sessionId,
    required String uploadUrl,
    required CloudDriveAccount account,
  }) async {
    try {
      final response = await _dio.post(
        '$uploadUrl/complete',
        data: {'sessionId': sessionId},
        options: Options(
          headers: _buildHeaders(account),
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      if (response.statusCode == 200) {
        final fileId = response.data['fileId'] as String;
        return Success(fileId);
      } else {
        return Failure('完成上传失败: ${response.statusCode}');
      }
    } catch (e) {
      return Failure('完成上传失败: $e');
    }
  }

  /// 获取文件大小
  Future<Result<int>> _getFileSize(
    String downloadUrl,
    CloudDriveAccount account,
  ) async {
    try {
      final response = await _dio.head(
        downloadUrl,
        options: Options(
          headers: _buildHeaders(account),
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      final contentLength = response.headers.value('content-length');
      if (contentLength != null) {
        return Success(int.parse(contentLength));
      } else {
        return Failure('无法获取文件大小');
      }
    } catch (e) {
      return Failure('获取文件大小失败: $e');
    }
  }

  /// 分块下载
  Future<Result<void>> _downloadChunks({
    required String downloadUrl,
    required File file,
    required int fileSize,
    required CloudDriveAccount account,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final totalChunks = (fileSize / chunkSize).ceil();
      final semaphore = Semaphore(maxConcurrentChunks);
      final futures = <Future<void>>[];

      for (int chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
        final future = semaphore.acquire().then((_) async {
          try {
            await _downloadChunk(
              downloadUrl: downloadUrl,
              file: file,
              chunkIndex: chunkIndex,
              fileSize: fileSize,
              account: account,
              onProgress: onProgress,
              cancelToken: cancelToken,
            );
          } finally {
            semaphore.release();
          }
        });
        futures.add(future);
      }

      await Future.wait(futures);
      return Success(null);
    } catch (e) {
      return Failure('分块下载失败: $e');
    }
  }

  /// 下载单个分块
  Future<void> _downloadChunk({
    required String downloadUrl,
    required File file,
    required int chunkIndex,
    required int fileSize,
    required CloudDriveAccount account,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    final start = chunkIndex * chunkSize;
    final end = (start + chunkSize).clamp(0, fileSize);

    for (int attempt = 0; attempt < retryAttempts; attempt++) {
      try {
        final response = await _dio.get(
          downloadUrl,
          options: Options(
            headers: {
              ..._buildHeaders(account),
              'Range': 'bytes=$start-${end - 1}',
            },
            sendTimeout: const Duration(minutes: 10),
            receiveTimeout: const Duration(minutes: 10),
            responseType: ResponseType.bytes,
          ),
          cancelToken: cancelToken,
        );

        if (response.statusCode == 206) {
          // Partial Content
          final chunkData = response.data as List<int>;
          final raf = await file.open(mode: FileMode.writeOnlyAppend);
          await raf.writeFrom(chunkData);
          await raf.close();

          LogManager().cloudDrive('分块 $chunkIndex 下载成功');
          return;
        } else {
          throw Exception('分块下载失败: ${response.statusCode}');
        }
      } catch (e) {
        if (attempt == retryAttempts - 1) {
          rethrow;
        }
        LogManager().cloudDrive(
          '分块 $chunkIndex 下载失败，重试中... (${attempt + 1}/$retryAttempts)',
        );
        await Future.delayed(retryDelay);
      }
    }
  }

  /// 构建请求头
  Map<String, String> _buildHeaders(CloudDriveAccount account) {
    return {
      'User-Agent': 'CloudDriveApp/1.0',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (account.cookies != null) 'Cookie': account.cookies!,
    };
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// 信号量 - 控制并发数量
class Semaphore {
  final int maxCount;
  int _currentCount;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Semaphore(this.maxCount) : _currentCount = maxCount;

  Future<void> acquire() async {
    if (_currentCount > 0) {
      _currentCount--;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _currentCount++;
    }
  }
}

/// 进度回调类型
typedef ProgressCallback = void Function(int received, int total);
