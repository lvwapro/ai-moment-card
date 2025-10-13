import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/nearby_place.dart';
import '../theme/app_theme.dart';

/// 附近地点展示组件
class NearbyPlacesWidget extends StatelessWidget {
  final List<NearbyPlace> places;

  const NearbyPlacesWidget({super.key, required this.places});

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
                SizedBox(width: 8),
                Text('附近地点',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: places.length > 5 ? 5 : places.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildItem(context, places[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, NearbyPlace place) => InkWell(
        onTap: () => _openMap(context, place),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: place.photos.isNotEmpty
                ? Image.network(place.photos.first,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          title: Text(place.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(place.address,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(place.typeShort,
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.primaryColor)),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.directions_walk,
                      size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 2),
                  Text(place.distanceText,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  if (place.rating != null) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.star, size: 12, color: Colors.amber[600]),
                    const SizedBox(width: 2),
                    Text(place.rating!,
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios,
              color: AppTheme.primaryColor, size: 16),
        ),
      );

  Widget _placeholder() => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
        child: Icon(Icons.place, color: Colors.grey[400]),
      );

  /// 打开地图
  Future<void> _openMap(BuildContext context, NearbyPlace place) async {
    final coords = place.location.split(',');
    if (coords.length != 2) return;

    final lon = double.parse(coords[0]);
    final lat = double.parse(coords[1]);
    final name = Uri.encodeComponent(place.name);

    // 并行检测可用地图
    final maps = await Future.wait([
      _checkMap(
          '高德',
          Icons.map,
          const Color(0xFF0091FF),
          Platform.isIOS
              ? 'iosamap://viewMap?poiname=$name&lat=$lat&lon=$lon'
              : 'amapuri://viewMap?poiname=$name&lat=$lat&lon=$lon'),
      _checkMap(
          '百度',
          Icons.map,
          const Color(0xFF3385FF),
          Platform.isIOS
              ? 'baidumap://map/marker?location=$lat,$lon&title=$name'
              : 'bdapp://map/marker?location=$lat,$lon&title=$name'),
      _checkMap('腾讯', Icons.map, const Color(0xFF3EB575),
          'qqmap://map/marker?marker=coord:$lat,$lon;title:$name'),
    ]);

    final available = maps.whereType<MapApp>().toList();

    // 添加系统默认地图（总是可用）
    available.add(MapApp(
      name: Platform.isIOS ? 'Apple地图' : '浏览器',
      icon: Icons.map_outlined,
      color: const Color(0xFF007AFF),
      url: Uri.parse(Platform.isIOS
          ? 'http://maps.apple.com/?q=$name&ll=$lat,$lon'
          : 'https://www.google.com/maps/search/?api=1&query=$lat,$lon'),
    ));

    if (!context.mounted) return;

    // 只有一个直接打开，多个显示选择器
    if (available.length == 1) {
      launchUrl(available.first.url, mode: LaunchMode.externalApplication);
    } else {
      _showPicker(context, available, place.name);
    }
  }

  /// 检测地图
  Future<MapApp?> _checkMap(
      String name, IconData icon, Color color, String url) async {
    try {
      final uri = Uri.parse(url);
      return await canLaunchUrl(uri)
          ? MapApp(name: name, icon: icon, color: color, url: uri)
          : null;
    } catch (_) {
      return null;
    }
  }

  /// 显示选择器
  void _showPicker(BuildContext context, List<MapApp> maps, String placeName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('选择地图应用',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(placeName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          ...maps.map((m) => ListTile(
                leading: CircleAvatar(
                    backgroundColor: m.color.withOpacity(0.1),
                    child: Icon(m.icon, color: m.color, size: 22)),
                title: Text(m.name),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey[400]),
                onTap: () {
                  Navigator.pop(context);
                  launchUrl(m.url, mode: LaunchMode.externalApplication);
                },
              )),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48)),
                child: const Text('取消'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 地图应用
class MapApp {
  final String name;
  final IconData icon;
  final Color color;
  final Uri url;

  MapApp(
      {required this.name,
      required this.icon,
      required this.color,
      required this.url});
}
