import '../../data/models/cloud_drive_entities.dart';
import '../../services/registry/cloud_drive_provider_registry.dart';

/// 根据账号构建用于图片/缩略图请求的通用头，集中管理，避免在UI层硬编码。
Map<String, String> buildMediaHeaders(CloudDriveAccount account) {
  final headers = <String, String>{
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
    ...account.authHeaders,
  };

  final descriptor = CloudDriveProviderRegistry.get(account.type);
  final extra = descriptor?.mediaHeadersBuilder?.call(account);
  if (extra != null && extra.isNotEmpty) {
    headers.addAll(extra..removeWhere((k, v) => v.isEmpty));
  }

  return headers;
}
