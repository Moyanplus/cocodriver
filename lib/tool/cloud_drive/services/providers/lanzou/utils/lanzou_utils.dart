import '../../../../../../core/logging/log_manager.dart';
import '../../../../data/models/cloud_drive_entities.dart';

/// 通用的蓝奏云辅助方法。
///
/// 蓝奏云的接口存在多种非标准参数（如 VEI、ylogin 等），这些逻辑
/// 需要在多个服务之间复用，因此集中在 Utils 中维护。
class LanzouUtils {
  const LanzouUtils._();

  /// 根据 Cookie 创建临时账号
  static CloudDriveAccount createTempAccount(String cookies, {String? uid}) =>
      CloudDriveAccount(
        id: uid != null ? 'temp_$uid' : 'temp',
        name: uid != null ? 'temp_$uid' : 'temp',
        type: CloudDriveType.lanzou,
        authType: AuthType.cookie,
        authValue: cookies,
        createdAt: DateTime.now(),
      );

  /// 从 Cookie 中提取 UID
  static String? extractUid(String cookies) {
    try {
      final cleaned = cookies.replaceAll('"', '').trim();
      for (final entry in cleaned.split(';')) {
        final trimmed = entry.trim();
        if (trimmed.isEmpty) continue;
        final parts = trimmed.split('=');

        if (parts.length >= 2 && parts[0].trim() == 'ylogin') {
          return parts.sublist(1).join('=').trim();
        }
      }
    } catch (e, stackTrace) {
      LogManager().cloudDrive('蓝奏云 - 提取UID失败: $e');
      LogManager().cloudDrive(stackTrace.toString());
    }
    return null;
  }

  /// 解析文件大小（支持 "1.6 K" 等格式）
  static int parseFileSize(dynamic rawSize) {
    if (rawSize == null) return 0;
    if (rawSize is num) return rawSize.toInt();

    final text = rawSize.toString().trim();
    if (text.isEmpty) return 0;

    final direct = double.tryParse(text);
    if (direct != null) return direct.toInt();

    final match = RegExp(r'([\d.]+)\s*([a-zA-Z]+)').firstMatch(text);
    if (match == null) return 0;

    final value = double.tryParse(match.group(1) ?? '');
    if (value == null) return 0;

    final unit = (match.group(2) ?? '').toUpperCase();
    const unitMap = {
      'B': 1,
      'BYTE': 1,
      'BYTES': 1,
      'K': 1024,
      'KB': 1024,
      'M': 1024 * 1024,
      'MB': 1024 * 1024,
      'G': 1024 * 1024 * 1024,
      'GB': 1024 * 1024 * 1024,
      'T': 1024 * 1024 * 1024 * 1024,
      'TB': 1024 * 1024 * 1024 * 1024,
    };

    final multiplier = unitMap[unit] ?? 1;
    return (value * multiplier).round();
  }
}
