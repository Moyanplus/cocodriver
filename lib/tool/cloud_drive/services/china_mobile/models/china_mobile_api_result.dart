/// 中国移动云盘API结果包装类
///
/// 统一封装API调用结果，包含成功/失败状态、数据和错误信息。
class ChinaMobileApiResult<T> {
  /// 是否成功
  final bool isSuccess;

  /// 数据
  final T? data;

  /// 错误信息
  final String? errorMessage;

  /// 是否失败
  bool get isFailure => !isSuccess;

  const ChinaMobileApiResult({
    required this.isSuccess,
    this.data,
    this.errorMessage,
  });

  /// 创建成功结果
  factory ChinaMobileApiResult.success(T data) {
    return ChinaMobileApiResult(isSuccess: true, data: data);
  }

  /// 创建失败结果
  factory ChinaMobileApiResult.failure(String errorMessage) {
    return ChinaMobileApiResult(isSuccess: false, errorMessage: errorMessage);
  }

  /// 从异常创建结果
  factory ChinaMobileApiResult.fromException(Exception e) {
    return ChinaMobileApiResult.failure(e.toString());
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ChinaMobileApiResult.success(data: $data)';
    } else {
      return 'ChinaMobileApiResult.failure(error: $errorMessage)';
    }
  }
}

/// 中国移动云盘响应解析器
///
/// 提供统一的响应解析逻辑。
class ChinaMobileResponseParser {
  /// 解析响应
  ///
  /// [response] 响应数据
  /// [statusCode] HTTP状态码
  /// [dataParser] 数据解析函数
  static ChinaMobileApiResult<T> parse<T>({
    required dynamic response,
    required int? statusCode,
    required T Function(Map<String, dynamic>) dataParser,
  }) {
    try {
      // 验证HTTP状态码
      if (statusCode != 200) {
        return ChinaMobileApiResult.failure('HTTP错误: $statusCode');
      }

      // 验证响应格式
      if (response is! Map<String, dynamic>) {
        return ChinaMobileApiResult.failure('响应格式错误');
      }

      // 检查API响应状态
      final success = response['success'] as bool? ?? false;
      if (!success) {
        final message = response['message'] as String? ?? '未知错误';
        final code = response['code'] as String?;
        return ChinaMobileApiResult.failure(
          code != null ? '[$code] $message' : message,
        );
      }

      // 解析数据
      final data = response['data'];
      if (data == null) {
        return ChinaMobileApiResult.failure('响应数据为空');
      }

      if (data is Map<String, dynamic>) {
        final parsedData = dataParser(data);
        return ChinaMobileApiResult.success(parsedData);
      } else {
        return ChinaMobileApiResult.failure('数据格式错误');
      }
    } catch (e) {
      return ChinaMobileApiResult.failure('解析响应失败: $e');
    }
  }
}
