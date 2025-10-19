import 'package:flutter/material.dart';

/// 文件类型信息
class FileTypeInfo {
  final IconData iconData;
  final Color color;
  final String category;

  const FileTypeInfo(this.iconData, this.color, this.category);
}

/// 文件类型工具类
/// 统一管理文件类型图标、颜色和分类信息
class FileTypeUtils {
  /// 文件类型映射表
  static final Map<String, FileTypeInfo> _fileTypeMap = {
    // 图片文件
    'jpg': const FileTypeInfo(Icons.image, Colors.green, 'image'),
    'jpeg': const FileTypeInfo(Icons.image, Colors.green, 'image'),
    'png': const FileTypeInfo(Icons.image, Colors.green, 'image'),
    'gif': const FileTypeInfo(Icons.image, Colors.green, 'image'),
    'bmp': const FileTypeInfo(Icons.image, Colors.green, 'image'),
    'webp': const FileTypeInfo(Icons.image, Colors.green, 'image'),
    'svg': const FileTypeInfo(Icons.image, Colors.green, 'image'),
    'ico': const FileTypeInfo(Icons.image, Colors.green, 'image'),

    // 视频文件
    'mp4': const FileTypeInfo(Icons.video_file, Colors.red, 'video'),
    'avi': const FileTypeInfo(Icons.video_file, Colors.red, 'video'),
    'mov': const FileTypeInfo(Icons.video_file, Colors.red, 'video'),
    'wmv': const FileTypeInfo(Icons.video_file, Colors.red, 'video'),
    'flv': const FileTypeInfo(Icons.video_file, Colors.red, 'video'),
    'webm': const FileTypeInfo(Icons.video_file, Colors.red, 'video'),
    'mkv': const FileTypeInfo(Icons.video_file, Colors.red, 'video'),
    'm4v': const FileTypeInfo(Icons.video_file, Colors.red, 'video'),

    // 音频文件
    'mp3': const FileTypeInfo(Icons.audio_file, Colors.orange, 'audio'),
    'wav': const FileTypeInfo(Icons.audio_file, Colors.orange, 'audio'),
    'flac': const FileTypeInfo(Icons.audio_file, Colors.orange, 'audio'),
    'aac': const FileTypeInfo(Icons.audio_file, Colors.orange, 'audio'),
    'ogg': const FileTypeInfo(Icons.audio_file, Colors.orange, 'audio'),
    'm4a': const FileTypeInfo(Icons.audio_file, Colors.orange, 'audio'),
    'wma': const FileTypeInfo(Icons.audio_file, Colors.orange, 'audio'),

    // 文档文件
    'pdf': const FileTypeInfo(Icons.picture_as_pdf, Colors.red, 'document'),
    'doc': const FileTypeInfo(Icons.description, Colors.blue, 'document'),
    'docx': const FileTypeInfo(Icons.description, Colors.blue, 'document'),
    'xls': const FileTypeInfo(Icons.table_chart, Colors.green, 'document'),
    'xlsx': const FileTypeInfo(Icons.table_chart, Colors.green, 'document'),
    'ppt': const FileTypeInfo(Icons.slideshow, Colors.orange, 'document'),
    'pptx': const FileTypeInfo(Icons.slideshow, Colors.orange, 'document'),
    'odt': const FileTypeInfo(Icons.description, Colors.blue, 'document'),
    'ods': const FileTypeInfo(Icons.table_chart, Colors.green, 'document'),
    'odp': const FileTypeInfo(Icons.slideshow, Colors.orange, 'document'),

    // 文本文件
    'txt': const FileTypeInfo(Icons.text_snippet, Colors.grey, 'text'),
    'md': const FileTypeInfo(Icons.text_snippet, Colors.grey, 'text'),
    'json': const FileTypeInfo(Icons.code, Colors.amber, 'text'),
    'xml': const FileTypeInfo(Icons.code, Colors.amber, 'text'),
    'html': const FileTypeInfo(Icons.code, Colors.amber, 'text'),
    'css': const FileTypeInfo(Icons.code, Colors.amber, 'text'),
    'js': const FileTypeInfo(Icons.code, Colors.amber, 'text'),
    'ts': const FileTypeInfo(Icons.code, Colors.amber, 'text'),
    'dart': const FileTypeInfo(Icons.code, Colors.blue, 'text'),
    'py': const FileTypeInfo(Icons.code, Colors.green, 'text'),
    'java': const FileTypeInfo(Icons.code, Colors.orange, 'text'),
    'cpp': const FileTypeInfo(Icons.code, Colors.blue, 'text'),
    'c': const FileTypeInfo(Icons.code, Colors.blue, 'text'),
    'h': const FileTypeInfo(Icons.code, Colors.blue, 'text'),
    'hpp': const FileTypeInfo(Icons.code, Colors.blue, 'text'),
    'php': const FileTypeInfo(Icons.code, Colors.purple, 'text'),
    'rb': const FileTypeInfo(Icons.code, Colors.red, 'text'),
    'go': const FileTypeInfo(Icons.code, Colors.cyan, 'text'),
    'rs': const FileTypeInfo(Icons.code, Colors.orange, 'text'),
    'swift': const FileTypeInfo(Icons.code, Colors.orange, 'text'),
    'kt': const FileTypeInfo(Icons.code, Colors.purple, 'text'),
    'sql': const FileTypeInfo(Icons.storage, Colors.blue, 'text'),
    'yaml': const FileTypeInfo(Icons.code, Colors.amber, 'text'),
    'yml': const FileTypeInfo(Icons.code, Colors.amber, 'text'),
    'ini': const FileTypeInfo(Icons.settings, Colors.grey, 'text'),
    'conf': const FileTypeInfo(Icons.settings, Colors.grey, 'text'),
    'log': const FileTypeInfo(Icons.description, Colors.grey, 'text'),

    // 压缩文件
    'zip': const FileTypeInfo(Icons.archive, Colors.purple, 'archive'),
    'rar': const FileTypeInfo(Icons.archive, Colors.purple, 'archive'),
    '7z': const FileTypeInfo(Icons.archive, Colors.purple, 'archive'),
    'tar': const FileTypeInfo(Icons.archive, Colors.purple, 'archive'),
    'gz': const FileTypeInfo(Icons.archive, Colors.purple, 'archive'),
    'bz2': const FileTypeInfo(Icons.archive, Colors.purple, 'archive'),
    'xz': const FileTypeInfo(Icons.archive, Colors.purple, 'archive'),

    // 可执行文件
    'exe': const FileTypeInfo(Icons.play_arrow, Colors.green, 'executable'),
    'msi': const FileTypeInfo(Icons.install_desktop, Colors.blue, 'executable'),
    'deb': const FileTypeInfo(
      Icons.install_desktop,
      Colors.orange,
      'executable',
    ),
    'rpm': const FileTypeInfo(Icons.install_desktop, Colors.red, 'executable'),
    'dmg': const FileTypeInfo(Icons.install_desktop, Colors.grey, 'executable'),
    'pkg': const FileTypeInfo(Icons.install_desktop, Colors.grey, 'executable'),
    'apk': const FileTypeInfo(Icons.android, Colors.green, 'executable'),
    'ipa': const FileTypeInfo(Icons.phone_iphone, Colors.blue, 'executable'),

    // 字体文件
    'ttf': const FileTypeInfo(Icons.font_download, Colors.purple, 'font'),
    'otf': const FileTypeInfo(Icons.font_download, Colors.purple, 'font'),
    'woff': const FileTypeInfo(Icons.font_download, Colors.purple, 'font'),
    'woff2': const FileTypeInfo(Icons.font_download, Colors.purple, 'font'),
    'eot': const FileTypeInfo(Icons.font_download, Colors.purple, 'font'),

    // 其他文件
    'iso': const FileTypeInfo(Icons.disc_full, Colors.blue, 'disk'),
    'bin': const FileTypeInfo(Icons.memory, Colors.grey, 'binary'),
    'dat': const FileTypeInfo(Icons.storage, Colors.grey, 'data'),
    'db': const FileTypeInfo(Icons.storage, Colors.blue, 'database'),
    'sqlite': const FileTypeInfo(Icons.storage, Colors.blue, 'database'),
    'sqlite3': const FileTypeInfo(Icons.storage, Colors.blue, 'database'),
  };

