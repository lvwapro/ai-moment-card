import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// 原生分享服务
/// 使用原生方法分享，避免插件蒙层问题
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
  static Future<bool> saveImageToGallery(String imagePath) async {
    try {
      if (Platform.isIOS) {
        return await _saveImageToGalleryIOS(imagePath);
      } else if (Platform.isAndroid) {
        return await _saveImageToGalleryAndroid(imagePath);
      } else {
        print('不支持的平台: ${Platform.operatingSystem}');
        return false;
      }
    } catch (e) {
      print('保存图片失败: $e');
      return false;
    }
  }

  /// iOS 保存到相册
  static Future<bool> _saveImageToGalleryIOS(String imagePath) async {
    try {
      final result = await _channel.invokeMethod('saveImageToGallery', {
        'imagePath': imagePath,
      });
      return result == true;
    } catch (e) {
      print('iOS 保存图片失败: $e');
      return false;
    }
  }

  /// Android 保存到相册
  static Future<bool> _saveImageToGalleryAndroid(String imagePath) async {
    try {
      final result = await _channel.invokeMethod('saveImageToGallery', {
        'imagePath': imagePath,
      });
      return result == true;
    } catch (e) {
      print('Android 保存图片失败: $e');
      return false;
    }
  }
}
