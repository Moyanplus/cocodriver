import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/models/cloud_drive_dtos.dart';
import '../../../data/models/cloud_drive_entities.dart';
import '../../../services/base/qr_login_service.dart';

/// 二维码登录组件
class QRCodeAuthWidget extends StatefulWidget {
  final CloudDriveType cloudDriveType;
  final Function(QRLoginInfo)? onLoginSuccess;
  final Function(String)? onError;

  const QRCodeAuthWidget({
    super.key,
    required this.cloudDriveType,
    this.onLoginSuccess,
    this.onError,
  });

  @override
  State<QRCodeAuthWidget> createState() => _QRCodeAuthWidgetState();
}

class _QRCodeAuthWidgetState extends State<QRCodeAuthWidget> {
  StreamSubscription<QRLoginInfo>? _qrLoginSubscription;
  QRLoginInfo? _currentQRLoginInfo;
  bool _isGeneratingQR = false;
  bool _isLoginSuccess = false;
  String? _qrError;

  /// 释放资源
  ///
  /// 取消二维码登录订阅，取消当前二维码登录会话
  /// 确保在组件销毁时正确清理资源
  @override
  void dispose() {
    _qrLoginSubscription?.cancel();
    if (_currentQRLoginInfo != null) {
      QRLoginManager.cancelQRLogin(_currentQRLoginInfo!.qrId);
    }
    super.dispose();
  }

  /// 构建二维码登录组件的UI界面
  ///
  /// 返回包含二维码显示、状态指示器和控制按钮的Column组件
  /// 使用响应式尺寸进行布局设计
  @override
  void initState() {
    super.initState();
    // 自动开始生成二维码
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startQRLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildQRCodeDisplay(),
        SizedBox(height: 16.h),
        _buildQRStatusIndicator(),
      ],
    );
  }

  /// 构建二维码显示区域
  ///
  /// 根据当前状态显示不同的内容：
  /// - 生成中：显示加载指示器
  /// - 已生成：显示二维码图片
  /// - 未生成：显示提示信息
  ///
  /// 返回对应的Widget组件
  Widget _buildQRCodeDisplay() {
    if (_isGeneratingQR) {
      return Container(
        width: 200.w,
        height: 200.h,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                '正在生成二维码...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentQRLoginInfo != null) {
      return GestureDetector(
        onTap: _isLoginSuccess ? null : _refreshQRCode,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              QrImageView(
                data: _currentQRLoginInfo!.qrContent,
                version: QrVersions.auto,
                size: 200.w,
                backgroundColor: Colors.white,
              ),
              SizedBox(height: 12.h),
              Text(
                _isLoginSuccess ? '登录成功' : '请使用手机扫描二维码登录',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              if (!_isLoginSuccess) ...[
                SizedBox(height: 4.h),
                Text(
                  '点击二维码可刷新',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // 没有二维码时显示空状态（不应该出现，因为会自动生成）
    return const SizedBox.shrink();
  }

  /// 构建二维码状态指示器
  ///
  /// 根据当前状态显示不同的状态信息：
  /// - 登录成功：显示成功信息
  /// - 错误状态：显示错误信息
  /// - 正常状态：显示提示信息
  /// - 无状态：返回空组件
  ///
  /// 返回状态指示器Widget
  Widget _buildQRStatusIndicator() {
    if (_isLoginSuccess) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, size: 16.sp, color: Colors.green),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                '扫码成功，请点击底部"添加账号"',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_qrError != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              size: 16.sp,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                _qrError!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_currentQRLoginInfo != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16.sp,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                '二维码已生成，请扫描登录',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// 刷新二维码
  ///
  /// 取消当前的登录会话并重新生成二维码
  void _refreshQRCode() {
    if (_currentQRLoginInfo != null) {
      QRLoginManager.cancelQRLogin(_currentQRLoginInfo!.qrId);
    }
    _qrLoginSubscription?.cancel();

    setState(() {
      _currentQRLoginInfo = null;
      _qrError = null;
      _isLoginSuccess = false;
    });

    _startQRLogin();
  }

  /// 开始二维码登录流程
  ///
  /// 设置生成状态为true，清除之前的错误信息
  /// 启动二维码登录管理器并监听登录状态变化
  /// 登录成功或失败时会更新UI状态
  void _startQRLogin() {
    setState(() {
      _isGeneratingQR = true;
      _qrError = null;
      _isLoginSuccess = false;
    });

    _qrLoginSubscription = QRLoginManager.startQRLogin(
      widget.cloudDriveType,
    ).listen(
      (qrLoginInfo) {
        setState(() {
          _currentQRLoginInfo = qrLoginInfo;
          _isGeneratingQR = false;
        });

        // 检查登录状态
        if (qrLoginInfo.status == QRLoginStatus.success) {
          // 登录成功，显示成功状态，通知外部表单
          setState(() {
            _isLoginSuccess = true;
          });
          widget.onLoginSuccess?.call(qrLoginInfo);
        } else if (qrLoginInfo.status == QRLoginStatus.failed) {
          // 登录失败
          setState(() {
            _qrError = qrLoginInfo.message;
            _isLoginSuccess = false;
          });
          widget.onError?.call(qrLoginInfo.message ?? '登录失败');
        } else if (qrLoginInfo.status == QRLoginStatus.expired) {
          // 二维码过期
          setState(() {
            _qrError = '二维码已过期，请重新生成';
            _isLoginSuccess = false;
          });
          widget.onError?.call('二维码已过期');
        }
      },
      onError: (error) {
        setState(() {
          _qrError = error.toString();
          _isGeneratingQR = false;
          _isLoginSuccess = false;
        });
        widget.onError?.call(error.toString());
      },
    );
  }
}
