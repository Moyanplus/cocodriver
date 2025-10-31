/// 添加账号表单常量
///
/// 定义表单组件中使用的所有常量，包括文本、尺寸等
class AddAccountFormConstants {
  // 私有构造函数，防止实例化
  AddAccountFormConstants._();

  // ==================== 文本常量 ====================

  // 标签文本
  static const String labelCloudDriveType = '云盘类型';
  static const String labelAccountName = '账号名称';
  static const String labelLoginMethod = '登录方式';
  static const String labelCookie = 'Cookie';

  // 提示文本
  static const String hintAccountName = '请输入账号名称';
  static const String hintCookie = '请输入登录后的Cookie';

  // 按钮文本
  static const String btnCancel = '取消';
  static const String btnAddAccount = '添加账号';
  static const String btnStartLogin = '开始登录';
  static const String btnCheck = '检查';
  static const String btnChecking = '检查中...';

  // 登录方式文本
  static const String authMethodWeb = '网页';
  static const String authMethodCookie = 'CK';
  static const String authMethodAuthorization = 'AUTH';
  static const String authMethodQRCode = '二维码';

  // 说明文本
  static const String instructionTitle = '使用说明';
  static const String instructionCookieTitle = '获取Cookie步骤';

  static const String webViewInstructions =
      '1. 点击"开始登录"按钮\n'
      '2. 在打开的页面中完成登录\n'
      '3. 登录成功后点击悬浮按钮自动获取Cookie\n'
      '4. 确认添加账号';

  // 错误和状态消息
  static const String msgFormIncomplete = '请填写完整信息';
  static const String msgQRCodeNotGenerated = '请先生成二维码并完成登录';
  static const String msgAccountCreateFailed = '创建账号失败';
  static const String msgQRLoginFailed = '二维码登录失败';
  static const String msgLoadingPreferences = '加载用户偏好设置...';

  // ==================== 尺寸常量 ====================

  // 边距
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 8.0;
  static const double itemSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double tinySpacing = 2.0;

  // 圆角
  static const double borderRadius = 8.0;
  static const double smallBorderRadius = 6.0;

  // 图标大小
  static const double iconSizeSmall = 12.0;
  static const double iconSizeMedium = 16.0;
  static const double iconSizeNormal = 18.0;
  static const double iconSizeLarge = 20.0;

  // 字体大小
  static const double fontSizeSmall = 12.0;
  static const double fontSizeNormal = 14.0;

  // 其他尺寸
  static const double loadingIndicatorSize = 16.0;
  static const double loadingIndicatorStroke = 2.0;
  static const double loadingMinHeight = 200.0;

  // 内容边距
  static const double contentPaddingHorizontal = 16.0;
  static const double contentPaddingVertical = 12.0;

  // 按钮边距
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;
  static const double buttonSpacing = 12.0;

  // TextField 行数
  static const int cookieTextFieldMaxLines = 3;

  // 透明度
  static const double outlineOpacity = 0.2;
  static const double containerOpacity = 0.3;
}
