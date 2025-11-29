/// 蓝奏云统一 Result 类型，用于向上层传递成功与错误信息。
class LanzouResult<T> {
  const LanzouResult._({this.data, this.error});

  final T? data;
  final LanzouFailure? error;

  bool get isSuccess => error == null;

  static LanzouResult<T> success<T>(T data) =>
      LanzouResult._(data: data);

  static LanzouResult<T> failure<T>(LanzouFailure error) =>
      LanzouResult._(error: error);
}

class LanzouFailure {
  const LanzouFailure({required this.message, this.code});

  final String message;
  final String? code;
}
