import '../../data/models/cloud_drive_entities.dart';
import '../../base/cloud_drive_operation_service.dart';
import '../../core/result.dart';
import '../../infrastructure/logging/cloud_drive_logger_adapter.dart';

/// 账号校验与详情获取服务
class AccountValidationService {
  AccountValidationService(this._logger);

  final CloudDriveLoggerAdapter _logger;

  /// 获取账号详情（昵称/容量等），并处理认证错误。
  Future<CloudDriveAccountDetails?> fetchDetails(CloudDriveAccount account) async {
    try {
      _logger.info('获取账号详情: ${account.name}');
      final strategy = CloudDriveOperationService.getStrategy(account.type);
      if (strategy == null) {
        _logger.warning('未找到策略，无法获取账号详情: ${account.type}');
        return null;
      }
      return await strategy.getAccountDetails(account: account);
    } on CloudDriveException catch (e) {
      if (e.type == CloudDriveErrorType.authentication) {
        return CloudDriveAccountDetails(
          id: account.id,
          name: account.name,
          isValid: false,
        );
      }
      _logger.error('获取账号详情失败(异常): $e');
      return null;
    } catch (e, stack) {
      _logger.error('获取账号详情失败: $e\n$stack');
      return null;
    }
  }
}
