import 'package:flutter_test/flutter_test.dart';
import '../../../../lib/tool/cloud_drive/data/models/cloud_drive_entities.dart';

void main() {
  group('CloudDriveBusinessRules Tests', () {
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
        modifiedTime: DateTime.now(),
      );
    });

    group('Account Validation Tests', () {
      test('should validate account with cookies', () {
        expect(testAccount.cookies, isNotNull);
        expect(testAccount.cookies, isNotEmpty);
        expect(testAccount.type, isA<CloudDriveType>());
      });

      test('should validate account creation time', () {
        expect(testAccount.createdAt, isA<DateTime>());
        expect(testAccount.lastLoginAt, isA<DateTime>());
        expect(testAccount.createdAt.isBefore(DateTime.now()), isTrue);
      });
    });

    group('File Validation Tests', () {
      test('should validate file properties', () {
        expect(testFile.id, isNotEmpty);
        expect(testFile.name, isNotEmpty);
        expect(testFile.size, greaterThanOrEqualTo(0));
        expect(testFile.isFolder, isA<bool>());
        expect(testFile.folderId, isNotEmpty);
      });

      test('should validate file timestamps', () {
        expect(testFile.modifiedTime, isA<DateTime>());
        expect(testFile.modifiedTime!.isBefore(DateTime.now()), isTrue);
      });
    });

    group('Cloud Drive Type Validation Tests', () {
      test('should validate all cloud drive types', () {
        final types = CloudDriveType.values;
        expect(types, hasLength(5));

        for (final type in types) {
          expect(type.displayName, isNotEmpty);
          expect(type.displayName, isA<String>());
        }
      });

      test('should validate specific cloud drive types', () {
        expect(CloudDriveType.baidu.displayName, equals('百度网盘'));
        expect(CloudDriveType.ali.displayName, equals('阿里云盘'));
        expect(CloudDriveType.lanzou.displayName, equals('蓝奏云'));
        expect(CloudDriveType.pan123.displayName, equals('123云盘'));
        expect(CloudDriveType.quark.displayName, equals('夸克云盘'));
      });
    });

    group('Auth Type Validation Tests', () {
      test('should validate all auth types', () {
        final authTypes = AuthType.values;
        expect(authTypes, hasLength(3));
        expect(authTypes, contains(AuthType.cookie));
        expect(authTypes, contains(AuthType.authorization));
        expect(authTypes, contains(AuthType.qrCode));
      });
    });

    group('File Size Validation Tests', () {
      test('should handle zero size files', () {
        final zeroSizeFile = CloudDriveFile(
          id: 'zero_file',
          name: 'zero.txt',
          size: 0,
          isFolder: false,
          folderId: '0',
          modifiedTime: DateTime.now(),
        );

        expect(zeroSizeFile.size, equals(0));
        expect(zeroSizeFile.isFolder, isFalse);
      });

      test('should handle large files', () {
        final largeFile = CloudDriveFile(
          id: 'large_file',
          name: 'large.txt',
          size: 1024 * 1024 * 1024, // 1GB
          isFolder: false,
          folderId: '0',
          modifiedTime: DateTime.now(),
        );

        expect(largeFile.size, equals(1024 * 1024 * 1024));
        expect(largeFile.size, greaterThan(0));
      });
    });
  });
}