  /// 默认文件类型信息
  static const FileTypeInfo _defaultFileType = FileTypeInfo(
    Icons.insert_drive_file,
    Colors.grey,
    'unknown',
  );

  /// 获取文件类型信息
  static FileTypeInfo getFileTypeInfo(String fileName) {
    final extension = _getFileExtension(fileName).toLowerCase();
    return _fileTypeMap[extension] ?? _defaultFileType;
  }

  /// 获取文件类型图标
  static IconData getFileTypeIcon(String fileName) {
    return getFileTypeInfo(fileName).iconData;
  }

  /// 获取文件类型颜色
  static Color getFileTypeColor(String fileName) {
    return getFileTypeInfo(fileName).color;
  }

  /// 获取文件类型分类
  static String getFileTypeCategory(String fileName) {
    return getFileTypeInfo(fileName).category;
  }

  /// 检查是否为图片文件
  static bool isImageFile(String fileName) {
    return getFileTypeCategory(fileName) == 'image';
  }

  /// 检查是否为视频文件
  static bool isVideoFile(String fileName) {
    return getFileTypeCategory(fileName) == 'video';
  }

  /// 检查是否为音频文件
  static bool isAudioFile(String fileName) {
    return getFileTypeCategory(fileName) == 'audio';
  }

  /// 检查是否为文档文件
  static bool isDocumentFile(String fileName) {
    return getFileTypeCategory(fileName) == 'document';
  }

  /// 检查是否为文本文件
  static bool isTextFile(String fileName) {
    return getFileTypeCategory(fileName) == 'text';
  }

  /// 检查是否为压缩文件
  static bool isArchiveFile(String fileName) {
    return getFileTypeCategory(fileName) == 'archive';
  }

  /// 检查是否为可执行文件
  static bool isExecutableFile(String fileName) {
    return getFileTypeCategory(fileName) == 'executable';
  }

  /// 获取文件扩展名
  static String _getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1 || lastDotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(lastDotIndex + 1);
  }

  /// 获取所有支持的文件类型
  static List<String> getSupportedFileTypes() {
    return _fileTypeMap.keys.toList()..sort();
  }

  /// 根据分类获取文件类型
  static List<String> getFileTypesByCategory(String category) {
    return _fileTypeMap.entries
        .where((entry) => entry.value.category == category)
        .map((entry) => entry.key)
        .toList()
      ..sort();
  }

  /// 获取所有分类
  static List<String> getAllCategories() {
    return _fileTypeMap.values.map((info) => info.category).toSet().toList()
      ..sort();
  }
}
