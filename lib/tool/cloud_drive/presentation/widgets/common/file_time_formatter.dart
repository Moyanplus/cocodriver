/// 通用时间格式化工具（精确到秒），供云盘 UI 复用。
class FileTimeFormatter {
  static String format(DateTime? time) {
    if (time == null) return '--';
    return '${time.month.toString().padLeft(2, '0')}/'
        '${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }
}
