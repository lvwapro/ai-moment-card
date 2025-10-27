import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/poetry_card.dart';
import '../../theme/app_theme.dart';
import 'dart:ui' as ui;

/// 足迹标记构建器
class FootprintMarkerBuilder {
  /// 构建地图标记（使用聚合，显示图片缩略图）
  static List<Marker> buildMarkers({
    required List<ClusterMarker> clusters,
    required String? selectedLocationKey,
    required Function(List<PoetryCard>, String) onMarkerTap,
  }) {
    final markers = <Marker>[];

    for (var cluster in clusters) {
      final isSelected = selectedLocationKey == cluster.id;
      final totalCards = cluster.cards.length;
      final firstCard = cluster.cards.first;

      markers.add(
        Marker(
          point: cluster.center,
          width: 60,
          height: 70,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () => onMarkerTap(cluster.cards, cluster.id),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 图片缩略图标记
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 图片容器
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.red : Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: _buildMarkerImage(firstCard),
                      ),
                    ),
                    // 数量徽章（如果有多个卡片）
                    if (totalCards > 1)
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.red : AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          child: Center(
                            child: Text(
                              totalCards.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // 底部小三角指示器
                const SizedBox(height: 2),
                CustomPaint(
                  size: const Size(12, 8),
                  painter: TrianglePainter(
                    color: isSelected ? Colors.red : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return markers;
  }

  /// 构建标记的图片（优先使用缓存）
  static Widget _buildMarkerImage(PoetryCard card) {
    // 1. 优先使用本地缓存图片（最快）
    final localPaths = card.metadata['localImagePaths'] as List<dynamic>?;
    if (localPaths != null && localPaths.isNotEmpty) {
      final localPath = localPaths.first.toString();
      final localFile = File(localPath);
      return Image.file(
        localFile,
        fit: BoxFit.cover,
        cacheWidth: 100, // 缩小缓存尺寸，提高性能
        errorBuilder: (context, error, stackTrace) => _buildFallbackImage(card),
      );
    }

    // 2. 使用卡片原始图片（本地文件）
    if (!card.image.path.startsWith('http')) {
      return Image.file(
        card.image,
        fit: BoxFit.cover,
        cacheWidth: 100,
        errorBuilder: (context, error, stackTrace) => _buildNetworkImage(card),
      );
    }

    // 3. 最后才使用网络图片
    return _buildNetworkImage(card);
  }

  /// 构建网络图片（带缓存）
  static Widget _buildNetworkImage(PoetryCard card) {
    // 优先使用云端图片URL
    final cloudUrls = card.metadata['cloudImageUrls'] as List<dynamic>?;
    String? imageUrl;

    if (cloudUrls != null && cloudUrls.isNotEmpty) {
      final cloudUrl = cloudUrls.first.toString();
      if (cloudUrl.startsWith('http')) {
        imageUrl = cloudUrl;
      }
    }

    // 备用：使用卡片图片URL
    if (imageUrl == null && card.image.path.startsWith('http')) {
      imageUrl = card.image.path;
    }

    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        cacheWidth: 100, // 缓存优化
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) =>
            _buildDefaultMarkerImage(),
      );
    }

    return _buildDefaultMarkerImage();
  }

  /// 备用图片
  static Widget _buildFallbackImage(PoetryCard card) {
    if (card.image.path.startsWith('http')) {
      return _buildNetworkImage(card);
    } else {
      return Image.file(
        card.image,
        fit: BoxFit.cover,
        cacheWidth: 100,
        errorBuilder: (context, error, stackTrace) =>
            _buildDefaultMarkerImage(),
      );
    }
  }

  /// 占位符（加载中）
  static Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  /// 默认标记图片（当所有图片都加载失败时）
  static Widget _buildDefaultMarkerImage() {
    return Container(
      color: AppTheme.primaryColor.withOpacity(0.2),
      child: const Icon(
        Icons.image,
        color: AppTheme.primaryColor,
        size: 24,
      ),
    );
  }
}

/// 聚合类 - 表示一组聚合的卡片
class ClusterMarker {
  final String id; // 聚合ID
  final LatLng center; // 聚合中心点
  final List<PoetryCard> cards; // 包含的卡片
  final List<String> locationKeys; // 包含的位置keys

  ClusterMarker({
    required this.id,
    required this.center,
    required this.cards,
    required this.locationKeys,
  });
}

/// 三角形指示器画笔
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = ui.Path()
      ..moveTo(size.width / 2, size.height) // 底部中心点
      ..lineTo(0, 0) // 左上角
      ..lineTo(size.width, 0) // 右上角
      ..close();

    // 添加阴影
    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 4.0, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => color != oldDelegate.color;
}
