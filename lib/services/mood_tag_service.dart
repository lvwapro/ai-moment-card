import 'dart:convert';
import 'package:http/http.dart' as http;

/// 情绪标签服务
class MoodTagService {
  static final MoodTagService _instance = MoodTagService._internal();
  factory MoodTagService() => _instance;
  MoodTagService._internal();

  static const String _baseUrl = 'https://a.mostsnews.com/api/map/mood-tags';

  /// 根据经纬度获取情绪标签
  ///
  /// [longitude] 经度
  /// [latitude] 纬度
  /// [radius] 半径（米），默认1000米
  Future<MoodTagResponse?> getMoodTags({
    required double longitude,
    required double latitude,
    int radius = 1000,
  }) async {
    try {
      print('🎭 开始获取情绪标签...');
      print('📍 经度: $longitude, 纬度: $latitude, 半径: ${radius}米');

      final url = Uri.parse(
        '$_baseUrl?longitude=$longitude&latitude=$latitude&radius=$radius',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('请求超时');
        },
      );

      print('📡 响应状态: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ 情绪标签获取成功');

        if (jsonData['success'] == true) {
          final result = MoodTagResponse.fromJson(jsonData);
          print('🎭 标签数量: ${result.moodTags.length}');
          print('🏷️ 标签列表: ${result.moodTags.join(', ')}');
          return result;
        } else {
          print('❌ API返回失败: ${jsonData['message']}');
          return null;
        }
      } else {
        print('❌ 请求失败，状态码: ${response.statusCode}');
        throw Exception('请求失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 获取情绪标签失败: $e');
      rethrow; // 继续抛出异常，让外层处理
    }
  }
}

/// 情绪标签响应数据模型
class MoodTagResponse {
  final LocationInfo location;
  final List<String> moodTags;
  final int timestamp;

  MoodTagResponse({
    required this.location,
    required this.moodTags,
    required this.timestamp,
  });

  factory MoodTagResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return MoodTagResponse(
      location: LocationInfo.fromJson(data['location']),
      moodTags: List<String>.from(data['moodTags']),
      timestamp: data['timestamp'],
    );
  }
}

/// 位置信息
class LocationInfo {
  final String name;
  final String address;
  final String type;
  final String distance;
  final Coordinates coordinates;

  LocationInfo({
    required this.name,
    required this.address,
    required this.type,
    required this.distance,
    required this.coordinates,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      name: json['name'],
      address: json['address'],
      type: json['type'],
      distance: json['distance'],
      coordinates: Coordinates.fromJson(json['coordinates']),
    );
  }
}

/// 坐标信息
class Coordinates {
  final double longitude;
  final double latitude;

  Coordinates({
    required this.longitude,
    required this.latitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }
}
