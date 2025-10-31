import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../../../core/logging/log_manager.dart';
import '../../data/models/cloud_drive_entities.dart';

/// 带认证的缓存管理器
/// 为每个账号创建独立的缓存管理器，支持Cookie认证
class AuthenticatedCacheManager extends CacheManager {
  static const key = 'authenticatedImageCache';

  static AuthenticatedCacheManager? _instance;

  factory AuthenticatedCacheManager() {
    _instance ??= AuthenticatedCacheManager._();
    return _instance!;
  }

  AuthenticatedCacheManager._()
    : super(
        Config(
          key,
          stalePeriod: const Duration(days: 7), // 缓存7天
          maxNrOfCacheObjects: 200, // 最多缓存200个图片
        ),
      );
}

/// 带认证的网络图片组件
/// 用于加载需要Cookie认证的图片（如夸克云盘缩略图）
/// 支持自动缓存，避免重复加载
class AuthenticatedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final CloudDriveAccount account;
  final Widget Function()? placeholderBuilder;
  final Widget Function()? errorBuilder;
  final BoxFit fit;

  const AuthenticatedNetworkImage({
    super.key,
    required this.imageUrl,
    required this.account,
    this.placeholderBuilder,
    this.errorBuilder,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: AuthenticatedCacheManager(),
      fit: fit,
      httpHeaders: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
        'Referer': 'https://pan.quark.cn/',
        if (account.cookies != null && account.cookies!.isNotEmpty)
          'Cookie': account.cookies!,
      },
      placeholder: (context, url) {
        LogManager().cloudDrive('⏳ 加载缩略图: $url');
        return placeholderBuilder?.call() ?? const SizedBox.shrink();
      },
      errorWidget: (context, url, error) {
        LogManager().error('缩略图加载失败: $url, error: $error');
        return errorBuilder?.call() ?? const Icon(Icons.error_outline);
      },
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }
}
