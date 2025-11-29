import 'package:flutter_test/flutter_test.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/data/cache/file_list_cache.dart';
import 'package:coco_cloud_drive/tool/cloud_drive/config/cloud_drive_cache_config.dart';

void main() {
  group('FileListCacheEntry', () {
    test('uses default TTL from CloudDriveCacheConfig', () {
      final entry = FileListCacheEntry(
        files: const [],
        folders: const [],
        timestamp: DateTime.now(),
      );
      expect(entry.ttl, CloudDriveCacheConfig.defaultFolderCacheTtl);
    });
  });
}
