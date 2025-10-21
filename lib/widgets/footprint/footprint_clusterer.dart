import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import '../../models/poetry_card.dart';
import 'footprint_marker_builder.dart';

/// 标记点 - 用于聚合计算
class _MarkerPoint {
  final String locationKey;
  final LatLng position;
  final List<PoetryCard> cards;

  _MarkerPoint({
    required this.locationKey,
    required this.position,
    required this.cards,
  });
}

/// 足迹聚合器
class FootprintClusterer {
  /// 聚合标记点（基于地图缩放级别和屏幕距离）
  static List<ClusterMarker> clusterMarkers({
    required Map<String, List<PoetryCard>> groupedCards,
    required double currentZoom,
  }) {
    if (groupedCards.isEmpty) return [];

    // 将分组的卡片转换为待聚合的点
    final points = <_MarkerPoint>[];
    groupedCards.forEach((locationKey, cards) {
      if (cards.isEmpty) return;

      final location = cards.first.selectedPlace!;
      final coords = location.location.split(',');
      if (coords.length != 2) return;

      try {
        final lng = double.parse(coords[0]);
        final lat = double.parse(coords[1]);
        points.add(_MarkerPoint(
          locationKey: locationKey,
          position: LatLng(lat, lng),
          cards: cards,
        ));
      } catch (e) {
        print('解析位置坐标失败: $e');
      }
    });

    // 根据缩放级别计算聚合距离（像素）
    final clusterPixelDistance = _getClusterDistance(currentZoom);

    // 执行聚合
    final clusters = <ClusterMarker>[];
    final processed = <int>{};

    for (int i = 0; i < points.length; i++) {
      if (processed.contains(i)) continue;

      final point = points[i];
      final clusterCards = <PoetryCard>[...point.cards];
      final clusterLocationKeys = <String>[point.locationKey];
      final clusterPositions = <LatLng>[point.position];

      // 查找附近需要聚合的点
      for (int j = i + 1; j < points.length; j++) {
        if (processed.contains(j)) continue;

        final otherPoint = points[j];
        final distance = _calculateScreenDistance(
          point.position,
          otherPoint.position,
          currentZoom,
        );

        // 如果在聚合距离内，则聚合
        if (distance < clusterPixelDistance) {
          clusterCards.addAll(otherPoint.cards);
          clusterLocationKeys.add(otherPoint.locationKey);
          clusterPositions.add(otherPoint.position);
          processed.add(j);
        }
      }

      processed.add(i);

      // 计算聚合中心点（多个点的平均位置）
      final centerLat =
          clusterPositions.map((p) => p.latitude).reduce((a, b) => a + b) /
              clusterPositions.length;
      final centerLng =
          clusterPositions.map((p) => p.longitude).reduce((a, b) => a + b) /
              clusterPositions.length;

      clusters.add(ClusterMarker(
        id: clusterLocationKeys.join('_'),
        center: LatLng(centerLat, centerLng),
        cards: clusterCards,
        locationKeys: clusterLocationKeys,
      ));
    }

    return clusters;
  }

  /// 根据缩放级别获取聚合距离（像素）
  static double _getClusterDistance(double zoom) {
    // zoom: 3-18
    // 距离: 200-40 像素
    // 缩放级别越高（地图越详细），聚合距离越小
    if (zoom >= 15) return 40; // 高缩放级别：只聚合非常接近的点
    if (zoom >= 12) return 60; // 中高缩放级别
    if (zoom >= 10) return 80; // 中等缩放级别
    if (zoom >= 8) return 120; // 中低缩放级别
    if (zoom >= 6) return 160; // 低缩放级别
    return 200; // 极低缩放级别：聚合较远的点
  }

  /// 计算两个地理位置在当前缩放级别下的屏幕距离（像素）
  static double _calculateScreenDistance(
      LatLng point1, LatLng point2, double zoom) {
    // 使用简化的墨卡托投影计算屏幕距离
    final scale = 256 * math.pow(2, zoom);

    // 将经纬度转换为墨卡托投影坐标（像素）
    final x1 = (point1.longitude + 180) / 360 * scale;
    final y1 = (1 -
            math.log(math.tan(point1.latitude * math.pi / 180) +
                    1 / math.cos(point1.latitude * math.pi / 180)) /
                math.pi) /
        2 *
        scale;

    final x2 = (point2.longitude + 180) / 360 * scale;
    final y2 = (1 -
            math.log(math.tan(point2.latitude * math.pi / 180) +
                    1 / math.cos(point2.latitude * math.pi / 180)) /
                math.pi) /
        2 *
        scale;

    // 计算欧几里得距离
    return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
  }

  /// 按地点分组卡片
  static Map<String, List<PoetryCard>> groupCardsByLocation(
      List<PoetryCard> cards) {
    final grouped = <String, List<PoetryCard>>{};

    for (var card in cards) {
      if (card.selectedPlace == null) continue;

      final location = card.selectedPlace!;
      final locationKey = location.location; // 使用经纬度作为唯一标识

      if (!grouped.containsKey(locationKey)) {
        grouped[locationKey] = [];
      }
      grouped[locationKey]!.add(card);
    }

    return grouped;
  }
}
