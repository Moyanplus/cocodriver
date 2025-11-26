/// 通用蓝奏云 API 异常
class LanzouApiException implements Exception {
  const LanzouApiException(this.message);

  final String message;

  @override
  String toString() => 'LanzouApiException: $message';
}
