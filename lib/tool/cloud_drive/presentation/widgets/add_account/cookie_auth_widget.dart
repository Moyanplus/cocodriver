import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Cookie认证组件
class CookieAuthWidget extends StatelessWidget {
  final TextEditingController cookiesController;
  final VoidCallback? onHelpPressed;

  const CookieAuthWidget({
    super.key,
    required this.cookiesController,
    this.onHelpPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Cookie信息',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onHelpPressed,
              icon: Icon(Icons.help_outline, size: 16.sp),
              label: Text('如何获取', style: TextStyle(fontSize: 12.sp)),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: TextField(
            controller: cookiesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  '请输入登录后的Cookie信息\n\n获取方法：\n1. 在浏览器中登录云盘\n2. 按F12打开开发者工具\n3. 在Network标签页中找到请求\n4. 复制Cookie值',
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
                height: 1.4,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12.w),
            ),
            style: TextStyle(fontSize: 14.sp, fontFamily: 'monospace'),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Cookie信息包含您的登录状态，请妥善保管，不要泄露给他人',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
