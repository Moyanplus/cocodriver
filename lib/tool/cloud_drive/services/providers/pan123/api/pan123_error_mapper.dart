import '../../../../core/result.dart';

/// 123云盘错误码映射工具
class Pan123ErrorMapper {
  /// 根据 123 云盘错误码生成统一的 [CloudDriveException]
  ///
  /// [code] 后端错误码
  /// [message] 原始错误信息
  /// [operation] 当前操作名称
  /// [context] 附加上下文
  static CloudDriveException map(
    int code,
    String message, {
    required String operation,
    Map<String, dynamic>? context,
  }) {
    final normalizedMessage =
        message.isNotEmpty ? message : _defaultMessage(code);
    return CloudDriveException(
      normalizedMessage,
      _mapType(code),
      operation: operation,
      context: context,
      statusCode: code,
    );
  }

  /// 将错误码映射到统一的 [CloudDriveErrorType]
  static CloudDriveErrorType _mapType(int code) {
    switch (code) {
      case 401: // token 数量超限或未登录
        return CloudDriveErrorType.authentication;
      case 5217: // 版本过低或流程不完整
      case -3: // 文件已在当前目录
      case 101010: // copy接口同目录
      case 7301: // 已删除，等待释放
        return CloudDriveErrorType.clientError;
      case 5206: // 未登录
      case 5207:
        return CloudDriveErrorType.authentication;
      default:
        if (code >= 5000) return CloudDriveErrorType.serverError;
        return CloudDriveErrorType.unknown;
    }
  }

  /// 返回常见错误码的默认提示
  static String _defaultMessage(int code) {
    switch (code) {
      case 5217:
        return '当前客户端版本过低，请更新后重试';
      case -3:
      case 101010:
        return '文件已在目标文件夹中，请选择其他文件夹';
      case 7301:
        return '文件已删除，系统释放空间需要一段时间，请稍后查看';
      case 5206:
      case 5207:
        return '登录状态已失效，请重新登录';
      default:
        return '操作失败 (code: $code)';
    }
  }
}
