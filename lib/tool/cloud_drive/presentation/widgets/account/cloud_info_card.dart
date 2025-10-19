import 'package:flutter/material.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../data/models/cloud_drive_dtos.dart';
import '../common/cloud_drive_common_widgets.dart';

/// 云盘信息卡片组件
class CloudInfoCard extends StatelessWidget {
  final CloudDriveAccount account;
  final CloudDriveAccountDetails? accountDetails;
  final bool isLoading;
  final String? error;

  const CloudInfoCard({
    super.key,
    required this.account,
    this.accountDetails,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return CloudDriveCommonWidgets.buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('云盘信息', style: CloudDriveUIConfig.titleTextStyle),
          SizedBox(height: CloudDriveUIConfig.spacingM),

          if (isLoading)
            _buildLoadingState()
          else if (error != null)
            _buildErrorState(context, error!)
          else if (accountDetails == null)
            _buildEmptyState(context)
          else
            _buildCloudDetailsContent(accountDetails!),
        ],
      ),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return CloudDriveCommonWidgets.buildLoadingState(message: '正在加载云盘信息...');
  }

  /// 构建错误状态
  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: CloudDriveUIConfig.cardPadding,
      decoration: BoxDecoration(
        color: CloudDriveUIConfig.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
        border: Border.all(
          color: CloudDriveUIConfig.errorColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: CloudDriveUIConfig.errorColor,
            size: CloudDriveUIConfig.iconSizeL,
          ),
          SizedBox(height: CloudDriveUIConfig.spacingS),
          Text(
            '加载失败',
            style: CloudDriveUIConfig.bodyTextStyle.copyWith(
              color: CloudDriveUIConfig.errorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: CloudDriveUIConfig.spacingXS),
          Text(
            error,
            style: CloudDriveUIConfig.smallTextStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: CloudDriveUIConfig.cardPadding,
      child: Column(
        children: [
          Icon(
            Icons.cloud_off,
            color: CloudDriveUIConfig.secondaryTextColor,
            size: CloudDriveUIConfig.iconSizeL,
          ),
          SizedBox(height: CloudDriveUIConfig.spacingS),
          Text(
            '暂无云盘信息',
            style: CloudDriveUIConfig.bodyTextStyle.copyWith(
              color: CloudDriveUIConfig.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建云盘详细信息内容
  Widget _buildCloudDetailsContent(CloudDriveAccountDetails details) {
    return Column(
      children: [
        // 存储空间信息
        if (details.quotaInfo.total > 0 || details.quotaInfo.used > 0)
          _buildStorageInfo(details),

        SizedBox(height: CloudDriveUIConfig.spacingM),

        // 文件统计信息
        _buildFileStats(details),

        SizedBox(height: CloudDriveUIConfig.spacingM),

        // 其他信息
        _buildOtherInfo(details),
      ],
    );
  }

  /// 构建存储空间信息
  Widget _buildStorageInfo(CloudDriveAccountDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '存储空间',
          style: CloudDriveUIConfig.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: CloudDriveUIConfig.spacingS),

        if (details.quotaInfo.total > 0 && details.quotaInfo.used > 0) ...[
          // 存储空间进度条
          _buildStorageProgressBar(details),
          SizedBox(height: CloudDriveUIConfig.spacingS),
        ],

        // 存储空间详情
        Row(
          children: [
            Expanded(
              child: CloudDriveCommonWidgets.buildInfoRow(
                label: '已使用',
                value: _formatFileSize(details.quotaInfo.used),
              ),
            ),
            Expanded(
              child: CloudDriveCommonWidgets.buildInfoRow(
                label: '总容量',
                value: _formatFileSize(details.quotaInfo.total),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建存储空间进度条
  Widget _buildStorageProgressBar(CloudDriveAccountDetails details) {
    if (details.quotaInfo.total == 0 || details.quotaInfo.used == 0) {
      return const SizedBox.shrink();
    }

    final usedPercentage = details.quotaInfo.used / details.quotaInfo.total;
    Color progressColor;

    if (usedPercentage > 0.9) {
      progressColor = CloudDriveUIConfig.errorColor;
    } else if (usedPercentage > 0.7) {
      progressColor = CloudDriveUIConfig.warningColor;
    } else {
      progressColor = CloudDriveUIConfig.successColor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('使用率', style: CloudDriveUIConfig.smallTextStyle),
            Text(
              '${(usedPercentage * 100).toStringAsFixed(1)}%',
              style: CloudDriveUIConfig.smallTextStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: CloudDriveUIConfig.spacingXS),
        LinearProgressIndicator(
          value: usedPercentage,
          backgroundColor: CloudDriveUIConfig.dividerColor,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
      ],
    );
  }

  /// 构建文件统计信息
  Widget _buildFileStats(CloudDriveAccountDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '文件统计',
          style: CloudDriveUIConfig.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: CloudDriveUIConfig.spacingS),

        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.person,
                label: '用户名',
                value: details.accountInfo.username,
                color: CloudDriveUIConfig.infoColor,
              ),
            ),
            if (details.accountInfo.phone != null)
              Expanded(
                child: _buildStatItem(
                  icon: Icons.phone,
                  label: '手机',
                  value: details.accountInfo.phone!,
                  color: CloudDriveUIConfig.folderColor,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// 构建统计项
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: CloudDriveUIConfig.cardPadding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(CloudDriveUIConfig.cardRadius),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: CloudDriveUIConfig.iconSize),
          SizedBox(height: CloudDriveUIConfig.spacingXS),
          Text(
            value,
            style: CloudDriveUIConfig.titleTextStyle.copyWith(color: color),
          ),
          Text(label, style: CloudDriveUIConfig.smallTextStyle),
        ],
      ),
    );
  }

  /// 构建其他信息
  Widget _buildOtherInfo(CloudDriveAccountDetails details) {
    return Column(
      children: [
        CloudDriveCommonWidgets.buildInfoRow(
          label: 'VIP状态',
          value: details.accountInfo.isVip ? 'VIP用户' : '普通用户',
        ),
        if (details.accountInfo.isSvip)
          CloudDriveCommonWidgets.buildInfoRow(
            label: 'SVIP状态',
            value: 'SVIP用户',
          ),
      ],
    );
  }

  /// 格式化文件大小
  String _formatFileSize(int? bytes) {
    if (bytes == null) return '未知';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
