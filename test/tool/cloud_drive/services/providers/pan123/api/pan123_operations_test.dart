import 'package:coco_cloud_drive/tool/cloud_drive/core/result.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/models/cloud_drive_models.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/services/providers/pan123/api/pan123_api_client.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/services/providers/pan123/api/pan123_base_service.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/services/providers/pan123/api/pan123_operations.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/services/providers/pan123/models/requests/pan123_list_request.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/services/providers/pan123/models/requests/pan123_operation_requests.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart' as mockito;
import 'package:mockito/mockito.dart';

class MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _successResponse([Map<String, dynamic>? data]) {
  return Response(
    data: data ?? {'code': 0},
    requestOptions: RequestOptions(path: ''),
    statusCode: 200,
  );
}

Response<Map<String, dynamic>> _failureResponse(int code, String message) {
  return Response(
    data: {'code': code, 'message': message},
    requestOptions: RequestOptions(path: ''),
    statusCode: 200,
  );
}

CloudDriveAccount _buildAccount() {
  return CloudDriveAccount(
    id: 'pan123',
    name: '123Test',
    type: CloudDriveType.pan123,
    authorizationToken: 'token',
    createdAt: DateTime.now(),
  );
}

CloudDriveFile _buildFile() =>
    CloudDriveFile(id: '1', name: 'file.txt', isFolder: false, folderId: '0');

void main() {
  late MockDio dio;
  late CloudDriveAccount account;

  setUp(() {
    dio = MockDio();
    account = _buildAccount();
    Pan123BaseService.dioFactory = (_) => dio;
  });

  tearDown(() {
    Pan123BaseService.resetDioFactory();
  });

  Future<void> stubPost(Map<String, dynamic>? body) async {
    mockito
        .when(() => dio.post(any<String>(), data: mockito.anyNamed('data')))
        .thenAnswer((invocation) async => _successResponse(body));
  }

  test('rename returns true on code 0', () async {
    await stubPost({'code': 0});
    final result = await Pan123Operations.rename(
      account: account,
      request: Pan123RenameRequest(file: _buildFile(), newName: 'new'),
    );
    expect(result, isTrue);
  });

  test('move returns true on code 0', () async {
    await stubPost({'code': 0});
    final result = await Pan123Operations.move(
      account: account,
      request: Pan123MoveRequest(file: _buildFile(), targetParentId: '123'),
    );
    expect(result, isTrue);
  });

  test('copy returns true on code 0', () async {
    await stubPost({'code': 0});
    final result = await Pan123Operations.copy(
      account: account,
      request: Pan123CopyRequest(file: _buildFile(), targetParentId: '123'),
    );
    expect(result, isTrue);
  });

  test('delete returns true on code 0', () async {
    await stubPost({'code': 0});
    final result = await Pan123Operations.delete(
      account: account,
      request: Pan123DeleteRequest(file: _buildFile()),
    );
    expect(result, isTrue);
  });

  test('rename throws CloudDriveException on failure code', () async {
    mockito
        .when(
          () => dio.post(mockito.any<String>(), data: mockito.anyNamed('data')),
        )
        .thenAnswer((_) async => _failureResponse(-3, 'error'));

    expect(
      () => Pan123Operations.rename(
        account: account,
        request: Pan123RenameRequest(file: _buildFile(), newName: 'name'),
      ),
      throwsA(isA<CloudDriveException>()),
    );
  });

  test('listFiles parses InfoList correctly', () async {
    final data = {
      'code': 0,
      'data': {
        'Next': 2,
        'Total': 1,
        'InfoList': [
          {
            'FileId': '10',
            'FileName': 'demo.txt',
            'Type': 0,
            'Size': '1234',
            'ParentFileId': '0',
            'UpdateAt': '2025-12-01T00:00:00.000Z',
          },
        ],
      },
    };

    mockito
        .when(() => dio.get(mockito.any<String>()))
        .thenAnswer((_) async => _successResponse(data));

    final response = await Pan123ApiClient().listFiles(
      account: account,
      request: const Pan123ListRequest(parentId: '0'),
    );
    expect(response.files, hasLength(1));
    expect(response.files.first.id, '10');
    expect(response.files.first.name, 'demo.txt');
  });
}
