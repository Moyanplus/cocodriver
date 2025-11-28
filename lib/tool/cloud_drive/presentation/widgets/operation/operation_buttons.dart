import 'package:flutter/material.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../common/cloud_drive_common_widgets.dart';

/// 操作按钮组件
class OperationButtons extends StatelessWidget {
  final CloudDriveFile file;
  final CloudDriveAccount account;
  final bool isLoading;
  final String? loadingMessage;
  final VoidCallback? onDownload;
  final VoidCallback? onHighSpeedDownload;
  final VoidCallback? onShare;
  final VoidCallback? onCopy;
  final VoidCallback? onRename;
  final VoidCallback? onMove;
  final VoidCallback? onDelete;
  final VoidCallback? onFileDetail;
  final bool downloadEnabled;
  final bool shareEnabled;
  final bool copyEnabled;
  final bool moveEnabled;
  final bool deleteEnabled;

  const OperationButtons({
    super.key,
    required this.file,
    required this.account,
    this.isLoading = false,
    this.loadingMessage,
    this.onDownload,
    this.onHighSpeedDownload,
    this.onShare,
    this.onCopy,
    this.onRename,
    this.onMove,
    this.onDelete,
    this.onFileDetail,
    this.downloadEnabled = true,
    this.shareEnabled = true,
    this.copyEnabled = true,
    this.moveEnabled = true,
    this.deleteEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    return Column(
      children: [
        // 主要操作按钮
        _buildPrimaryOperations(),

        SizedBox(height: CloudDriveUIConfig.spacingM),

        // 次要操作按钮
        _buildSecondaryOperations(),
      ],
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return CloudDriveCommonWidgets.buildCard(
      child: CloudDriveCommonWidgets.buildLoadingState(
        message: loadingMessage ?? '正在处理...',
      ),
    );
  }

  /// 构建主要操作按钮
  Widget _buildPrimaryOperations() {
    // 统计主要操作按钮的数量
    final hasThreePrimaryButtons =
        onDownload != null && onHighSpeedDownload != null && onShare != null;

    return CloudDriveCommonWidgets.buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('主要操作', style: CloudDriveUIConfig.titleTextStyle),
          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 下载、高速下载、分享 - 三个按钮一行
          if (hasThreePrimaryButtons)
            Padding(
              padding: EdgeInsets.only(bottom: CloudDriveUIConfig.spacingS),
              child: Row(
                children: [
                  // 下载按钮
                  Expanded(
                    child: _buildCompactButton(
                      icon: Icons.download_rounded,
                      label: '下载',
                      onPressed: onDownload!,
                      color: CloudDriveUIConfig.successColor,
                      enabled: downloadEnabled,
                    ),
                  ),
                  SizedBox(width: CloudDriveUIConfig.spacingS),
                  // 高速下载按钮
                  Expanded(
                    child: _buildCompactButton(
                      icon: Icons.speed_rounded,
                      label: '高速',
                      onPressed: onHighSpeedDownload!,
                      color: CloudDriveUIConfig.infoColor,
                    ),
                  ),
                  SizedBox(width: CloudDriveUIConfig.spacingS),
                  // 分享按钮
                  Expanded(
                    child: _buildCompactButton(
                      icon: Icons.share_rounded,
                      label: '分享',
                      onPressed: onShare!,
                      color: CloudDriveUIConfig.warningColor,
                      enabled: shareEnabled,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // 如果不是三个按钮都有，则分别显示
            if (onDownload != null)
              _buildOperationButton(
                icon: Icons.download,
                label: '下载文件',
                onPressed: onDownload!,
                color: CloudDriveUIConfig.successColor,
                enabled: downloadEnabled,
              ),
            if (onHighSpeedDownload != null)
              _buildOperationButton(
                icon: Icons.speed,
                label: '高速下载',
                onPressed: onHighSpeedDownload!,
                color: CloudDriveUIConfig.infoColor,
              ),
            if (onShare != null)
              _buildOperationButton(
                icon: Icons.share,
                label: '分享文件',
                onPressed: onShare!,
                color: CloudDriveUIConfig.warningColor,
                enabled: shareEnabled,
              ),
          ],
        ],
      ),
    );
  }

  /// 构建次要操作按钮
  Widget _buildSecondaryOperations() {
    // 统计复制、移动、删除按钮的数量
    final hasThreeButtons =
        onCopy != null && onMove != null && onDelete != null;

    return CloudDriveCommonWidgets.buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('其他操作', style: CloudDriveUIConfig.titleTextStyle),
          SizedBox(height: CloudDriveUIConfig.spacingM),

          // 文件详情按钮
          if (onFileDetail != null)
            _buildOperationButton(
              icon: Icons.info,
              label: '查看详情',
              onPressed: onFileDetail!,
              color: CloudDriveUIConfig.infoColor,
            ),

          // 重命名按钮
          if (onRename != null)
            _buildOperationButton(
              icon: Icons.edit,
              label: '重命名',
              onPressed: onRename!,
              color: CloudDriveUIConfig.warningColor,
            ),

          // 复制、移动、删除 - 三个按钮一行
          if (hasThreeButtons)
            Padding(
              padding: EdgeInsets.only(bottom: CloudDriveUIConfig.spacingS),
              child: Row(
                children: [
                  // 复制按钮
                  Expanded(
                    child: _buildCompactButton(
                      icon: Icons.copy_rounded,
                      label: '复制',
                      onPressed: onCopy!,
                      color: CloudDriveUIConfig.infoColor,
                      enabled: copyEnabled,
                    ),
                  ),
                  SizedBox(width: CloudDriveUIConfig.spacingS),
                  // 移动按钮
                  Expanded(
                    child: _buildCompactButton(
                      icon: Icons.drive_file_move_rounded,
                      label: '移动',
                      onPressed: onMove!,
                      color: CloudDriveUIConfig.warningColor,
                      enabled: moveEnabled,
                    ),
                  ),
                  SizedBox(width: CloudDriveUIConfig.spacingS),
                  // 删除按钮
                  Expanded(
                    child: _buildCompactButton(
                      icon: Icons.delete_rounded,
                      label: '删除',
                      onPressed: onDelete!,
                      color: CloudDriveUIConfig.errorColor,
                      enabled: deleteEnabled,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // 如果不是三个按钮都有，则分别显示
            if (onCopy != null)
              _buildOperationButton(
                icon: Icons.copy,
                label: '复制文件',
                onPressed: onCopy!,
                color: CloudDriveUIConfig.infoColor,
                enabled: copyEnabled,
              ),
            if (onMove != null)
              _buildOperationButton(
                icon: Icons.drive_file_move,
                label: '移动文件',
                onPressed: onMove!,
                color: CloudDriveUIConfig.warningColor,
                enabled: moveEnabled,
              ),
            if (onDelete != null)
              _buildOperationButton(
                icon: Icons.delete,
                label: '删除文件',
                onPressed: onDelete!,
                color: CloudDriveUIConfig.errorColor,
                enabled: deleteEnabled,
              ),
          ],
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildOperationButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    bool enabled = true,
  }) {
    final displayColor = enabled ? color : Colors.grey;
    final backgroundColor =
        enabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.15);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: CloudDriveUIConfig.spacingS),
      child: CloudDriveCommonWidgets.buildSecondaryButton(
        text: label,
        onPressed: enabled ? onPressed : null,
        textColor: displayColor,
        backgroundColor: backgroundColor,
        icon: Icon(icon, color: displayColor),
      ),
    );
  }

  /// 构建紧凑型按钮（用于一行多个按钮）
  Widget _buildCompactButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    bool enabled = true,
  }) {
    final displayColor = enabled ? color : Colors.grey;
    final backgroundColor =
        enabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.15);
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: CloudDriveUIConfig.spacingM,
            horizontal: CloudDriveUIConfig.spacingS,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: displayColor, size: 24),
              SizedBox(height: CloudDriveUIConfig.spacingXS),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: displayColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
