import 'package:dio/dio.dart';

/// 通用 HTTP 辅助，封装默认 query、Map 解析与错误包装。
class CloudDriveHttpClient {
  CloudDriveHttpClient({
    required this.provider,
    required this.dio,
    required this.defaultQueryBuilder,
  });

  final String provider;
  final Dio dio;
  final Map<String, String> Function(Map<String, String> extra)
  defaultQueryBuilder;

  Future<Map<String, dynamic>> getMap(Uri uri) async {
    final response = await dio.getUri(uri);
    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Response<dynamic>> getResponse(Uri uri) => dio.getUri(uri);

  Future<Map<String, dynamic>> postMap(Uri uri, {dynamic data}) async {
    final response = await dio.postUri(uri, data: data);
    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Response<dynamic>> postResponse(Uri uri, {dynamic data}) =>
      dio.postUri(uri, data: data);

  Future<Response<dynamic>> putResponse(
    Uri uri, {
    dynamic data,
    ProgressCallback? onSendProgress,
    Map<String, dynamic>? headers,
  }) =>
      dio.putUri(
        uri,
        data: data,
        onSendProgress: onSendProgress,
        options: headers == null ? null : Options(headers: headers),
      );

  Future<Response<dynamic>> deleteResponse(Uri uri, {dynamic data}) =>
      dio.deleteUri(uri, data: data);

  /// 直接获取二进制/流。
  Future<Response<List<int>>> getBytes(Uri uri) =>
      dio.getUri<List<int>>(uri, options: Options(responseType: ResponseType.bytes));

  Future<Response<ResponseBody>> getStream(Uri uri) =>
      dio.getUri<ResponseBody>(uri, options: Options(responseType: ResponseType.stream));

  /// 构建带默认 query 的 URI。
  Uri buildUri(String base, Map<String, String> query) =>
      Uri.parse(base).replace(queryParameters: defaultQueryBuilder(query));

  /// 统一错误包装，供 _safeCall 之类使用。
  String formatDioError(DioException e) {
    final req = e.requestOptions;
    final code = e.response?.statusCode;
    return '[$provider] HTTP ${code ?? 'error'} ${req.method} ${req.uri}: ${e.message}';
  }
}
