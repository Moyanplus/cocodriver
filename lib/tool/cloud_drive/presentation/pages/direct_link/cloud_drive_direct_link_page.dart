import 'package:flutter/material.dart';

import '../../../../../../core/logging/log_manager.dart';
import '../../../../../../core/utils/responsive_utils.dart';
import '../../../business/cloud_drive_business_service.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../../widgets/direct_link/direct_link.dart';

/// 直链解析页面 - 重构版本
class CloudDriveDirectLinkPage extends StatefulWidget {
  const CloudDriveDirectLinkPage({super.key});

  @override
  State<CloudDriveDirectLinkPage> createState() =>
      _CloudDriveDirectLinkPageState();
}

class _CloudDriveDirectLinkPageState extends State<CloudDriveDirectLinkPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Map<String, dynamic>? _result;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('直链解析'),
        backgroundColor: CloudDriveUIConfig.primaryActionColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 链接输入区域
            LinkInputSection(
              urlController: _urlController,
              passwordController: _passwordController,
              onParse: _parseDirectLink,
              isLoading: _isLoading,
            ),

            // 结果显示区域
            ResultDisplaySection(
              result: _result,
              error: _error,
              onRetry: _parseDirectLink,
            ),

            // 底部间距
            SizedBox(height: ResponsiveUtils.getSpacing() * 2),
          ],
        ),
      ),
    );
  }

  /// 解析直链
  Future<void> _parseDirectLink() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入分享链接'),
          backgroundColor: CloudDriveUIConfig.warningColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      LogManager().cloudDrive('开始解析直链: $url');

      final result = await CloudDriveBusinessService.parseAndDownloadFile(
        shareUrl: url,
        password: _passwordController.text.trim().isEmpty
            ? null
            : _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _result = result.fileInfo;
          _isLoading = false;
        });

        if (result.success) {
          LogManager().cloudDrive('直链解析成功');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: CloudDriveUIConfig.successColor,
            ),
          );
        } else {
          _error = result.message;
        }
      }
    } catch (e) {
      LogManager().error('直链解析失败: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }
}
