import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tool/cloud_drive/data/models/cloud_drive_entities.dart';

/// 云盘类型状态
class CloudDriveTypeState {
  final CloudDriveType? selectedType;
  final List<CloudDriveType> availableTypes;
  final bool isFilterEnabled;

  const CloudDriveTypeState({
    this.selectedType,
    this.availableTypes = const [],
    this.isFilterEnabled = false,
  });

  /// 使用可用云盘类型的默认构造函数
  factory CloudDriveTypeState.defaultState() {
    return CloudDriveTypeState(
      availableTypes: CloudDriveTypeHelper.availableTypes,
    );
  }

  /// 是否有选中的云盘类型
  bool get hasSelectedType => selectedType != null;

  /// 是否启用了过滤
  bool get isFiltering => isFilterEnabled && hasSelectedType;

  /// 复制并更新状态
  CloudDriveTypeState copyWith({
    CloudDriveType? selectedType,
    List<CloudDriveType>? availableTypes,
    bool? isFilterEnabled,
  }) => CloudDriveTypeState(
    selectedType: selectedType ?? this.selectedType,
    availableTypes: availableTypes ?? this.availableTypes,
    isFilterEnabled: isFilterEnabled ?? this.isFilterEnabled,
  );
}

/// 云盘类型状态管理
class CloudDriveTypeNotifier extends StateNotifier<CloudDriveTypeState> {
  CloudDriveTypeNotifier() : super(CloudDriveTypeState.defaultState());

  /// 选择云盘类型
  void selectType(CloudDriveType type) {
    state = state.copyWith(selectedType: type);
  }

  /// 清除选择
  void clearSelection() {
    state = state.copyWith(selectedType: null);
  }

  /// 切换过滤状态
  void toggleFilter() {
    state = state.copyWith(isFilterEnabled: !state.isFilterEnabled);
  }

  /// 启用过滤
  void enableFilter() {
    state = state.copyWith(isFilterEnabled: true);
  }

  /// 禁用过滤
  void disableFilter() {
    state = state.copyWith(isFilterEnabled: false);
  }

  /// 重置状态
  void reset() {
    state = const CloudDriveTypeState();
  }
}

/// 云盘类型Provider
final cloudDriveTypeProvider =
    StateNotifierProvider<CloudDriveTypeNotifier, CloudDriveTypeState>(
      (ref) => CloudDriveTypeNotifier(),
    );
