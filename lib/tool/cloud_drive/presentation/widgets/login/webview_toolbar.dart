import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/cloud_drive_ui_config.dart';
import '../common/cloud_drive_common_widgets.dart';

/// WebView工具栏组件
class WebViewToolbar extends StatelessWidget {
  final bool canGoBack;
  final bool canGoForward;
  final bool isLoading;
  final double currentZoom;
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final VoidCallback? onRefresh;
  final VoidCallback? onStop;
  final Function(double)? onZoomChanged;
  final VoidCallback? onManualCheck;

  const WebViewToolbar({
    super.key,
    this.canGoBack = false,
    this.canGoForward = false,
    this.isLoading = false,
    this.currentZoom = 1.0,
    this.onBack,
    this.onForward,
    this.onRefresh,
    this.onStop,
    this.onZoomChanged,
    this.onManualCheck,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // 导航按钮
          _buildNavigationButtons(),

          // 分隔线
          Container(
            width: 1.w,
            height: 32.h,
            color: CloudDriveUIConfig.dividerColor.withOpacity(0.3),
          ),

          // 刷新/停止按钮
          _buildRefreshButton(),

          // 分隔线
          Container(
            width: 1.w,
            height: 32.h,
            color: CloudDriveUIConfig.dividerColor.withOpacity(0.3),
          ),

          // 缩放控制
          _buildZoomControls(),

          const Spacer(),

          // 手动检查按钮
          if (onManualCheck != null) _buildManualCheckButton(),
        ],
      ),
    );
  }

  /// 构建导航按钮
  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // 后退按钮
        _buildToolbarButton(
          icon: Icons.arrow_back,
          onPressed: canGoBack ? onBack : null,
          tooltip: '后退',
        ),

        // 前进按钮
        _buildToolbarButton(
          icon: Icons.arrow_forward,
          onPressed: canGoForward ? onForward : null,
          tooltip: '前进',
        ),
      ],
    );
  }

  /// 构建刷新按钮
  Widget _buildRefreshButton() {
    return _buildToolbarButton(
      icon: isLoading ? Icons.stop : Icons.refresh,
      onPressed: isLoading ? onStop : onRefresh,
      tooltip: isLoading ? '停止' : '刷新',
    );
  }

  /// 构建缩放控制
  Widget _buildZoomControls() {
    return Row(
      children: [
        // 缩小按钮
        _buildToolbarButton(
          icon: Icons.zoom_out,
          onPressed:
              currentZoom > 0.5
                  ? () => onZoomChanged?.call(currentZoom - 0.25)
                  : null,
          tooltip: '缩小',
        ),

        // 缩放显示
        Container(
          width: 60.w,
          alignment: Alignment.center,
          child: Text(
            '${(currentZoom * 100).toInt()}%',
            style: CloudDriveUIConfig.smallTextStyle,
          ),
        ),

        // 放大按钮
        _buildToolbarButton(
          icon: Icons.zoom_in,
          onPressed:
              currentZoom < 3.0
                  ? () => onZoomChanged?.call(currentZoom + 0.25)
                  : null,
          tooltip: '放大',
        ),
      ],
    );
  }

  /// 构建手动检查按钮
  Widget _buildManualCheckButton() {
    return Container(
      margin: EdgeInsets.only(right: CloudDriveUIConfig.spacingS),
      child: CloudDriveCommonWidgets.buildSecondaryButton(
        text: '检查登录',
        onPressed: onManualCheck ?? () {},
        icon: const Icon(Icons.check_circle),
      ),
    );
  }

  /// 构建工具栏按钮
  Widget _buildToolbarButton({
    required IconData icon,
    VoidCallback? onPressed,
    required String tooltip,
  }) {
    return SizedBox(
      width: 40.w,
      height: 40.h,
      child: IconButton(
        icon: Icon(
          icon,
          size: CloudDriveUIConfig.iconSize,
          color:
              onPressed != null
                  ? CloudDriveUIConfig.textColor
                  : CloudDriveUIConfig.secondaryTextColor,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}
