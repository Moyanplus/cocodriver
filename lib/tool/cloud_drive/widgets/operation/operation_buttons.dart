import 'package:flutter/material.dart';
import '../../config/cloud_drive_ui_config.dart';
import '../../models/cloud_drive_models.dart';
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
    return CloudDriveCommonWidgets.buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '主要操作',
            style: CloudDriveUIConfig.titleTextStyle,
          ),
          SizedBox(height: CloudDriveUIConfig.spacingM),
          
          // 下载按钮
          if (onDownload != null)
            _buildOperationButton(
              icon: Icons.download,
              label: '下载文件',
              onPressed: onDownload!,
              color: CloudDriveUIConfig.successColor,
            ),
          
          // 高速下载按钮
          if (onHighSpeedDownload != null)
            _buildOperationButton(
              icon: Icons.speed,
              label: '高速下载',
              onPressed: onHighSpeedDownload!,
              color: CloudDriveUIConfig.infoColor,
            ),
          
          // 分享按钮
          if (onShare != null)
            _buildOperationButton(
              icon: Icons.share,
              label: '分享文件',
              onPressed: onShare!,
              color: CloudDriveUIConfig.warningColor,
            ),
        ],
      ),
    );
  }

  /// 构建次要操作按钮
  Widget _buildSecondaryOperations() {
    return CloudDriveCommonWidgets.buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '其他操作',
            style: CloudDriveUIConfig.titleTextStyle,
          ),
          SizedBox(height: CloudDriveUIConfig.spacingM),
          
          // 文件详情按钮
          if (onFileDetail != null)
            _buildOperationButton(
              icon: Icons.info,
              label: '查看详情',
              onPressed: onFileDetail!,
              color: CloudDriveUIConfig.infoColor,
            ),
          
          // 复制按钮
          if (onCopy != null)
            _buildOperationButton(
              icon: Icons.copy,
              label: '复制文件',
              onPressed: onCopy!,
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
          
          // 移动按钮
          if (onMove != null)
            _buildOperationButton(
              icon: Icons.drive_file_move,
              label: '移动文件',
              onPressed: onMove!,
              color: CloudDriveUIConfig.warningColor,
            ),
          
          // 删除按钮
          if (onDelete != null)
            _buildOperationButton(
              icon: Icons.delete,
              label: '删除文件',
              onPressed: onDelete!,
              color: CloudDriveUIConfig.errorColor,
            ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildOperationButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: CloudDriveUIConfig.spacingS),
      child: CloudDriveCommonWidgets.buildSecondaryButton(
        text: label,
        onPressed: onPressed,
        textColor: color,
        backgroundColor: color,
        icon: Icon(icon, color: color),
      ),
    );
  }
}
