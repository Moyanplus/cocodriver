import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// 日志文件管理器
/// 负责管理日志文件的创建、轮转和清理
class LogFileManager {
  static final LogFileManager _instance = LogFileManager._internal();
  factory LogFileManager() => _instance;
  LogFileManager._internal();

  /// 最大日志文件大小（10MB）
  static const int maxFileSize = 10 * 1024 * 1024;

  /// 保留的日志文件数量
  static const int maxLogFiles = 7;

  late Directory _logDirectory;
  File? _currentLogFile;

  /// 初始化日志文件管理器
  Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logDirectory = Directory('${directory.path}/logs');

      if (!await _logDirectory.exists()) {
        await _logDirectory.create(recursive: true);
      }

      // 清理旧日志
      await _cleanOldLogs();

      // 创建或获取当前日志文件
      _currentLogFile = await _getCurrentLogFile();
    } catch (e) {
      if (kDebugMode) {
        print('LogFileManager: 初始化失败: $e');
      }
    }
  }

  /// 获取当前日志文件
  Future<File> _getCurrentLogFile() async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
    final fileName = 'app_log_$dateStr.txt';
    final file = File('${_logDirectory.path}/$fileName');

    // 检查文件是否存在，不存在则创建
    if (!await file.exists()) {
      await file.create();
      // 添加文件头
      await file.writeAsString(
        '=== 日志开始: ${DateTime.now().toIso8601String()} ===\n',
      );
    }

    // 检查文件大小，如果超过限制则轮转
    final fileSize = await file.length();
    if (fileSize > maxFileSize) {
      return await _rotateLogFile(file);
    }

    return file;
  }

  /// 轮转日志文件
  Future<File> _rotateLogFile(File currentFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = '${currentFile.path}.$timestamp';
      await currentFile.rename(newPath);

      // 创建新文件
      final newFile = File(currentFile.path);
      await newFile.create();
      await newFile.writeAsString(
        '=== 日志开始: ${DateTime.now().toIso8601String()} ===\n',
      );

      return newFile;
    } catch (e) {
      if (kDebugMode) {
        print('LogFileManager: 轮转日志文件失败: $e');
      }
      return currentFile;
    }
  }

  /// 清理旧日志文件
  Future<void> _cleanOldLogs() async {
    try {
      final files =
          await _logDirectory
              .list()
              .where((entity) => entity is File && entity.path.endsWith('.txt'))
              .cast<File>()
              .toList();

      // 按修改时间排序（新的在前）
      files.sort((a, b) {
        final aTime = a.lastModifiedSync();
        final bTime = b.lastModifiedSync();
        return bTime.compareTo(aTime);
      });

      // 保留最新的N个文件，删除其他
      if (files.length > maxLogFiles) {
        for (int i = maxLogFiles; i < files.length; i++) {
          await files[i].delete();
          if (kDebugMode) {
            print('LogFileManager: 删除旧日志: ${files[i].path}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('LogFileManager: 清理旧日志失败: $e');
      }
    }
  }

  /// 写入日志
  Future<void> writeLog(String message) async {
    try {
      // 确保有当前日志文件
      _currentLogFile ??= await _getCurrentLogFile();

      // 检查是否需要轮转
      final fileSize = await _currentLogFile!.length();
      if (fileSize > maxFileSize) {
        _currentLogFile = await _rotateLogFile(_currentLogFile!);
      }

      // 写入日志
      await _currentLogFile!.writeAsString(
        message,
        mode: FileMode.append,
        flush: true, // 立即刷新到磁盘
      );
    } catch (e) {
      if (kDebugMode) {
        print('LogFileManager: 写入日志失败: $e');
      }
    }
  }

  /// 获取所有日志文件
  Future<List<File>> getAllLogFiles() async {
    try {
      final files =
          await _logDirectory
              .list()
              .where((entity) => entity is File && entity.path.endsWith('.txt'))
              .cast<File>()
              .toList();

      // 按修改时间排序（新的在前）
      files.sort((a, b) {
        final aTime = a.lastModifiedSync();
        final bTime = b.lastModifiedSync();
        return bTime.compareTo(aTime);
      });

      return files;
    } catch (e) {
      if (kDebugMode) {
        print('LogFileManager: 获取日志文件失败: $e');
      }
      return [];
    }
  }

  /// 获取所有日志内容
  Future<String> getAllLogs() async {
    try {
      final files = await getAllLogFiles();
      final buffer = StringBuffer();

      for (final file in files) {
        try {
          // 尝试读取文件
          final content = await file.readAsString(encoding: utf8);
          buffer.write(content);
          buffer.write('\n');
        } catch (e) {
          // 如果编码失败，尝试逐字节读取并清理
          if (kDebugMode) {
            print('LogFileManager: 文件编码错误，尝试清理: ${file.path}');
          }
          try {
            final bytes = await file.readAsBytes();
            // 只保留有效的 UTF-8 字符
            final cleanedContent = String.fromCharCodes(
              bytes.where((byte) => byte >= 0 && byte <= 127),
            );
            buffer.write(cleanedContent);
            buffer.write('\n');
          } catch (cleanError) {
            if (kDebugMode) {
              print('LogFileManager: 清理文件失败: $cleanError');
            }
          }
        }
      }

      return buffer.toString();
    } catch (e) {
      if (kDebugMode) {
        print('LogFileManager: 读取所有日志失败: $e');
      }
      return '';
    }
  }

  /// 导出日志
  Future<String?> exportLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportFile = File('${directory.path}/logs_export_$timestamp.txt');

      final allLogs = await getAllLogs();
      await exportFile.writeAsString(allLogs);

      return exportFile.path;
    } catch (e) {
      if (kDebugMode) {
        print('LogFileManager: 导出日志失败: $e');
      }
      return null;
    }
  }

  /// 清空所有日志
  Future<void> clearAllLogs() async {
    try {
      final files = await getAllLogFiles();
      for (final file in files) {
        await file.delete();
      }

      // 重新创建当前日志文件
      _currentLogFile = await _getCurrentLogFile();

      if (kDebugMode) {
        print('LogFileManager: 所有日志已清空');
      }
    } catch (e) {
      if (kDebugMode) {
        print('LogFileManager: 清空日志失败: $e');
      }
    }
  }

  /// 获取日志统计信息
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final files = await getAllLogFiles();
      int totalSize = 0;
      int totalLines = 0;

      for (final file in files) {
        totalSize += await file.length();
        final content = await file.readAsString();
        totalLines +=
            content.split('\n').where((line) => line.isNotEmpty).length;
      }

      return {
        'fileCount': files.length,
        'totalSize': totalSize,
        'totalSizeFormatted': _formatFileSize(totalSize),
        'totalLines': totalLines,
        'oldestLog': files.isEmpty ? null : files.last.lastModifiedSync(),
        'newestLog': files.isEmpty ? null : files.first.lastModifiedSync(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('LogFileManager: 获取统计信息失败: $e');
      }
      return {};
    }
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// 获取日志目录路径
  String get logDirectoryPath => _logDirectory.path;
}
