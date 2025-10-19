import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/cloud_drive_ui_config.dart';

/// 结果显示区域组件
class ResultDisplaySection extends StatelessWidget {
  final Map<String, dynamic>? result;
  final String? error;
  final VoidCallback onRetry;

  const ResultDisplaySection({
    super.key,
    this.result,
    this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return _buildErrorState(context);
    }

    if (result != null) {
      return _buildResultState(context);
    }

    return _buildEmptyState(context);
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: CloudDriveUIConfig.pagePadding,
      child: Column(
        children: [
          Icon(
            Icons.link_off,
            size: 64,
            color: CloudDriveUIConfig.secondaryTextColor,
          ),
          SizedBox(height: CloudDriveUIConfig.spacingM),
          Text(
            '暂无解析结果',
            style: CloudDriveUIConfig.titleTextStyle.copyWith(
              color: CloudDriveUIConfig.secondaryTextColor,
            ),
          ),
          SizedBox(height: CloudDriveUIConfig.spacingS),
          Text(
            '输入分享链接并点击解析按钮',
            style: CloudDriveUIConfig.bodyTextStyle.copyWith(
              color: CloudDriveUIConfig.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: CloudDriveUIConfig.pagePadding,
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: CloudDriveUIConfig.errorColor,
          ),
          SizedBox(height: CloudDriveUIConfig.spacingM),
          Text(
            '解析失败',
            style: CloudDriveUIConfig.titleTextStyle.copyWith(
              color: CloudDriveUIConfig.errorColor,
            ),
          ),
          SizedBox(height: CloudDriveUIConfig.spacingS),
          Text(
            error!,
            style: CloudDriveUIConfig.bodyTextStyle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: CloudDriveUIConfig.spacingL),
          ElevatedButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }

  /// 构建结果状态
  Widget _buildResultState(BuildContext context) {
    return Container(
      padding: CloudDriveUIConfig.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('解析结果', style: CloudDriveUIConfig.titleTextStyle),
          SizedBox(height: CloudDriveUIConfig.spacingM),

          Card(
            child: Padding(
              padding: CloudDriveUIConfig.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 文件信息
                  if (result!['fileName'] != null) ...[
                    _buildInfoRow('文件名', result!['fileName']),
                    SizedBox(height: CloudDriveUIConfig.spacingS),
                  ],

                  if (result!['fileSize'] != null) ...[
                    _buildInfoRow('文件大小', result!['fileSize']),
                    SizedBox(height: CloudDriveUIConfig.spacingS),
                  ],

                  if (result!['fileType'] != null) ...[
                    _buildInfoRow('文件类型', result!['fileType']),
                    SizedBox(height: CloudDriveUIConfig.spacingS),
                  ],

                  // 下载链接
                  if (result!['downloadUrl'] != null) ...[
                    _buildDownloadUrlRow(result!['downloadUrl']),
                    SizedBox(height: CloudDriveUIConfig.spacingM),
                  ],

                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              () => _copyDownloadUrl(
                                context,
                                result!['downloadUrl'],
                              ),
                          icon: const Icon(Icons.copy),
                          label: const Text('复制链接'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CloudDriveUIConfig.infoColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: CloudDriveUIConfig.spacingM),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              () => _openDownloadUrl(
                                context,
                                result!['downloadUrl'],
                              ),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('打开链接'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: CloudDriveUIConfig.smallTextStyle.copyWith(
              color: CloudDriveUIConfig.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Text(value, style: CloudDriveUIConfig.bodyTextStyle)),
      ],
    );
  }

  /// 构建下载链接行
  Widget _buildDownloadUrlRow(String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '下载链接:',
          style: CloudDriveUIConfig.smallTextStyle.copyWith(
            color: CloudDriveUIConfig.secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: CloudDriveUIConfig.spacingXS),
        Container(
          padding: CloudDriveUIConfig.inputPadding,
          decoration: BoxDecoration(
            color: CloudDriveUIConfig.cardBackgroundColor,
            borderRadius: BorderRadius.circular(CloudDriveUIConfig.inputRadius),
            border: Border.all(
              color: CloudDriveUIConfig.dividerColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            url,
            style: CloudDriveUIConfig.smallTextStyle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 复制下载链接
  void _copyDownloadUrl(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('下载链接已复制到剪贴板'),
        backgroundColor: CloudDriveUIConfig.successColor,
      ),
    );
  }

  /// 打开下载链接
  void _openDownloadUrl(BuildContext context, String url) {
    // TODO: 实现打开链接逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('打开链接: $url'),
        backgroundColor: CloudDriveUIConfig.infoColor,
      ),
    );
  }
}
