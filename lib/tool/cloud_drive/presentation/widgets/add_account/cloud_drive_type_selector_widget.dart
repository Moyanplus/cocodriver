import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/cloud_drive_entities.dart';
import '../../../services/registry/cloud_drive_provider_registry.dart';
import 'add_account_form_constants.dart';

/// 云盘类型选择器组件
///
/// 使用 DropdownButtonFormField 样式，带图标和颜色
class CloudDriveTypeSelectorWidget extends StatelessWidget {
  final CloudDriveType selectedType;
  final ValueChanged<CloudDriveType> onTypeChanged;

  const CloudDriveTypeSelectorWidget({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final descriptors = CloudDriveProviderRegistry.descriptors;
    final hasDescriptor = descriptors.isNotEmpty;

    return DropdownButtonFormField<CloudDriveType>(
      value: selectedType,
      decoration: InputDecoration(
        labelText: AddAccountFormConstants.labelCloudDriveType,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AddAccountFormConstants.borderRadius.r,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AddAccountFormConstants.contentPaddingHorizontal.w,
          vertical: AddAccountFormConstants.contentPaddingVertical.h,
        ),
      ),
      items: hasDescriptor
          ? descriptors
              .map(
                (descriptor) => DropdownMenuItem(
                  value: descriptor.type,
                  child: Row(
                    children: [
                      Icon(
                        descriptor.iconData ?? descriptor.type.iconData,
                        color: descriptor.color ?? descriptor.type.color,
                        size: AddAccountFormConstants.iconSizeLarge.w,
                      ),
                      SizedBox(width: AddAccountFormConstants.smallSpacing.w),
                      Text(descriptor.displayName ?? descriptor.type.displayName),
                    ],
                  ),
                ),
              )
              .toList()
          : CloudDriveTypeHelper.availableTypes
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        type.iconData,
                        color: type.color,
                        size: AddAccountFormConstants.iconSizeLarge.w,
                      ),
                      SizedBox(width: AddAccountFormConstants.smallSpacing.w),
                      Text(type.displayName),
                    ],
                  ),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) {
          onTypeChanged(value);
        }
      },
    );
  }
}
