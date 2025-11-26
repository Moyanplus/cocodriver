import '../models/lanzou_result.dart';

/// 仓库：蓝奏云分享操作，目前蓝奏官方无公开 API。
class LanzouShareRepository {
  Future<LanzouResult<String>> createShareLink({
    required List<String> fileIds,
    String? password,
    int? expireDays,
  }) async {
    return LanzouResult.failure(
      const LanzouFailure(message: '蓝奏云暂不支持 API 分享功能'),
    );
  }
}
