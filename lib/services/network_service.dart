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
      connectTimeout: const Duration(seconds: 15), // 减少到15秒，更快失败
      receiveTimeout: const Duration(seconds: 60), // 接收数据超时保持60秒
      sendTimeout: const Duration(seconds: 30), // 发送超时减少到30秒
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

        handler.next(options);
      },
    ));
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
      return 'com.qualrb.texaswinrate';
    }
  }

  // 生成Token
  Future<String?> generateToken() async {
    try {
      final bundleId = await getBundleId();
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000; // 秒级时间戳

      // 按照 bundle-id-timestamp-toodan 格式生成内容
      final content = '$bundleId-$timestamp-toodan';

      // 使用SHA256哈希密钥，与Node.js保持一致
      final keyBytes = utf8.encode(_secretKey);
      final hashedKey = sha256.convert(keyBytes);

      // 使用AES-256-ECB加密
      final key = encrypt.Key(Uint8List.fromList(hashedKey.bytes));
      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));

      final encrypted = encrypter.encrypt(content);
      final token = encrypted.base16; // 使用hex格式，与Node.js一致

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

  // 测试网络连接（异步执行，不阻塞主流程）
  Future<bool> testConnection() async {
    try {
      await _dio.get(
        '',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (status) => status! < 500, // 4xx 也算成功，说明服务器可达
        ),
      );

      return true;
    } catch (e) {
      return false;
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

        // 异步测试网络连接，不等待结果（不阻塞初始化）
        testConnection();

        return true;
      } else {
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
}
