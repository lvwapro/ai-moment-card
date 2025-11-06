import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 上传状态
enum UploadStatus { idle, picking, uploading, success, failed }

/// 腾讯云COS图片上传服务
class CosUploadService {
  // 单例模式
  static CosUploadService? _instance;
  static CosUploadService get instance {
    _instance ??= CosUploadService._internal();
    return _instance!;
  }

  CosUploadService._internal();

  // 配置信息
  static const String _bucket = "apk-1251046496";
  static const String _region = "ap-guangzhou";
  static const String _cosPath = "ptw";

  // 从 .env 文件或环境变量获取敏感信息
  static String get _secretId {
    // 优先从 .env 文件获取
    final envValue = dotenv.env['SECRET_ID_TX'];
    if (envValue != null &&
        envValue.isNotEmpty &&
        envValue != 'YOUR_SECRET_ID_HERE') {
      return envValue;
    }

    // 回退到环境变量
    return const String.fromEnvironment(
      'SECRET_ID_TX',
      defaultValue: 'YOUR_SECRET_ID_HERE',
    );
  }

  static String get _secretKey {
    // 优先从 .env 文件获取
    final envValue = dotenv.env['TENCENT_SECRET_KEY'];
    if (envValue != null &&
        envValue.isNotEmpty &&
        envValue != 'YOUR_SECRET_KEY_HERE') {
      return envValue;
    }

    // 回退到环境变量
    return const String.fromEnvironment(
      'TENCENT_SECRET_KEY',
      defaultValue: 'YOUR_SECRET_KEY_HERE',
    );
  }

  bool _isInitialized = false;

  /// 公共初始化方法 - 在应用启动时调用一次
  static Future<void> initialize() async {
    await instance._initCosService();
  }

  /// 初始化COS服务
  Future<void> _initCosService() async {
    if (_isInitialized) return;

    try {
      // 1. 初始化密钥
      await Cos().initWithPlainSecret(_secretId, _secretKey);

      // 2. 注册 COS 服务
      // 创建 CosXmlServiceConfig 对象，根据需要修改默认的配置参数
      CosXmlServiceConfig serviceConfig = CosXmlServiceConfig(
        region: _region,
        isDebuggable: true,
        isHttps: true,
      );

      // 注册默认 COS Service
      await Cos().registerDefaultService(serviceConfig);

      // 创建 TransferConfig 对象，根据需要修改默认的配置参数
      TransferConfig transferConfig = TransferConfig(
        forceSimpleUpload: false,
        enableVerification: true,
        divisionForUpload: 2097152, // 设置大于等于 2M 的文件进行分块上传
        sliceSizeForUpload: 1048576, //设置默认分块大小为 1M
      );

      // 注册默认 COS TransferManger
      await Cos().registerDefaultTransferManger(serviceConfig, transferConfig);

      _isInitialized = true;
    } catch (e) {
      throw Exception('初始化COS服务失败: $e');
    }
  }

  /// 上传文件
  Future<Map<String, dynamic>> uploadFile({
    required String filePath,
    Function(UploadStatus)? onStatus,
    Function(int completed, int total)? onProgress,
  }) async {
    try {
      print('开始上传文件: $filePath');
      onStatus?.call(UploadStatus.uploading);
      // 确保服务已初始化
      if (!_isInitialized) {
        throw Exception('COS服务未初始化，请先调用 CosUploadService.initialize()');
      }
      // 检查文件
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在');
      }

      final fileSize = await file.length();
      if (fileSize > 50 * 1024 * 1024) {
        throw Exception('文件大小不能超过10MB');
      }

      /// 获取文件扩展名
      String getFileExtension(String path) =>
          path.split('.').last.toLowerCase();

      // 生成唯一文件名
      final extension = getFileExtension(filePath);

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}.$extension';
      final objectKey = '$_cosPath$fileName';
      // 获取传输管理器
      final transferManager = Cos().getDefaultTransferManger();

      // 执行上传
      final completer = Completer<String>();
      // 上传成功回调
      void successCallBack(
          Map<String?, String?>? header, CosXmlResult? result) {
        final imageUrl =
            'https://$_bucket.cos.$_region.myqcloud.com/$objectKey';
        completer.complete(imageUrl);
      }

      // 上传失败回调
      void failCallBack(CosXmlClientException? clientException,
          CosXmlServiceException? serviceException) {
        String error = '上传失败';
        if (clientException != null)
          error += ': ${clientException.message ?? clientException.errorCode}';
        if (serviceException != null)
          error +=
              ': ${serviceException.errorMessage ?? serviceException.statusCode}';
        completer.completeError(Exception(error));
      }

      // 上传进度回调
      void progressCallBack(int complete, int total) {
        onProgress?.call(complete, total);
      }

      // 开始上传
      await transferManager.upload(
        _bucket,
        objectKey,
        filePath: file.path,
        resultListener: ResultListener(successCallBack, failCallBack),
        progressCallBack: progressCallBack,
      );

      final String imageUrl = await completer.future;
      onStatus?.call(UploadStatus.success);

      return {
        'success': true,
        'url': imageUrl,
        'objectKey': objectKey,
        'fileSize': fileSize,
        'fileName': fileName,
      };
    } catch (e) {
      onStatus?.call(UploadStatus.failed);
      return {
        'success': false,
        'error': '上传失败: $e',
        'filePath': filePath,
      };
    }
  }
}
