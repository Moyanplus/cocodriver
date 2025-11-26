import '../../../../../core/logging/log_manager.dart';
import '../models/lanzou_direct_link_models.dart';
import '../models/lanzou_result.dart';
import '../repository/lanzou_direct_link_repository.dart';

/// Facade：对外暴露直链解析能力。
class LanzouDirectLinkService {
  static Future<LanzouResult<LanzouDirectLinkResult>> parseDirectLink({
    required String shareUrl,
    String? password,
  }) async {
    final repository = LanzouDirectLinkRepository();
    final request = LanzouDirectLinkRequest(shareUrl: shareUrl, password: password);
    final result = await repository.parseDirectLink(request);
    if (!result.isSuccess) {
      LogManager().error('解析直链失败: ${result.error?.message}');
    }
    return result;
  }
}
