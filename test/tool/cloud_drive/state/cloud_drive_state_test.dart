import 'package:flutter_test/flutter_test.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/data/models/cloud_drive_entities.dart';

void main() {
  group('CloudDriveState Tests', () {
    late CloudDriveAccount testAccount;
    late CloudDriveFile testFile;

    setUp(() {
      testAccount = CloudDriveAccount(
        id: 'test_account_1',
        type: CloudDriveType.baidu,
        name: 'Test Account',
        cookies: 'test_cookies',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      testFile = CloudDriveFile(
        id: 'file_1',
        name: 'test_file.txt',
        size: 1024,
        isFolder: false,
        folderId: '0',
        updatedAt: DateTime.now(),
      );
    });

    group('Account State Tests', () {
      test('should create account with correct properties', () {
        expect(testAccount.id, equals('test_account_1'));
        expect(testAccount.type, equals(CloudDriveType.baidu));
        expect(testAccount.name, equals('Test Account'));
        expect(testAccount.cookies, equals('test_cookies'));
      });

      test('should handle account validation', () {
        expect(testAccount.cookies, isNotNull);
        expect(testAccount.createdAt, isA<DateTime>());
        expect(testAccount.lastLoginAt, isA<DateTime>());
      });
    });

    group('File State Tests', () {
      test('should create file with correct properties', () {
        expect(testFile.id, equals('file_1'));
        expect(testFile.name, equals('test_file.txt'));
        expect(testFile.size, equals(1024));
        expect(testFile.isFolder, isFalse);
        expect(testFile.folderId, equals('0'));
      });

      test('should handle file operations', () {
        expect(testFile.updatedAt, isA<DateTime>());
      });
    });

    group('Cloud Drive Type Tests', () {
      test('should have correct enum values', () {
        expect(CloudDriveType.values, hasLength(6));
        expect(CloudDriveType.values, contains(CloudDriveType.baidu));
        expect(CloudDriveType.values, contains(CloudDriveType.ali));
        expect(CloudDriveType.values, contains(CloudDriveType.lanzou));
        expect(CloudDriveType.values, contains(CloudDriveType.pan123));
        expect(CloudDriveType.values, contains(CloudDriveType.quark));
        expect(CloudDriveType.values, contains(CloudDriveType.chinaMobile));
      });

      test('should have correct display names', () {
        expect(CloudDriveType.baidu.displayName, equals('百度网盘'));
        expect(CloudDriveType.ali.displayName, equals('阿里云盘'));
        expect(CloudDriveType.lanzou.displayName, equals('蓝奏云'));
        expect(CloudDriveType.pan123.displayName, equals('123云盘'));
        expect(CloudDriveType.quark.displayName, equals('夸克云盘'));
        expect(CloudDriveType.chinaMobile.displayName, equals('中国移动云盘'));
      });
    });

    group('Auth Type Tests', () {
      test('should have correct enum values', () {
        expect(AuthType.values, hasLength(4));
        expect(AuthType.values, contains(AuthType.cookie));
        expect(AuthType.values, contains(AuthType.authorization));
        expect(AuthType.values, contains(AuthType.web));
        expect(AuthType.values, contains(AuthType.qrCode));
      });
    });
  });
}
