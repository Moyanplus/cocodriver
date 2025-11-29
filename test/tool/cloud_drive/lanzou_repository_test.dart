import 'package:coco_cloud_drive/tool/cloud_drive/services/providers/lanzou/models/lanzou_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LanzouResult success helper', () {
    final result = LanzouResult.success('data');
    expect(result.isSuccess, true);
    expect(result.data, 'data');
    expect(result.error, null);
  });

  test('LanzouResult failure helper', () {
    final failure = LanzouFailure(message: 'error');
    final result = LanzouResult.failure<String>(failure);
    expect(result.isSuccess, false);
    expect(result.error?.message, 'error');
  });
}
