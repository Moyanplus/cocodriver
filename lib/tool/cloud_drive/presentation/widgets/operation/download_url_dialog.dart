import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../common/cloud_drive_common_widgets.dart';

/// 下载URL选择对话框组件
class DownloadUrlDialog extends StatelessWidget {
  final List<String> downloadUrls;
  final VoidCallback? onCancel;
  final Function(String url)? onSelect;

  const DownloadUrlDialog({
    super.key,
    required this.downloadUrls,
    this.onCancel,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '选择下载链接',
        style: CloudDriveUIConfig.titleTextStyle,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '检测到多个下载链接，请选择一个：',
              style: CloudDriveUIConfig.bodyTextStyle,
            ),
            
            SizedBox(height: CloudDriveUIConfig.spacingM),
            
            // URL列表
            ...downloadUrls.asMap().entries.map((entry) {
              final index = entry.key;
              final url = entry.value;
              
              return Container(
                margin: EdgeInsets.only(bottom: CloudDriveUIConfig.spacingS),
                child: CloudDriveCommonWidgets.buildCard(
                  onTap: () => _handleUrlSelect(context, url),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.link,
                            color: CloudDriveUIConfig.infoColor,
                            size: CloudDriveUIConfig.iconSizeS,
                          ),
                          SizedBox(width: CloudDriveUIConfig.spacingS),
                          Text(
                            '链接 ${index + 1}',
                            style: CloudDriveUIConfig.bodyTextStyle.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: CloudDriveUIConfig.secondaryTextColor,
                            size: CloudDriveUIConfig.iconSizeS,
                          ),
                        ],
                      ),
                      
                      SizedBox(height: CloudDriveUIConfig.spacingS),
                      
                      // URL预览
                      Container(
                        width: double.infinity,
                        padding: CloudDriveUIConfig.inputPadding,
                        decoration: BoxDecoration(
                          color: CloudDriveUIConfig.dividerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(CloudDriveUIConfig.inputRadius),
                        ),
                        child: Text(
                          _getUrlPreview(url),
                          style: CloudDriveUIConfig.smallTextStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        // 取消按钮
        TextButton(
          onPressed: () {
            onCancel?.call();
            Navigator.of(context).pop();
          },
          child: Text(
            '取消',
            style: TextStyle(color: CloudDriveUIConfig.secondaryTextColor),
          ),
        ),
      ],
    );
  }

  /// 处理URL选择
  void _handleUrlSelect(BuildContext context, String url) {
    onSelect?.call(url);
    Navigator.of(context).pop();
  }

  /// 获取URL预览
  String _getUrlPreview(String url) {
    if (url.length <= 60) {
      return url;
    }
    
    return '${url.substring(0, 30)}...${url.substring(url.length - 30)}';
  }
}

/// 下载进度对话框
class DownloadProgressDialog extends StatelessWidget {
  final String fileName;
  final double progress;
  final String? status;
  final VoidCallback? onCancel;

  const DownloadProgressDialog({
    super.key,
    required this.fileName,
    required this.progress,
    this.status,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '下载中',
        style: CloudDriveUIConfig.titleTextStyle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 文件名
          Text(
            fileName,
            style: CloudDriveUIConfig.bodyTextStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: CloudDriveUIConfig.spacingM),
          
          // 进度条
          LinearProgressIndicator(
            value: progress,
            backgroundColor: CloudDriveUIConfig.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(CloudDriveUIConfig.successColor),
          ),
          
          SizedBox(height: CloudDriveUIConfig.spacingS),
          
          // 进度文本
          Text(
            '${(progress * 100).toStringAsFixed(1)}%',
            style: CloudDriveUIConfig.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          
          // 状态文本
          if (status != null) ...[
            SizedBox(height: CloudDriveUIConfig.spacingXS),
            Text(
              status!,
              style: CloudDriveUIConfig.smallTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            '取消下载',
            style: TextStyle(color: CloudDriveUIConfig.errorColor),
          ),
        ),
      ],
    );
  }
}

/// 下载完成对话框
class DownloadCompleteDialog extends StatelessWidget {
  final String fileName;
  final String? filePath;
  final VoidCallback? onClose;
  final VoidCallback? onOpenFile;

  const DownloadCompleteDialog({
    super.key,
    required this.fileName,
    this.filePath,
    this.onClose,
    this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: CloudDriveUIConfig.successColor,
            size: CloudDriveUIConfig.iconSize,
          ),
          SizedBox(width: CloudDriveUIConfig.spacingS),
          Text(
            '下载完成',
            style: CloudDriveUIConfig.titleTextStyle,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 文件名
          Text(
            fileName,
            style: CloudDriveUIConfig.bodyTextStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: CloudDriveUIConfig.spacingM),
          
          // 文件路径
          if (filePath != null) ...[
            CloudDriveCommonWidgets.buildInfoRow(
              label: '保存位置',
              value: filePath!,
            ),
          ],
        ],
      ),
      actions: [
        // 关闭按钮
        TextButton(
          onPressed: () {
            onClose?.call();
            Navigator.of(context).pop();
          },
          child: Text(
            '关闭',
            style: TextStyle(color: CloudDriveUIConfig.secondaryTextColor),
          ),
        ),
        
        // 打开文件按钮
        if (onOpenFile != null)
          CloudDriveCommonWidgets.buildButton(
            text: '打开文件',
            onPressed: () {
              onOpenFile?.call();
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }
}
