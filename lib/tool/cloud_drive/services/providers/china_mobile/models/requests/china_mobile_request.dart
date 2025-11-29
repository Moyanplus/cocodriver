/// 中国移动云盘请求基类，统一输出请求体。
abstract class ChinaMobileRequest {
  Map<String, dynamic> toRequestBody();
}
