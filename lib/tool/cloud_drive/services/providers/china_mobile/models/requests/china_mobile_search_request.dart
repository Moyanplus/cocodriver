import 'china_mobile_request.dart';

/// 中国移动云盘搜索请求
class ChinaMobileSearchRequest implements ChinaMobileRequest {
  /// 搜索条件
  final SearchConditions conditions;

  /// 显示信息
  final ShowInfo showInfo;

  const ChinaMobileSearchRequest({
    required this.conditions,
    required this.showInfo,
  });

  /// 转换为请求体
  @override
  Map<String, dynamic> toRequestBody() => {
    'conditions': conditions.toJson(),
    'showInfo': showInfo.toJson(),
  };

  @override
  String toString() =>
      'ChinaMobileSearchRequest(keyword: ${conditions.keyword})';
}

/// 搜索条件
class SearchConditions {
  /// 类型
  final int type;

  /// 关键字
  final String keyword;

  /// 所有者
  final String? owner;

  /// 完整文件ID路径
  final String? fullFileIdPath;

  const SearchConditions({
    required this.type,
    required this.keyword,
    this.owner,
    this.fullFileIdPath,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'type': type,
    'keyword': keyword,
    if (owner != null) 'owner': owner,
    if (fullFileIdPath != null) 'fullFileIdPath': fullFileIdPath,
  };
}

/// 显示信息
class ShowInfo {
  /// 是否返回总数标志
  final bool returnTotalCountFlag;

  /// 排序信息列表
  final List<dynamic> sortInfos;

  /// 起始编号
  final int startNum;

  /// 结束编号
  final int stopNum;

  const ShowInfo({
    required this.returnTotalCountFlag,
    this.sortInfos = const [],
    required this.startNum,
    required this.stopNum,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'returnTotalCountFlag': returnTotalCountFlag,
    'sortInfos': sortInfos,
    'startNum': startNum,
    'stopNum': stopNum,
  };
}
