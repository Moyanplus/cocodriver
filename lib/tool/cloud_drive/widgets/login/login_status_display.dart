import 'package:flutter/material.dart';
import '../../config/cloud_drive_ui_config.dart';
import '../common/cloud_drive_common_widgets.dart';
import '../../models/cloud_drive_models.dart';

/// 登录状态显示组件
class LoginStatusDisplay extends StatelessWidget {
  final CloudDriveType cloudDriveType;
  final String accountName;
  final bool isLoading;
  final bool isLoggedIn;
  final String? statusMessage;
  final VoidCallback? onRetry;

  const LoginStatusDisplay({
    super.key,
    required this.cloudDriveType,
    required this.accountName,
    this.isLoading = false,
    this.isLoggedIn = false,
    this.statusMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CloudDriveCommonWidgets.buildCard(
      child: Column(
        children: [
          // 标题
          Row(
            children: [
              Icon(
                _getCloudDriveIcon(),
                color: _getCloudDriveColor(),
                size: CloudDriveUIConfig.iconSizeL,
              ),
              SizedBox(width: CloudDriveUIConfig.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getCloudDriveName()} 登录',
                      style: CloudDriveUIConfig.titleTextStyle,
                    ),
                    Text(
                      '账号: $accountName',
                      style: CloudDriveUIConfig.smallTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: CloudDriveUIConfig.spacingM),
          
          // 状态显示
          _buildStatusContent(),
        ],
      ),
    );
  }

  /// 构建状态内容
  Widget _buildStatusContent() {
    if (isLoading) {
      return _buildLoadingStatus();
    } else if (isLoggedIn) {
      return _buildSuccessStatus();
    } else {
      return _buildWaitingStatus();
    }
  }

  /// 构建加载状态
  Widget _buildLoadingStatus() {
    return Column(
      children: [
        CloudDriveCommonWidgets.buildLoadingState(
          message: statusMessage ?? '正在加载登录页面...',
        ),
      ],
    );
  }

  /// 构建成功状态
  Widget _buildSuccessStatus() {
    return Column(
      children: [
        Icon(
          Icons.check_circle,
          color: CloudDriveUIConfig.successColor,
          size: CloudDriveUIConfig.iconSizeL,
        ),
        SizedBox(height: CloudDriveUIConfig.spacingS),
        Text(
          '登录成功！',
          style: CloudDriveUIConfig.titleTextStyle.copyWith(
            color: CloudDriveUIConfig.successColor,
          ),
        ),
        if (statusMessage != null) ...[
          SizedBox(height: CloudDriveUIConfig.spacingS),
          Text(
            statusMessage!,
            style: CloudDriveUIConfig.bodyTextStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// 构建等待状态
  Widget _buildWaitingStatus() {
    return Column(
      children: [
        Icon(
          Icons.hourglass_empty,
          color: CloudDriveUIConfig.warningColor,
          size: CloudDriveUIConfig.iconSizeL,
        ),
        SizedBox(height: CloudDriveUIConfig.spacingS),
        Text(
          '等待登录',
          style: CloudDriveUIConfig.titleTextStyle.copyWith(
            color: CloudDriveUIConfig.warningColor,
          ),
        ),
        SizedBox(height: CloudDriveUIConfig.spacingS),
        Text(
          statusMessage ?? '请在网页中完成登录操作',
          style: CloudDriveUIConfig.bodyTextStyle,
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          SizedBox(height: CloudDriveUIConfig.spacingM),
          CloudDriveCommonWidgets.buildSecondaryButton(
            text: '重新检查',
            onPressed: onRetry ?? () {},
            icon: const Icon(Icons.refresh),
          ),
        ],
      ],
    );
  }

  /// 获取云盘图标
  IconData _getCloudDriveIcon() {
    switch (cloudDriveType) {
      case CloudDriveType.ali:
        return Icons.cloud;
      case CloudDriveType.baidu:
        return Icons.storage;
      case CloudDriveType.quark:
        return Icons.speed;
      case CloudDriveType.lanzou:
        return Icons.link;
      case CloudDriveType.pan123:
        return Icons.folder;
      default:
        return Icons.cloud_queue;
    }
  }

  /// 获取云盘颜色
  Color _getCloudDriveColor() {
    switch (cloudDriveType) {
      case CloudDriveType.ali:
        return Colors.blue;
      case CloudDriveType.baidu:
        return Colors.red;
      case CloudDriveType.quark:
        return Colors.green;
      case CloudDriveType.lanzou:
        return Colors.orange;
      case CloudDriveType.pan123:
        return Colors.purple;
      default:
        return CloudDriveUIConfig.secondaryActionColor;
    }
  }

  /// 获取云盘名称
  String _getCloudDriveName() {
    switch (cloudDriveType) {
      case CloudDriveType.ali:
        return '阿里云盘';
      case CloudDriveType.baidu:
        return '百度网盘';
      case CloudDriveType.quark:
        return '夸克云盘';
      case CloudDriveType.lanzou:
        return '蓝奏云';
      case CloudDriveType.pan123:
        return '123云盘';
      default:
        return '云盘';
    }
  }
}
