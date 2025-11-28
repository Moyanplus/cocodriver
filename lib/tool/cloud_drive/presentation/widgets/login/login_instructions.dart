import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../common/cloud_drive_common_widgets.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../services/provider/cloud_drive_provider_registry.dart';

/// 登录提示组件
class LoginInstructions extends StatelessWidget {
  final CloudDriveType cloudDriveType;
  final VoidCallback? onClose;

  const LoginInstructions({
    super.key,
    required this.cloudDriveType,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return CloudDriveCommonWidgets.buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.info,
                color: CloudDriveUIConfig.infoColor,
                size: CloudDriveUIConfig.iconSize,
              ),
              SizedBox(width: CloudDriveUIConfig.spacingS),
              Text('登录说明', style: CloudDriveUIConfig.titleTextStyle),
              const Spacer(),
              if (onClose != null)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: CloudDriveUIConfig.secondaryTextColor,
                    size: CloudDriveUIConfig.iconSizeS,
                  ),
                  onPressed: onClose,
                ),
            ],
          ),

          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 登录步骤
          _buildLoginSteps(),

          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 注意事项
          _buildNotes(),
        ],
      ),
    );
  }

  /// 构建登录步骤
  Widget _buildLoginSteps() {
    final steps = _getLoginSteps();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '登录步骤：',
          style: CloudDriveUIConfig.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: CloudDriveUIConfig.spacingS),

        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;

          return Container(
            margin: EdgeInsets.only(bottom: CloudDriveUIConfig.spacingS),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 步骤编号
                Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: CloudDriveUIConfig.primaryActionColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: CloudDriveUIConfig.smallTextStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: CloudDriveUIConfig.spacingS),

                // 步骤内容
                Expanded(
                  child: Text(step, style: CloudDriveUIConfig.bodyTextStyle),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 构建注意事项
  Widget _buildNotes() {
    final notes = _getNotes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '注意事项：',
          style: CloudDriveUIConfig.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: CloudDriveUIConfig.spacingS),

        ...notes.map((note) {
          return Container(
            margin: EdgeInsets.only(bottom: CloudDriveUIConfig.spacingXS),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning,
                  color: CloudDriveUIConfig.warningColor,
                  size: CloudDriveUIConfig.iconSizeS,
                ),
                SizedBox(width: CloudDriveUIConfig.spacingS),
                Expanded(
                  child: Text(note, style: CloudDriveUIConfig.smallTextStyle),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 获取登录步骤
  List<String> _getLoginSteps() {
    final descriptor = CloudDriveProviderRegistry.get(cloudDriveType);
    if (descriptor == null) {
      throw StateError('未注册云盘描述: $cloudDriveType');
    }
    // 可按需为特定云盘定制，未配置则给通用提示
    switch (descriptor.id ?? cloudDriveType.name) {
      case 'ali':
        return ['在网页中输入手机号和验证码', '完成登录验证', '系统将自动获取登录信息'];
      case 'baidu':
        return ['使用百度账号登录', '完成安全验证（如需要）', '系统将自动获取Cookie信息'];
      case 'quark':
        return ['使用夸克账号登录', '完成登录验证', '系统将自动获取Token信息'];
      case 'lanzou':
        return ['使用蓝奏云账号登录', '完成登录验证', '系统将自动获取登录信息'];
      case 'pan123':
        return ['使用123云盘账号登录', '完成登录验证', '系统将自动获取Token信息'];
      default:
        return ['在网页中完成登录', '系统将自动获取登录信息'];
    }
  }

  /// 获取注意事项
  List<String> _getNotes() {
    return ['请确保网络连接正常', '登录过程中请勿关闭页面', '如遇到问题，请尝试刷新页面', '登录信息将安全保存，不会泄露'];
  }
}
