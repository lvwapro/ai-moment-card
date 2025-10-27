import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

/// 相册管理服务
/// 使用 gal 插件管理相册权限和保存功能
class GalleryService {
  GalleryService._();
  static final GalleryService instance = GalleryService._();

  /// 相册名称（可选，用于保存到特定相册）
  static const String albumName = '迹见文案';

  /// 检查是否有相册访问权限
  ///
  /// [toAlbum] - 是否检查保存到特定相册的权限
  /// 返回 true 表示有权限，false 表示没有权限
  Future<bool> hasAccess({bool toAlbum = false}) async {
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: toAlbum);
      debugPrint('相册访问权限检查: $hasAccess (toAlbum: $toAlbum)');
      return hasAccess;
    } catch (e) {
      debugPrint('检查相册权限失败: $e');
      return false;
    }
  }

  /// 请求相册访问权限
  ///
  /// [toAlbum] - 是否请求保存到特定相册的权限
  /// 返回 true 表示权限已授予，false 表示权限被拒绝
  Future<bool> requestAccess({bool toAlbum = false}) async {
    try {
      final granted = await Gal.requestAccess(toAlbum: toAlbum);
      debugPrint('相册权限请求结果: $granted (toAlbum: $toAlbum)');
      return granted;
    } catch (e) {
      debugPrint('请求相册权限失败: $e');
      return false;
    }
  }

  /// 保存图片到相册
  ///
  /// [imagePath] - 图片文件路径
  /// [useAlbum] - 是否保存到特定相册（默认 false）
  /// 返回 true 表示保存成功，false 表示保存失败
  Future<bool> saveImage(String imagePath, {bool useAlbum = false}) async {
    try {
      // 检查文件是否存在
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('图片文件不存在: $imagePath');
        return false;
      }

      // 检查权限
      final hasPermission = await hasAccess(toAlbum: useAlbum);
      if (!hasPermission) {
        // 请求权限
        final granted = await requestAccess(toAlbum: useAlbum);
        if (!granted) {
          debugPrint('用户拒绝了相册访问权限');
          return false;
        }
      }

      // 保存图片
      await Gal.putImage(
        imagePath,
        album: useAlbum ? albumName : null,
      );

      debugPrint('图片保存成功: $imagePath${useAlbum ? ' (相册: $albumName)' : ''}');
      return true;
    } on GalException catch (e) {
      debugPrint('保存图片失败 (GalException): ${e.type.message}');
      return false;
    } catch (e) {
      debugPrint('保存图片失败: $e');
      return false;
    }
  }

  /// 保存视频到相册
  ///
  /// [videoPath] - 视频文件路径
  /// [useAlbum] - 是否保存到特定相册（默认 false）
  /// 返回 true 表示保存成功，false 表示保存失败
  Future<bool> saveVideo(String videoPath, {bool useAlbum = false}) async {
    try {
      // 检查文件是否存在
      final file = File(videoPath);
      if (!await file.exists()) {
        debugPrint('视频文件不存在: $videoPath');
        return false;
      }

      // 检查权限
      final hasPermission = await hasAccess(toAlbum: useAlbum);
      if (!hasPermission) {
        // 请求权限
        final granted = await requestAccess(toAlbum: useAlbum);
        if (!granted) {
          debugPrint('用户拒绝了相册访问权限');
          return false;
        }
      }

      // 保存视频
      await Gal.putVideo(
        videoPath,
        album: useAlbum ? albumName : null,
      );

      debugPrint('视频保存成功: $videoPath${useAlbum ? ' (相册: $albumName)' : ''}');
      return true;
    } on GalException catch (e) {
      debugPrint('保存视频失败 (GalException): ${e.type.message}');
      return false;
    } catch (e) {
      debugPrint('保存视频失败: $e');
      return false;
    }
  }

  /// 打开系统相册
  ///
  /// 返回 true 表示打开成功，false 表示打开失败
  Future<bool> openGallery() async {
    try {
      await Gal.open();
      debugPrint('系统相册已打开');
      return true;
    } catch (e) {
      debugPrint('打开相册失败: $e');
      return false;
    }
  }

  /// 检查并请求权限（如果需要）
  ///
  /// [toAlbum] - 是否需要保存到特定相册的权限
  /// 返回 true 表示已有权限或权限请求成功，false 表示权限被拒绝
  Future<bool> ensureAccess({bool toAlbum = false}) async {
    final hasPermission = await hasAccess(toAlbum: toAlbum);
    if (hasPermission) {
      return true;
    }
    return requestAccess(toAlbum: toAlbum);
  }

  /// 获取权限状态的描述信息
  ///
  /// 用于调试和日志记录
  Future<String> getAccessStatusDescription() async {
    final hasBasicAccess = await hasAccess();
    final hasAlbumAccess = await hasAccess(toAlbum: true);

    return '''
相册权限状态:
  - 基本访问: ${hasBasicAccess ? '已授权' : '未授权'}
  - 相册访问: ${hasAlbumAccess ? '已授权' : '未授权'}
''';
  }
}
