import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// 位置信息模型
class LocationInfo {
  final double latitude;
  final double longitude;
  final String? address;
  final double? accuracy;
  final DateTime timestamp;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    this.address,
    this.accuracy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'accuracy': accuracy,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() =>
      'LocationInfo(lat: $latitude, lng: $longitude, address: $address)';
}

/// 位置服务
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  LocationInfo? _lastLocation;
  Future<LocationInfo?>? _currentRequest;

  /// 获取当前位置
  Future<LocationInfo?> getCurrentLocation() async {
    // 如果有正在进行的请求，复用它
    if (_currentRequest != null) {
      print('📍 复用正在进行的位置获取请求...');
      return _currentRequest!;
    }

    // 创建新的请求
    _currentRequest = _getLocationInternal();
    final result = await _currentRequest!;
    _currentRequest = null;
    return result;
  }

  /// 内部位置获取方法
  Future<LocationInfo?> _getLocationInternal() async {
    try {
      print('📍 开始获取位置信息...');

      // 检查位置权限
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        print('位置权限被拒绝');
        return null;
      }

      // 检查位置服务是否启用
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        print('位置服务未启用');
        return null;
      }

      // 获取位置
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('📍 获取到位置: ${position.latitude}, ${position.longitude}');

      // 获取地址信息（可选）
      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          address =
              '${placemark.country} ${placemark.administrativeArea} ${placemark.locality}';
        }
      } catch (e) {
        print('⚠️ 获取地址信息失败: $e');
      }

      _lastLocation = LocationInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );

      print('✅ 位置信息获取成功: $_lastLocation');
      return _lastLocation;
    } catch (e) {
      print('❌ 获取位置信息失败: $e');
      return null;
    }
  }

  /// 检查位置权限
  Future<bool> _checkLocationPermission() async {
    try {
      // 检查权限状态
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // 请求权限
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('位置权限被拒绝');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('位置权限被永久拒绝，需要手动开启');
        return false;
      }

      print('位置权限已授予');
      return true;
    } catch (e) {
      print('检查位置权限失败: $e');
      return false;
    }
  }

  /// 获取最后已知位置
  LocationInfo? getLastLocation() => _lastLocation;

  /// 清除位置缓存
  void clearLocationCache() {
    _lastLocation = null;
    print('位置缓存已清除');
  }

  /// 检查位置服务是否可用
  Future<bool> isLocationServiceAvailable() async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      final hasPermission = await _checkLocationPermission();
      return isServiceEnabled && hasPermission;
    } catch (e) {
      print('检查位置服务可用性失败: $e');
      return false;
    }
  }

  /// 获取位置权限状态
  Future<LocationPermission> getLocationPermissionStatus() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      print('获取位置权限状态失败: $e');
      return LocationPermission.denied;
    }
  }

  /// 打开位置设置
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      print('打开位置设置失败: $e');
    }
  }

  /// 打开应用设置
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('打开应用设置失败: $e');
    }
  }
}
