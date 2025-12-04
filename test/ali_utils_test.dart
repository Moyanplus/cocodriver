import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:coco_cloud_drive/tool/cloud_drive/data/models/cloud_drive_entities.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/services/providers/ali/api/ali_base_service.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/services/providers/ali/models/responses/ali_share_record.dart';

void main() {
  group('AliBaseService.parseUserIdFromToken', () {
    test('returns userId when payload contains userId', () {
      final payload = '{"userId":"abc123"}';
      final token = 'eyJhbGciOiJIUzI1NiJ9.${_encodePayload(payload)}.signature';

      final userId = AliBaseService.parseUserIdFromToken(token);

      expect(userId, 'abc123');
    });

    test('returns null for invalid token', () {
      expect(AliBaseService.parseUserIdFromToken('invalid'), isNull);
      expect(AliBaseService.parseUserIdFromToken(null), isNull);
    });
  });

  group('AliShareRecord.fromJson', () {
    test('parses first file and metadata', () {
      final json = {
        'share_id': 'sid',
        'share_name': '分享1',
        'share_url': 'https://a.b/c',
        'expired': false,
        'share_pwd': '1234',
        'created_at': '2023-08-20T15:01:36.833Z',
        'first_file': {
          'file_id': 'f1',
          'name': '视频.mp4',
          'type': 'file',
          'parent_file_id': 'root',
          'created_at': '2023-08-20T15:01:00.000Z',
          'updated_at': '2023-08-20T15:02:00.000Z',
          'thumbnail': 'thumb',
          'category': 'video',
          'size': 10,
        },
      };

      final record = AliShareRecord.fromJson(json);

      expect(record.shareId, 'sid');
      expect(record.shareName, '分享1');
      expect(record.sharePwd, '1234');
      expect(record.expired, isFalse);
      expect(record.firstFile, isNotNull);
      expect(record.firstFile!.id, 'f1');
      expect(record.firstFile!.thumbnailUrl, 'thumb');
      expect(record.firstFile!.category, FileCategory.video);
    });
  });

  group('AliBaseService.parseFileItem', () {
    test('parses file item with date and category', () {
      final item = {
        'file_id': 'f123',
        'name': 'img.png',
        'type': 'file',
        'parent_file_id': 'root',
        'size': 100,
        'created_at': '2023-09-01T10:00:00.000Z',
        'updated_at': '2023-09-02T10:00:00.000Z',
        'thumbnail': 'thumb-url',
        'category': 'image',
        'mime_type': 'image/png',
      };

      final parsed = AliBaseService.parseFileItem(item)!;
      expect(parsed.id, 'f123');
      expect(parsed.name, 'img.png');
      expect(parsed.isFolder, isFalse);
      expect(parsed.folderId, 'root');
      expect(parsed.size, 100);
      expect(parsed.thumbnailUrl, 'thumb-url');
      expect(
        parsed.category,
        isNull,
      ); // parseFileItem keeps raw category in metadata
      expect(parsed.metadata?['category'], 'image');
      expect(parsed.metadata?['mimeType'], 'image/png');
      expect(parsed.createdAt, isA<DateTime>());
      expect(parsed.updatedAt, isA<DateTime>());
    });

    test('returns null when missing id or name', () {
      expect(AliBaseService.parseFileItem({}), isNull);
      expect(AliBaseService.parseFileItem({'file_id': '1'}), isNull);
    });

    test('parses create folder response that uses file_name', () {
      final item = {
        'parent_file_id': 'root',
        'type': 'folder',
        'file_id': '693124d21088770910a64cd08fe3df9c95a56004',
        'domain_id': 'bj29',
        'drive_id': '513204303',
        'file_name': '0',
        'encrypt_mode': 'none',
        'created_at': '2025-12-04T06:06:10.001Z',
        'updated_at': '2025-12-04T06:06:10.001Z',
      };

      final parsed = AliBaseService.parseFileItem(item)!;

      expect(parsed.id, '693124d21088770910a64cd08fe3df9c95a56004');
      expect(parsed.name, '0');
      expect(parsed.isFolder, isTrue);
      expect(parsed.createdAt, isA<DateTime>());
      expect(parsed.updatedAt, isA<DateTime>());
      expect(parsed.metadata?['driveId'], '513204303');
    });

    test('parses upload complete response with content_type and modified_at', () {
      final item = {
        'drive_id': '513204303',
        'domain_id': 'bj29',
        'file_id': '693126ef75a319601cad4484bbc7ca72eb6ec8ec',
        'name': '截屏2025-12-03 10.56.24.png',
        'type': 'file',
        'content_type': 'application/oct-stream',
        'created_at': '2025-12-04T06:15:11.103Z',
        'updated_at': '2025-12-04T06:15:11.803Z',
        'modified_at': '2025-12-04T06:15:11.103Z',
        'file_extension': 'png',
        'size': 44207,
        'status': 'available',
        'user_meta': '{"channel":"file_upload","client":"web"}',
        'upload_id': 'A8A84FC3AA7E4848B5D5C6827130EC8E',
        'parent_file_id': '6930f0a8db1f958d19d54a18b56ae8b7d785a962',
        'crc64_hash': '13909693009216209223',
        'content_hash': '0E16EA05856A0E95CEEBE79EFC6E0846D9E12337',
        'content_hash_name': 'sha1',
        'category': 'image',
        'encrypt_mode': 'none',
        'user_tags': {
          'channel': 'file_upload',
          'client': 'web',
        },
        'local_modified_at': '2025-12-03T02:56:26.775Z',
        'revision_id': '693126ef57c166ce8f934246ab0ffb6ffba4011d',
        'location': 'cn-beijing',
        'content_uri': '',
      };

      final parsed = AliBaseService.parseFileItem(item)!;

      expect(parsed.id, '693126ef75a319601cad4484bbc7ca72eb6ec8ec');
      expect(parsed.name, '截屏2025-12-03 10.56.24.png');
      expect(parsed.isFolder, isFalse);
      expect(parsed.size, 44207);
      expect(parsed.createdAt, DateTime.parse('2025-12-04T06:15:11.103Z'));
      expect(parsed.updatedAt, DateTime.parse('2025-12-04T06:15:11.803Z'));
      expect(parsed.metadata?['mimeType'], 'application/oct-stream');
      expect(parsed.metadata?['fileExtension'], 'png');
      expect(parsed.metadata?['crc64Hash'], '13909693009216209223');
      expect(parsed.metadata?['uploadId'], 'A8A84FC3AA7E4848B5D5C6827130EC8E');
      expect(parsed.metadata?['localModifiedAt'], '2025-12-03T02:56:26.775Z');
      expect(parsed.metadata?['category'], 'image');
    });
  });
}

String _encodePayload(String payload) {
  final bytes = payload.codeUnits;
  final encoded = base64UrlEncode(bytes).replaceAll('=', '');
  return encoded;
}
