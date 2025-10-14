import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/poetry_card.dart';
import '../providers/history_manager.dart';
import '../screens/card_detail_screen.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

/// 足迹页面 - 在地图上展示用户生成卡片的位置
class FootprintScreen extends StatefulWidget {
  const FootprintScreen({super.key});

  @override
  State<FootprintScreen> createState() => _FootprintScreenState();
}

class _FootprintScreenState extends State<FootprintScreen> {
  final MapController _mapController = MapController();
  PoetryCard? _selectedCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          context.l10n('我的足迹'),
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
      body: Consumer<HistoryManager>(
        builder: (context, historyManager, child) {
          // 获取所有有位置信息的卡片
          final cardsWithLocation = historyManager.cards
              .where((card) =>
                  card.nearbyPlaces != null && card.nearbyPlaces!.isNotEmpty)
              .toList();

          if (cardsWithLocation.isEmpty) {
            return _buildEmptyState();
          }

          // 提取所有位置点
          final markers = _buildMarkers(cardsWithLocation);

          // 计算地图中心点和缩放级别
          final center = _calculateCenter(cardsWithLocation);

          return Stack(
            children: [
              // 地图
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 12.0,
                  minZoom: 3.0,
                  maxZoom: 18.0,
                  onTap: (_, __) {
                    setState(() {
                      _selectedCard = null;
                    });
                  },
                ),
                children: [
                  // 地图瓦片层（使用OpenStreetMap）
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.ai_poetry_card',
                  ),
                  // 标记层
                  MarkerLayer(markers: markers),
                ],
              ),

              // 统计信息卡片
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _buildStatsCard(cardsWithLocation),
              ),

              // 选中的卡片详情
              if (_selectedCard != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildSelectedCardInfo(_selectedCard!),
                ),
            ],
          );
        },
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n('暂无足迹记录'),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n('生成卡片时会自动记录位置'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计信息卡片
  Widget _buildStatsCard(List<PoetryCard> cards) {
    // 统计唯一位置数量
    final uniqueLocations = <String>{};
    for (var card in cards) {
      if (card.nearbyPlaces != null && card.nearbyPlaces!.isNotEmpty) {
        final location = card.nearbyPlaces!.first;
        uniqueLocations.add('${location.location}');
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.location_on,
            uniqueLocations.length.toString(),
            context.l10n('个足迹'),
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
          ),
          _buildStatItem(
            Icons.article,
            cards.length.toString(),
            context.l10n('篇创作'),
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建地图标记
  List<Marker> _buildMarkers(List<PoetryCard> cards) {
    final markers = <Marker>[];

    for (var card in cards) {
      if (card.nearbyPlaces == null || card.nearbyPlaces!.isEmpty) continue;

      final location = card.nearbyPlaces!.first;
      final coords = location.location.split(',');
      if (coords.length != 2) continue;

      try {
        final lng = double.parse(coords[0]);
        final lat = double.parse(coords[1]);

        markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCard = card;
                });
                // 将地图中心移动到选中的标记
                _mapController.move(LatLng(lat, lng), 14.0);
              },
              child: Icon(
                Icons.location_on,
                color: _selectedCard?.id == card.id
                    ? AppTheme.primaryColor
                    : Colors.red,
                size: 40,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      } catch (e) {
        print('解析位置坐标失败: $e');
      }
    }

    return markers;
  }

  /// 计算地图中心点
  LatLng _calculateCenter(List<PoetryCard> cards) {
    if (cards.isEmpty) {
      return LatLng(39.9042, 116.4074); // 默认北京
    }

    double totalLat = 0;
    double totalLng = 0;
    int count = 0;

    for (var card in cards) {
      if (card.nearbyPlaces == null || card.nearbyPlaces!.isEmpty) continue;

      final location = card.nearbyPlaces!.first;
      final coords = location.location.split(',');
      if (coords.length != 2) continue;

      try {
        final lng = double.parse(coords[0]);
        final lat = double.parse(coords[1]);
        totalLat += lat;
        totalLng += lng;
        count++;
      } catch (e) {
        // 忽略解析错误
      }
    }

    if (count == 0) {
      return LatLng(39.9042, 116.4074);
    }

    return LatLng(totalLat / count, totalLng / count);
  }

  /// 构建选中卡片的信息卡片
  Widget _buildSelectedCardInfo(PoetryCard card) {
    return GestureDetector(
      onTap: () {
        // 跳转到卡片详情页
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardDetailScreen(
              card: card,
              isResultMode: false,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card.nearbyPlaces!.first.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() {
                      _selectedCard = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              card.poetry,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _formatDate(card.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  context.l10n('点击查看详情'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${context.l10n('天前')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${context.l10n('小时前')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${context.l10n('分钟前')}';
    } else {
      return context.l10n('刚刚');
    }
  }
}
