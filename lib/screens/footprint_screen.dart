import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:math' as math;
import '../models/poetry_card.dart';
import '../providers/history_manager.dart';
import '../services/language_service.dart';
import '../widgets/footprint/footprint_marker_builder.dart';
import '../widgets/footprint/footprint_clusterer.dart';
import '../widgets/footprint/footprint_stats_card.dart';
import '../widgets/footprint/footprint_selected_cards_info.dart';
import '../widgets/footprint/footprint_empty_state.dart';

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
  double _currentZoom = 12.0; // 当前缩放级别

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
              return const FootprintEmptyState();
            }

            // 按地点分组卡片
            final groupedCards =
                FootprintClusterer.groupCardsByLocation(cardsWithLocation);

            // 聚合并构建标记
            final clusters = FootprintClusterer.clusterMarkers(
              groupedCards: groupedCards,
              currentZoom: _currentZoom,
            );

            final markers = FootprintMarkerBuilder.buildMarkers(
              clusters: clusters,
              selectedLocationKey: _selectedLocationKey,
              currentZoom: _currentZoom,
              onMarkerTap: (cards, id) {
                setState(() {
                  _selectedCards = cards;
                  _selectedLocationKey = id;
                });

                // 找到被点击的聚合
                final cluster = clusters.firstWhere((c) => c.id == id);

                // 智能缩放和移动
                _moveToCluster(cluster);
              },
            );

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
                          // 更新当前缩放级别，触发重新聚合
                          setState(() {
                            _currentZoom = _mapController.camera.zoom;
                          });
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
                    child: FootprintStatsCard(cards: cardsWithLocation),
                  ),

                  // 选中的卡片详情
                  if (_selectedCards != null && _selectedCards!.isNotEmpty)
                    Positioned(
                      bottom: 100, // 调整位置，避免被导航栏遮挡
                      left: 16,
                      right: 16,
                      child: FootprintSelectedCardsInfo(
                        cards: _selectedCards!,
                        onClose: () {
                          setState(() {
                            _selectedCards = null;
                            _selectedLocationKey = null;
                          });
                        },
                      ),
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
        text: context.l10n('我的足迹地图 - 拾光记'),
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

  /// 智能移动到聚合点（带缩放和动画）
  void _moveToCluster(ClusterMarker cluster) {
    // 判断是否需要放大
    double targetZoom = _currentZoom;

    // 如果是聚合点（多个不同位置）
    if (cluster.locationKeys.length > 1) {
      // 聚合点需要放大以展开查看
      if (_currentZoom < 15) {
        targetZoom = 15.0; // 放大到高缩放级别
      } else {
        targetZoom = math.min(_currentZoom + 2, 18.0); // 在当前基础上再放大
      }
    }
    // 如果是单个位置但缩放级别较低
    else if (_currentZoom < 14) {
      targetZoom = 15.0; // 放大到合适的查看级别
    }
    // 如果是单个位置且已经在高缩放级别
    else {
      // 保持当前缩放级别，只移动到中心
      targetZoom = _currentZoom;
    }

    // 使用动画移动到目标位置和缩放级别
    _mapController.move(cluster.center, targetZoom);

    // 延迟更新缩放级别状态，避免立即触发重新聚合
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _currentZoom = targetZoom;
        });
      }
    });
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

  /// 获取地图URL（根据语言切换）
  String _getMapUrl() {
    final currentLang = LanguageService.to.getCurrentLanguage();

    if (currentLang == 'zh') {
      // 中文使用高德地图（高清晰度，scale=2）
      return 'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=10&style=8&x={x}&y={y}&z={z}';
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
    // 中文和英文地图都启用 retina 模式以获得更清晰的显示
    return true;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
