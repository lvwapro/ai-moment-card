import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageSaveService {
  static final ImageSaveService _instance = ImageSaveService._internal();
  factory ImageSaveService() => _instance;
  ImageSaveService._internal();

  /// 保存卡片到相册
  Future<bool> saveCardToGallery(GlobalKey repaintBoundaryKey) async {
    try {
      print('💾 开始保存卡片到相册...');

      // 检查权限
      if (!await _requestPermission()) {
        print('❌ 相册权限未授权');
        return false;
      }

      print('✅ 相册权限已授权，开始渲染图片...');

      // 获取渲染边界
      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      // 转换为图片
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        print('❌ 图片转换失败');
        return false;
      }

      print('✅ 图片渲染完成，开始保存...');

      // 使用 image_gallery_saver 保存到相册
      final result = await ImageGallerySaver.saveImage(
        byteData.buffer.asUint8List(),
        quality: 100,
        name: 'AI诗意卡片_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('📸 保存结果: $result');

      // 检查保存结果
      if (result != null && result['isSuccess'] == true) {
        print('✅ 保存成功！');
        return true;
      } else {
        print('❌ 保存失败: $result');
        return false;
      }
    } catch (e) {
      print('❌ 保存图片失败: $e');
      print('❌ 错误堆栈: ${StackTrace.current}');
      return false;
    }
  }

  /// 保存文件到相册
  Future<bool> saveFileToGallery(File file) async {
    try {
      print('💾 开始保存文件到相册: ${file.path}');

      // 检查权限
      if (!await _requestPermission()) {
        print('❌ 相册权限未授权');
        return false;
      }

      print('✅ 相册权限已授权，开始保存...');

      // 使用 image_gallery_saver 保存文件
      final result = await ImageGallerySaver.saveFile(
        file.path,
        name: 'AI诗意卡片_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('📸 保存结果: $result');

      // 检查保存结果
      if (result != null && result['isSuccess'] == true) {
        print('✅ 保存成功！');
        return true;
      } else {
        print('❌ 保存失败: $result');
        return false;
      }
    } catch (e) {
      print('❌ 保存文件失败: $e');
      print('❌ 错误堆栈: ${StackTrace.current}');
      return false;
    }
  }

  /// 请求相册权限
  Future<bool> _requestPermission() async {
    try {
      // 统一使用 photos 权限（可读写），这样设置中会显示"所有照片"选项
      final permission = Permission.photos;

      var status = await permission.status;
      print('📸 当前相册权限状态: $status');

      // 如果已授权（包括limited），直接返回
      if (status.isGranted || status.isLimited) {
        print('✅ 相册权限已授权');
        return true;
      }

      // 如果是永久拒绝状态，直接引导去设置（不再请求）
      if (status.isPermanentlyDenied) {
        print('⚠️ 相册权限被永久拒绝，引导用户去设置');
        await openAppSettings();
        return false;
      }

      // 如果是denied或restricted，尝试请求权限
      print('🔄 开始请求相册权限...');
      status = await permission.request();
      print('📸 请求后相册权限状态: $status');

      // 请求后检查状态
      if (status.isGranted || status.isLimited) {
        print('✅ 用户授权成功');
        return true;
      }

      // 如果请求后变成永久拒绝或拒绝
      if (status.isPermanentlyDenied || status.isDenied) {
        print('⚠️ 用户拒绝授权，引导去设置');
        await openAppSettings();
      }

      return false;
    } catch (e) {
      print('❌ 请求相册权限失败: $e');
      print('❌ 错误详情: ${e.toString()}');
      return false;
    }
  }

  /// 获取权限状态描述
  Future<String> getPermissionStatus() async {
    var status = await Permission.photos.status;

    switch (status) {
      case PermissionStatus.granted:
        return '已授权';
      case PermissionStatus.denied:
        return '未授权';
      case PermissionStatus.restricted:
        return '受限制';
      case PermissionStatus.limited:
        return '部分授权';
      case PermissionStatus.permanentlyDenied:
        return '永久拒绝';
      case PermissionStatus.provisional:
        return '临时授权';
    }
  }
}
