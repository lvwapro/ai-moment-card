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
    required double currentZoom,
  }) {
    final markers = <Marker>[];

    for (var cluster in clusters) {
      final isSelected = selectedLocationKey == cluster.id;
      final totalCards = cluster.cards.length;
      final firstCard = cluster.cards.first;

      // 根据缩放级别计算marker大小
      final markerSize = _calculateMarkerSize(currentZoom);
      final imageSize = markerSize.imageSize;
      final markerWidth = markerSize.width;
      final markerHeight = markerSize.height;
      final badgeSize = markerSize.badgeSize;
      final fontSize = markerSize.fontSize;
      final triangleSize = markerSize.triangleSize;

      markers.add(
        Marker(
          point: cluster.center,
          width: markerWidth,
          height: markerHeight,
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
                      width: imageSize,
                      height: imageSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(imageSize * 0.16),
                        border: Border.all(
                          color: isSelected ? Colors.red : Colors.white,
                          width: markerSize.borderWidth,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: markerSize.shadowBlur,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(imageSize * 0.1),
                        child: _buildMarkerImage(firstCard),
                      ),
                    ),
                    // 数量徽章（如果有多个卡片）
                    if (totalCards > 1)
                      Positioned(
                        right: -5 * markerSize.scale,
                        top: -5 * markerSize.scale,
                        child: Container(
                          padding: EdgeInsets.all(4 * markerSize.scale),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.red : AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white,
                                width: 2 * markerSize.scale),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4 * markerSize.scale,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: BoxConstraints(
                            minWidth: badgeSize,
                            minHeight: badgeSize,
                          ),
                          child: Center(
                            child: Text(
                              totalCards.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSize,
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
                SizedBox(height: 2 * markerSize.scale),
                CustomPaint(
                  size: Size(triangleSize.width, triangleSize.height),
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

  /// 根据缩放级别计算marker大小
  /// zoom < 6: 小
  /// zoom 6-9: 中小
  /// zoom 9-12: 中等
  /// zoom 12-15: 标准
  /// zoom > 15: 大
  static _MarkerSize _calculateMarkerSize(double zoom) {
    double scale;

    if (zoom < 6) {
      // 小 (50%)
      scale = 0.5;
    } else if (zoom < 9) {
      // 中小 (65%)
      scale = 0.65;
    } else if (zoom < 12) {
      // 中等 (80%)
      scale = 0.8;
    } else if (zoom < 15) {
      // 标准 (100%)
      scale = 1.0;
    } else {
      // 大 (120%)
      scale = 1.2;
    }

    // 基础尺寸
    const double baseImageSize = 50.0;
    const double baseMarkerWidth = 60.0;
    const double baseMarkerHeight = 70.0;
    const double baseBadgeSize = 24.0;
    const double baseFontSize = 12.0;
    const double baseTriangleWidth = 12.0;
    const double baseTriangleHeight = 8.0;

    return _MarkerSize(
      scale: scale,
      imageSize: baseImageSize * scale,
      width: baseMarkerWidth * scale,
      height: baseMarkerHeight * scale,
      badgeSize: baseBadgeSize * scale,
      fontSize: baseFontSize * scale,
      triangleSize: Size(baseTriangleWidth * scale, baseTriangleHeight * scale),
      borderWidth: 3.0 * scale,
      shadowBlur: 6.0 * scale,
    );
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

/// Marker尺寸配置
class _MarkerSize {
  final double scale; // 缩放比例
  final double imageSize; // 图片尺寸
  final double width; // marker宽度
  final double height; // marker高度
  final double badgeSize; // 徽章尺寸
  final double fontSize; // 字体大小
  final Size triangleSize; // 三角形尺寸
  final double borderWidth; // 边框宽度
  final double shadowBlur; // 阴影模糊半径

  _MarkerSize({
    required this.scale,
    required this.imageSize,
    required this.width,
    required this.height,
    required this.badgeSize,
    required this.fontSize,
    required this.triangleSize,
    required this.borderWidth,
    required this.shadowBlur,
  });
}
