import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/poetry_card.dart';
import 'fallback_background.dart';

/// 缓存的卡片图片组件
///
/// 特点：
/// - 使用 StatefulWidget 保持图片状态
/// - 优先使用本地图片（同步加载）
/// - 异步加载时使用 FutureBuilder
/// - 防止不必要的重新加载
class CachedCardImage extends StatefulWidget {
  final PoetryCard card;

  const CachedCardImage({
    super.key,
    required this.card,
  });

  @override
  State<CachedCardImage> createState() => _CachedCardImageState();
}

class _CachedCardImageState extends State<CachedCardImage>
    with AutomaticKeepAliveClientMixin {
  ImageProvider? _cachedImageProvider;
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true; // 保持状态，防止重新加载

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedCardImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 只有当卡片ID变化时才重新加载
    if (oldWidget.card.id != widget.card.id) {
      _loadImage();
    }
  }

  /// 加载图片
  void _loadImage() {
    // 首先尝试同步获取本地图片
    final localProvider = _tryGetLocalImageSync();
    if (localProvider != null) {
      setState(() {
        _cachedImageProvider = localProvider;
      });
      return;
    }

    // 如果没有本地图片，异步加载
    if (!_isLoading) {
      _isLoading = true;
      _getImageProviderAsync().then((provider) {
        if (mounted) {
          setState(() {
            _cachedImageProvider = provider;
            _isLoading = false;
          });
        }
      });
    }
  }

  /// 尝试同步获取本地图片
  ImageProvider? _tryGetLocalImageSync() {
    // 使用统一的 getFirstImagePath() 方法获取首图
    final firstImagePath = widget.card.getFirstImagePath();

    // 判断是本地图片还是网络 URL
    if (!firstImagePath.startsWith('http')) {
      try {
        final localFile = File(firstImagePath);
        if (localFile.existsSync()) {
          return FileImage(localFile);
        }
      } catch (e) {
        // 本地文件检查失败
      }
    }

    return null;
  }

  /// 异步获取图片Provider
  Future<ImageProvider?> _getImageProviderAsync() async {
    // 使用统一的 getFirstImagePath() 方法获取首图
    final firstImagePath = widget.card.getFirstImagePath();

    // 判断是本地图片还是网络 URL
    if (firstImagePath.startsWith('http')) {
      return NetworkImage(
        firstImagePath,
        headers: {'Cache-Control': 'max-age=86400'},
      );
    } else {
      try {
        final localFile = File(firstImagePath);
        if (await localFile.exists()) {
          return FileImage(localFile);
        }
      } catch (e) {
        // 本地文件检查失败
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用以支持 AutomaticKeepAliveClientMixin

    if (_cachedImageProvider != null) {
      return RepaintBoundary(
        child: Image(
          image: _cachedImageProvider!,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallback(context);
          },
        ),
      );
    }

    // 加载中或无图片时显示备用背景
    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: FallbackBackgrounds.historyCard(),
    );
  }
}
