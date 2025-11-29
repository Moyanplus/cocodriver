import '../lanzou_config.dart';

/// 构建蓝奏云 API 请求体的便捷构造器。
///
/// Lanzou 的接口大量复用 `task/folder_id/vei` 等字段，手动拼装
/// Map 容易出错。通过链式调用可以快速生成结构化请求数据，
/// 同时保持参数注入顺序一致。
class LanzouRequestBuilder {
  /// 设置任务编号，内部会根据 key 取出真实 task id。
  LanzouRequestBuilder task(String taskKey) {
    _data['task'] = LanzouConfig.getTaskId(taskKey);
    return this;
  }

  /// 设置文件夹 ID，空值时自动映射为根目录。
  LanzouRequestBuilder folder(String? folderId) {
    _data['folder_id'] = LanzouConfig.getFolderId(folderId);
    return this;
  }

  /// 设置分页页码。
  LanzouRequestBuilder page(int page) {
    _data['pg'] = page;
    return this;
  }

  LanzouRequestBuilder maybePage(int? page) {
    if (page != null) {
      _data['pg'] = page;
    }
    return this;
  }

  /// 设置文件 ID。
  LanzouRequestBuilder file(String fileId) {
    _data['file_id'] = fileId;
    return this;
  }

  /// 设置 VEI 参数。
  LanzouRequestBuilder vei(String value) {
    _data['vei'] = value;
    return this;
  }

  /// 添加额外字段，自动忽略 null。
  LanzouRequestBuilder add(String key, dynamic value) {
    if (value != null) {
      _data[key] = value;
    }
    return this;
  }

  Map<String, dynamic> build() => Map<String, dynamic>.from(_data);

  final Map<String, dynamic> _data = {};
}
