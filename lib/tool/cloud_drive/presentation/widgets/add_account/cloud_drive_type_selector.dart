import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/cloud_drive_entities.dart';

/// 云盘类型选择器组件
class CloudDriveTypeSelector extends StatelessWidget {
  final CloudDriveType selectedType;
  final ValueChanged<CloudDriveType> onTypeChanged;

  const CloudDriveTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择云盘类型',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: CloudDriveType.values.map((type) {
              final isSelected = selectedType == type;
              return InkWell(
                onTap: () => onTypeChanged(type),
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).dividerColor,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 16.sp,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.displayName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _getTypeDescription(type),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getTypeDescription(CloudDriveType type) {
    switch (type) {
      case CloudDriveType.baidu:
        return '百度网盘，支持大文件存储';
      case CloudDriveType.ali:
        return '阿里云盘，高速下载';
      case CloudDriveType.quark:
        return '夸克网盘，智能分类';
      case CloudDriveType.lanzou:
        return '蓝奏云盘，简单易用';
      case CloudDriveType.pan123:
        return '123云盘，免费大容量';
    }
  }
}
