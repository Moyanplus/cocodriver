import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/qr_login_models.dart';
import '../models/cloud_drive_models.dart';
import '../services/base/qr_login_service.dart';

/// 二维码登录页面
class QRLoginPage extends StatefulWidget {
  final CloudDriveType cloudDriveType;
  final String accountName;
  final Function(String authData) onLoginSuccess;
  final VoidCallback? onCancel;

  const QRLoginPage({
    super.key,
    required this.cloudDriveType,
    required this.accountName,
    required this.onLoginSuccess,
    this.onCancel,
  });

  @override
  State<QRLoginPage> createState() => _QRLoginPageState();
}

class _QRLoginPageState extends State<QRLoginPage> {
  StreamSubscription<QRLoginInfo>? _loginSubscription;
  QRLoginInfo? _currentLoginInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startQRLogin();
  }

  @override
  void dispose() {
    _loginSubscription?.cancel();
    if (_currentLoginInfo != null) {
      QRLoginManager.cancelQRLogin(_currentLoginInfo!.qrId);
    }
    super.dispose();
  }

  /// 开始二维码登录流程
  void _startQRLogin() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    _loginSubscription = QRLoginManager.startQRLogin(
      widget.cloudDriveType,
    ).listen(
      (loginInfo) {
        setState(() {
          _currentLoginInfo = loginInfo;
          _isLoading = false;
        });

        // 处理登录成功
        if (loginInfo.status == QRLoginStatus.success) {
          _handleLoginSuccess(loginInfo);
        }
        // 处理登录失败
        else if (loginInfo.status == QRLoginStatus.failed) {
          _handleLoginFailed(loginInfo);
        }
        // 处理二维码过期
        else if (loginInfo.status == QRLoginStatus.expired) {
          _handleQRExpired();
        }
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
          _error = error.toString();
        });
      },
    );
  }

  /// 处理登录成功
  Future<void> _handleLoginSuccess(QRLoginInfo loginInfo) async {
    try {
      final service = QRLoginManager.getService(widget.cloudDriveType);
      if (service == null) {
        throw Exception('找不到${widget.cloudDriveType.displayName}的二维码登录服务');
      }

      // 解析认证数据
      final authData = await service.parseAuthData(loginInfo);

      // 调用成功回调
      widget.onLoginSuccess(authData);

      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.cloudDriveType.displayName}登录成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = '解析登录数据失败: $e';
      });
    }
  }

  /// 处理登录失败
  void _handleLoginFailed(QRLoginInfo loginInfo) {
    setState(() {
      _error = loginInfo.message ?? '登录失败';
    });
  }

  /// 处理二维码过期
  void _handleQRExpired() {
    setState(() {
      _error = '二维码已过期，请重新生成';
    });
  }

  /// 重新生成二维码
  void _regenerateQR() {
    _loginSubscription?.cancel();
    _startQRLogin();
  }

  /// 取消登录
  void _cancelLogin() {
    if (_currentLoginInfo != null) {
      QRLoginManager.cancelQRLogin(_currentLoginInfo!.qrId);
    }
    widget.onCancel?.call();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cloudDriveType.displayName}二维码登录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _regenerateQR,
            tooltip: '重新生成二维码',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _cancelLogin,
            tooltip: '取消登录',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在生成二维码...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorView();
    }

    if (_currentLoginInfo == null) {
      return const Center(child: Text('无法获取二维码信息'));
    }

    return _buildQRView(_currentLoginInfo!);
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '登录失败',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _regenerateQR,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重新生成'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _cancelLogin,
                  icon: const Icon(Icons.close),
                  label: const Text('取消'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRView(QRLoginInfo loginInfo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 状态指示器
          _buildStatusIndicator(loginInfo),

          const SizedBox(height: 32),

          // 二维码显示区域
          _buildQRCodeDisplay(loginInfo),

          const SizedBox(height: 32),

          // 使用说明
          _buildInstructions(),

          const SizedBox(height: 24),

          // 倒计时显示
          if (loginInfo.expiresAt != null) _buildCountdown(loginInfo),

          const SizedBox(height: 24),

          // 操作按钮
          _buildActionButtons(loginInfo),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(QRLoginInfo loginInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: loginInfo.status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: loginInfo.status.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(loginInfo.status.icon, color: loginInfo.status.color, size: 20),
          const SizedBox(width: 8),
          Text(
            loginInfo.status.displayName,
            style: TextStyle(
              color: loginInfo.status.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeDisplay(QRLoginInfo loginInfo) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 二维码
          QrImageView(
            data: loginInfo.qrContent,
            version: QrVersions.auto,
            size: 200.0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            errorStateBuilder: (context, error) {
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('二维码生成失败')),
              );
            },
          ),

          const SizedBox(height: 16),

          // 二维码ID（调试用）
          if (loginInfo.qrId.isNotEmpty)
            Text(
              'ID: ${loginInfo.qrId}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '使用说明',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '1. 打开${widget.cloudDriveType.displayName}手机APP\n'
            '2. 点击"扫一扫"功能\n'
            '3. 扫描上方二维码\n'
            '4. 在手机上确认登录',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown(QRLoginInfo loginInfo) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
      builder: (context, snapshot) {
        final remaining = loginInfo.remainingSeconds;
        if (remaining <= 0) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '二维码已过期',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        final minutes = remaining ~/ 60;
        final seconds = remaining % 60;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                remaining < 60
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '剩余时间: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: remaining < 60 ? Colors.orange[700] : Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(QRLoginInfo loginInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _regenerateQR,
          icon: const Icon(Icons.refresh),
          label: const Text('重新生成'),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: _cancelLogin,
          icon: const Icon(Icons.close),
          label: const Text('取消登录'),
        ),
      ],
    );
  }
}
