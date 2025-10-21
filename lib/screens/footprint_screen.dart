import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'dart:io';
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
  late final MapController _mapController;
  List<PoetryCard>? _selectedCards; // 改为列表，支持显示同一地点的多个卡片
  String? _selectedLocationKey; // 记录选中的地点
  final GlobalKey _mapKey = GlobalKey(); // 用于截图
  bool _isSharing = false; // 分享状态
  bool _isAdjusting = false; // 防止递归调整

  // 自定义地图边界
  // 使用更保守的边界值，避免地图在极地附近严重变形
  final double minLatitude = -80.0;
  final double maxLatitude = 80.0;
  // 左右边界，覆盖全球主要区域
  final double minLongitude = -170.0;
  final double maxLongitude = 170.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  // 修正地图边界（上下限制 + 左右循环）
  void _adjustMapBounds() {
    // 如果正在调整，先重置标志，允许新的调整
    if (_isAdjusting) {
      _isAdjusting = false;
    }

    try {
      final camera = _mapController.camera;
      final LatLng currentCenter = camera.center;

      // 获取地图的可视边界
      final bounds = camera.visibleBounds;

      // 1. 修正纬度（上下边界限制）
      double adjustedLat = currentCenter.latitude;
      bool needAdjust = false;

      // 检查可视区域的南边界
      if (bounds.south < minLatitude) {
        // 计算需要向上移动多少
        final double offset = minLatitude - bounds.south;
        adjustedLat = currentCenter.latitude + offset;
        needAdjust = true;
      }
      // 检查可视区域的北边界
      else if (bounds.north > maxLatitude) {
        // 计算需要向下移动多少
        final double offset = bounds.north - maxLatitude;
        adjustedLat = currentCenter.latitude - offset;
        needAdjust = true;
      }

      // 2. 修正经度（左右边界限制）
      double adjustedLng = currentCenter.longitude;

      // 检查可视区域的西边界
      if (bounds.west < minLongitude) {
        // 计算需要向右移动多少
        final double offset = minLongitude - bounds.west;
        adjustedLng = currentCenter.longitude + offset;
        needAdjust = true;
      }
      // 检查可视区域的东边界
      else if (bounds.east > maxLongitude) {
        // 计算需要向左移动多少
        final double offset = bounds.east - maxLongitude;
        adjustedLng = currentCenter.longitude - offset;
        needAdjust = true;
      }

      // 如果需要调整，更新地图位置
      if (needAdjust) {
        _isAdjusting = true;
        _mapController.move(LatLng(adjustedLat, adjustedLng), camera.zoom);
        // 使用 Future.delayed 重置标志，时间缩短以支持快速拖动
        Future.delayed(const Duration(milliseconds: 50), () {
          _isAdjusting = false;
        });
      }
    } catch (e) {
      _isAdjusting = false;
      print('调整地图边界失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            context.l10n('我的足迹'),
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          actions: [
            // 分享按钮
            Consumer<HistoryManager>(
              builder: (context, historyManager, child) {
                final cardsWithLocation = historyManager.cards
                    .where((card) => card.selectedPlace != null)
                    .toList();

                // 只有有足迹时才显示分享按钮
                if (cardsWithLocation.isEmpty) {
                  return const SizedBox.shrink();
                }

                return IconButton(
                  icon: _isSharing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.ios_share),
                  onPressed: _isSharing ? null : _shareFootprint,
                );
              },
            ),
          ],
        ),
        body: Consumer<HistoryManager>(
          builder: (context, historyManager, child) {
            // 获取所有有位置信息的卡片
            final cardsWithLocation = historyManager.cards
                .where((card) => card.selectedPlace != null)
                .toList();

            if (cardsWithLocation.isEmpty) {
              return _buildEmptyState();
            }

            // 按地点分组卡片
            final groupedCards = _groupCardsByLocation(cardsWithLocation);

            // 提取所有位置点
            final markers = _buildMarkers(groupedCards);

            // 计算地图中心点和缩放级别
            final center = _calculateCenter(cardsWithLocation);

            return RepaintBoundary(
              key: _mapKey,
              child: Stack(
                children: [
                  // 地图 - 使用 flutter_map，不支持旋转
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 12.0,
                      minZoom: 3.0,
                      maxZoom: 18.0,
                      // 禁用旋转功能，只允许缩放和拖拽
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                      ),
                      onTap: (_, __) {
                        setState(() {
                          _selectedCards = null;
                          _selectedLocationKey = null;
                        });
                      },
                      // 监听地图事件，在拖动结束后调整边界
                      onMapEvent: (MapEvent event) {
                        if (event is MapEventMoveEnd) {
                          _adjustMapBounds();
                        }
                      },
                    ),
                    children: [
                      // 地图瓦片层（根据语言动态切换）
                      TileLayer(
                        urlTemplate: _getMapUrl(),
                        subdomains: _getMapSubdomains(),
                        userAgentPackageName: 'com.qualrb.aiPoetryCard',
                        tileSize: 256,
                        retinaMode: _getRetinaMode(),
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
                  if (_selectedCards != null && _selectedCards!.isNotEmpty)
                    Positioned(
                      bottom: 100, // 调整位置，避免被导航栏遮挡
                      left: 16,
                      right: 16,
                      child: _buildSelectedCardsInfo(_selectedCards!),
                    ),
                ],
              ),
            );
          },
        ),
      );

  /// 分享足迹地图
  Future<void> _shareFootprint() async {
    setState(() {
      _isSharing = true;
    });

    try {
      // 等待一帧以确保UI更新完成
      await Future.delayed(const Duration(milliseconds: 100));

      // 获取RepaintBoundary
      final boundary =
          _mapKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('无法获取地图渲染对象');
      }

      // 截图（提高像素比例以获得更清晰的图片）
      final image = await boundary.toImage(pixelRatio: 4.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('无法生成图片');
      }

      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/footprint_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // 分享
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: context.l10n('我的足迹地图 - 迹见文案'),
      );

      // 分享完成后删除临时文件
      if (result.status == ShareResultStatus.success) {
        try {
          await file.delete();
        } catch (e) {
          print('删除临时文件失败: $e');
        }
      }
    } catch (e) {
      print('分享失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n('分享失败，请重试')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  /// 构建空状态
  Widget _buildEmptyState() => Center(
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

  /// 构建统计信息卡片
  Widget _buildStatsCard(List<PoetryCard> cards) {
    // 统计唯一位置数量
    final uniqueLocations = <String>{};
    for (var card in cards) {
      if (card.selectedPlace != null) {
        final location = card.selectedPlace!;
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
  Widget _buildStatItem(IconData icon, String value, String label) => Row(
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

  /// 按地点分组卡片
  Map<String, List<PoetryCard>> _groupCardsByLocation(List<PoetryCard> cards) {
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

  /// 构建地图标记
  List<Marker> _buildMarkers(Map<String, List<PoetryCard>> groupedCards) {
    final markers = <Marker>[];

    groupedCards.forEach((locationKey, cards) {
      if (cards.isEmpty) return;

      final location = cards.first.selectedPlace!;
      final coords = location.location.split(',');
      if (coords.length != 2) return;

      try {
        final lng = double.parse(coords[0]);
        final lat = double.parse(coords[1]);

        // 检查该地点是否被选中
        final isSelected = _selectedLocationKey == locationKey;

        markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCards = cards; // 设置该地点的所有卡片
                  _selectedLocationKey = locationKey;
                });
                // 将地图中心移动到选中的标记
                _mapController.move(LatLng(lat, lng), 14.0);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: isSelected ? Colors.red : AppTheme.primaryColor,
                    size: 40,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  // 如果有多个卡片，显示数量
                  if (cards.length > 1)
                    Positioned(
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.red : AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cards.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      } catch (e) {
        print('解析位置坐标失败: $e');
      }
    });

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
      if (card.selectedPlace == null) continue;

      final location = card.selectedPlace!;
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

  /// 构建选中卡片的信息卡片（支持多个卡片）
  Widget _buildSelectedCardsInfo(List<PoetryCard> cards) {
    if (cards.isEmpty) return const SizedBox.shrink();

    final locationName = cards.first.selectedPlace!.name;

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
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
          // 位置信息和关闭按钮
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
                  cards.length > 1
                      ? '$locationName (${cards.length}篇)'
                      : locationName,
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
                    _selectedCards = null;
                    _selectedLocationKey = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 卡片列表
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: cards.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final card = cards[index];
                return GestureDetector(
                  onTap: () {
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 获取地图URL（根据语言切换）
  String _getMapUrl() {
    final currentLang = LanguageService.to.getCurrentLanguage();

    if (currentLang == 'zh') {
      // 中文使用高德地图
      return 'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}';
    } else {
      // 英文使用 CartoDB Voyager（清晰的英文地图）
      return 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
    }
  }

  /// 获取地图子域名
  List<String> _getMapSubdomains() {
    final currentLang = LanguageService.to.getCurrentLanguage();

    if (currentLang == 'zh') {
      return ['1', '2', '3', '4']; // 高德地图子域名
    } else {
      return ['a', 'b', 'c', 'd']; // CartoDB 子域名
    }
  }

  /// 获取 Retina 模式设置
  bool _getRetinaMode() {
    final currentLang = LanguageService.to.getCurrentLanguage();

    // 只有英文地图（CartoDB）需要 retina 模式
    return currentLang != 'zh';
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

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
