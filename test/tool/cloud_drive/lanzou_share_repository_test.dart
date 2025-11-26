import 'package:flutter_test/flutter_test.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/services/lanzou/repository/lanzou_share_repository.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/services/lanzou/models/lanzou_result.dart';

void main() {
  test('LanzouShareRepository returns failure by default', () async {
    final repository = LanzouShareRepository();
    final result = await repository.createShareLink(fileIds: ['1']);
    expect(result.isSuccess, false);
    expect(result.error?.message, contains('暂不支持'));
  });
}
