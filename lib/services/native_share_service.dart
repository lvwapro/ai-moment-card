import 'dart:io';
import 'package:flutter/services.dart';
import 'gallery_service.dart';

/// 原生分享服务
/// 使用原生方法分享，避免插件蒙层问题
/// 使用 gal 插件管理相册保存功能
class NativeShareService {
  static const MethodChannel _channel = MethodChannel('native_share');

  /// 分享图片文件
  static Future<bool> shareImage(String imagePath) async {
    try {
      if (Platform.isIOS) {
        return await _shareImageIOS(imagePath);
      } else if (Platform.isAndroid) {
        return await _shareImageAndroid(imagePath);
      } else {
        print('不支持的平台: ${Platform.operatingSystem}');
        return false;
      }
    } catch (e) {
      print('原生分享失败: $e');
      return false;
    }
  }

  /// iOS 原生分享
  static Future<bool> _shareImageIOS(String imagePath) async {
    try {
      final result = await _channel.invokeMethod('shareImage', {
        'imagePath': imagePath,
        'subject': '我的诗意瞬间',
      });
      return result == true;
    } catch (e) {
      print('iOS 原生分享失败: $e');
      return false;
    }
  }

  /// Android 原生分享
  static Future<bool> _shareImageAndroid(String imagePath) async {
    try {
      final result = await _channel.invokeMethod('shareImage', {
        'imagePath': imagePath,
        'subject': '我的诗意瞬间',
      });
      return result == true;
    } catch (e) {
      print('Android 原生分享失败: $e');
      return false;
    }
  }

  /// 保存图片到相册
  /// 使用 gal 插件管理相册权限和保存功能
  static Future<bool> saveImageToGallery(String imagePath) async {
    try {
      return await GalleryService.instance.saveImage(imagePath, useAlbum: true);
    } catch (e) {
      print('保存图片失败: $e');
      return false;
    }
  }

  /// 检查相册访问权限
  static Future<bool> hasGalleryAccess() =>
      GalleryService.instance.hasAccess(toAlbum: true);

  /// 请求相册访问权限
  static Future<bool> requestGalleryAccess() =>
      GalleryService.instance.requestAccess(toAlbum: true);

  /// 打开系统相册
  static Future<bool> openGallery() => GalleryService.instance.openGallery();
}
