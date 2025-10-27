import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_service.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  late Dio _dio;

  // 环境配置
  // 如果域名无法解析，可以尝试使用 IP 地址
  String get baseUrl => 'https://a.mostsnews.com/';
  // String get baseUrl => 'https://104.21.72.208/'; // 备用 IP（需要配置 Host header）

  // 认证信息
  String? _token;
  String? _bundleId;
  String? _deviceId;

  // 加密密钥
  static const String _secretKey = 'toodan@2025bc!';

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加拦截器
    _dio.interceptors.add(LogInterceptor(
      requestBody: kDebugMode,
      responseBody: kDebugMode,
      logPrint: (object) => print('$object'),
    ));

    // 添加拦截器
    _dio.interceptors.add(LogInterceptor(
      requestBody: kDebugMode,
      responseBody: kDebugMode,
      logPrint: (object) => print('$object'),
    ));

    // 添加认证拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 自动添加认证头
        if (_token != null && _bundleId != null && _deviceId != null) {
          options.headers['token'] = _token;
          options.headers['bundle-id'] = _bundleId;
          options.headers['device-id'] = _deviceId;
        }

        // 添加语言头
        final locale = _getCurrentLocale();
        options.headers['Accept-Language'] = locale;

        // 添加平台头
        final platform = _getCurrentPlatform();
        options.headers['platform'] = platform;

        handler.next(options);
      },
    ));
  }

  // 获取当前平台
  String _getCurrentPlatform() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    }
    return 'unknown';
  }

  // 获取当前语言设置
  String _getCurrentLocale() {
    try {
      // 使用应用内设置的语言，而不是系统语言
      return LanguageService.to.getCurrentLanguage();
    } catch (e) {
      print('获取语言设置失败: $e');
      return 'en';
    }
  }

  // 设置认证信息
  void setAuthInfo(String token, String bundleId, String deviceId) {
    _token = token;
    _bundleId = bundleId;
    _deviceId = deviceId;
    print(' 认证信息已设置: bundleId=$bundleId, deviceId=$deviceId');
  }

  // 获取设备ID - 真实设备ID + bundleId 进行MD5哈希
  Future<String> getDeviceId() async {
    try {
      String realDeviceId = 'unknown';

      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        realDeviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        realDeviceId = iosInfo.identifierForVendor ?? 'unknown';
      }

      // 获取bundleId
      final bundleId = await getBundleId();

      // 组合真实设备ID和bundleId
      final combinedId = '$realDeviceId$bundleId';

      // 进行MD5哈希并转为小写32位
      final bytes = utf8.encode(combinedId);
      final digest = md5.convert(bytes);
      final deviceId = digest.toString();

      print('真实设备ID: $realDeviceId');
      print('Bundle ID: $bundleId');
      print('组合ID: $combinedId');
      print('MD5哈希后设备ID: $deviceId');

      return deviceId;
    } catch (e) {
      print('获取设备ID失败: $e');
      return 'unknown';
    }
  }

  // 获取Bundle ID
  Future<String> getBundleId() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.packageName;
    } catch (e) {
      print('获取Bundle ID失败: $e');
      return 'com.qualrb.aiPoetry';
    }
  }

  // 生成Token
  Future<String?> generateToken() async {
    try {
      final bundleId = await getBundleId();
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000; // 秒级时间戳

      print('正在生成Token...');
      print('Bundle ID: $bundleId');
      print('Timestamp: $timestamp');

      // 按照 bundle-id-timestamp-toodan 格式生成内容
      final content = '$bundleId-$timestamp-toodan';
      print('Token内容: $content');

      // 使用SHA256哈希密钥，与Node.js保持一致
      final keyBytes = utf8.encode(_secretKey);
      final hashedKey = sha256.convert(keyBytes);

      // 使用AES-256-ECB加密
      final key = encrypt.Key(Uint8List.fromList(hashedKey.bytes));
      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));

      final encrypted = encrypter.encrypt(content);
      final token = encrypted.base16; // 使用hex格式，与Node.js一致

      print('Token生成成功: $token');
      return token;
    } catch (e) {
      print('Token生成异常: $e');
      return null;
    }
  }

  // 保存deviceId到本地
  Future<void> saveDeviceId(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_id', deviceId);
      print('DeviceId已保存: $deviceId');
    } catch (e) {
      print('保存DeviceId失败: $e');
    }
  }

  // 获取本地保存的deviceId
  Future<String?> getSavedDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('device_id');
    } catch (e) {
      print('获取DeviceId失败: $e');
      return null;
    }
  }

  // 初始化认证信息
  Future<bool> initializeAuth() async {
    try {
      // 首先初始化 Dio 实例
      init();

      final bundleId = await getBundleId();
      final deviceId = await getDeviceId();
      final token = await generateToken();

      if (token != null) {
        setAuthInfo(token, bundleId, deviceId);
        // 保存deviceId到本地
        await saveDeviceId(deviceId);
        return true;
      } else {
        print('Token生成失败');
        return false;
      }
    } catch (e) {
      print('认证初始化失败: $e');
      return false;
    }
  }

  // GET 请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // POST 请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      // 确保 Content-Type 始终被设置
      final mergedOptions = options ?? Options();
      mergedOptions.contentType = Headers.jsonContentType;

      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: mergedOptions,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // PUT 请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // DELETE 请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        print('连接超时');
        break;
      case DioExceptionType.sendTimeout:
        print('发送超时');
        break;
      case DioExceptionType.receiveTimeout:
        print('接收超时');
        break;
      case DioExceptionType.badResponse:
        print('服务器错误: ${e.response?.statusCode}');
        break;
      case DioExceptionType.cancel:
        print('请求取消');
        break;
      case DioExceptionType.connectionError:
        print('连接错误');
        break;
      default:
        print('未知错误: ${e.message}');
    }
  }

  // 获取附近地点（公共API，不需要认证头）
  Future<Map<String, dynamic>?> getNearbyPlaces({
    required double longitude,
    required double latitude,
    int radius = 1000,
  }) async {
    try {
      print('🗺️ 开始获取附近地点: ($longitude, $latitude, radius=$radius)');

      // 创建独立的Dio实例，不带认证头
      final publicDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => true,
      ));

      final response = await publicDio.get(
        'https://a.mostsnews.com/api/map/nearby',
        queryParameters: {
          'longitude': longitude,
          'latitude': latitude,
          'radius': radius,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          print('✅ 获取附近地点成功');
          return data;
        } else {
          print('⚠️ 获取附近地点失败: ${data['message']}');
          return null;
        }
      } else {
        print('⚠️ 获取附近地点失败 - HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ 获取附近地点异常: ${e.toString().split('\n').first}');
      return null;
    }
  }

  // 获取VIP状态（需要认证头）
  Future<Response?> getVipStatus() async {
    try {
      final bundleId = await getBundleId();
      final deviceId = await getDeviceId();
      final token = await generateToken();

      if (token == null) {
        print('❌ Token生成失败');
        return null;
      }

      // 创建独立的 Dio 实例
      final dio = Dio(BaseOptions(
        baseUrl: 'https://a.mostsnews.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      // 构建完整的URL（带查询参数）
      final url = '/api/vip/status?bundleId=$bundleId&deviceId=$deviceId';

      print('📤 ========== 发送VIP请求 ==========');
      print('   完整URL: https://a.mostsnews.com$url');
      print('   Method: GET');
      print('   Headers:');
      print('      Content-Type: application/json');
      print('      token: $token');
      print('      bundle-id: $bundleId');
      print('      device-id: $deviceId');
      print('================================');

      // 发送请求，手动设置所有请求头
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'token': token,
            'bundle-id': bundleId,
            'device-id': deviceId,
          },
        ),
      );

      print('📥 ========== 收到VIP响应 ==========');
      print('   Status: ${response.statusCode}');
      print('   Data: ${response.data}');
      print('================================');

      return response;
    } catch (e) {
      print('❌ 获取VIP状态异常: $e');
      if (e is DioException) {
        print('   错误类型: ${e.type}');
        print('   响应状态: ${e.response?.statusCode}');
        print('   响应数据: ${e.response?.data}');
      }
      return null;
    }
  }
}
