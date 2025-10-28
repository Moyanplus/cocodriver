import 'package:flutter_test/flutter_test.dart';
import '../../../../lib/tool/cloud_drive/data/models/cloud_drive_entities.dart';

void main() {
  group('CloudDriveService Tests', () {
    late CloudDriveAccount testAccount;

    setUp(() {
      testAccount = CloudDriveAccount(
        id: 'test_account_1',
        type: CloudDriveType.baidu,
        name: 'Test Account',
        cookies: 'test_cookies',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    });

    group('Account Creation Tests', () {
      test('should create account with correct properties', () {
        expect(testAccount.id, equals('test_account_1'));
        expect(testAccount.type, equals(CloudDriveType.baidu));
        expect(testAccount.name, equals('Test Account'));
        expect(testAccount.cookies, equals('test_cookies'));
        expect(testAccount.createdAt, isA<DateTime>());
        expect(testAccount.lastLoginAt, isA<DateTime>());
      });

      test('should handle different cloud drive types', () {
        final aliAccount = CloudDriveAccount(
          id: 'ali_account',
          type: CloudDriveType.ali,
          name: 'Ali Account',
          createdAt: DateTime.now(),
        );

        expect(aliAccount.type, equals(CloudDriveType.ali));
        expect(aliAccount.name, equals('Ali Account'));
      });
    });

    group('Cloud Drive Type Tests', () {
      test('should have correct display names', () {
        expect(CloudDriveType.baidu.displayName, equals('百度网盘'));
        expect(CloudDriveType.ali.displayName, equals('阿里云盘'));
        expect(CloudDriveType.lanzou.displayName, equals('蓝奏云'));
        expect(CloudDriveType.pan123.displayName, equals('123云盘'));
        expect(CloudDriveType.quark.displayName, equals('夸克云盘'));
      });
    });

    group('File Creation Tests', () {
      test('should create file with correct properties', () {
        final testFile = CloudDriveFile(
          id: 'file_1',
          name: 'test_file.txt',
          size: 1024,
          isFolder: false,
          folderId: '0',
          modifiedTime: DateTime.now(),
        );

        expect(testFile.id, equals('file_1'));
        expect(testFile.name, equals('test_file.txt'));
        expect(testFile.size, equals(1024));
        expect(testFile.isFolder, isFalse);
        expect(testFile.folderId, equals('0'));
      });

      test('should create folder with correct properties', () {
        final testFolder = CloudDriveFile(
          id: 'folder_1',
          name: 'test_folder',
          size: 0,
          isFolder: true,
          folderId: '0',
          modifiedTime: DateTime.now(),
        );

        expect(testFolder.id, equals('folder_1'));
        expect(testFolder.name, equals('test_folder'));
        expect(testFolder.size, equals(0));
        expect(testFolder.isFolder, isTrue);
      });
    });
  });
}
