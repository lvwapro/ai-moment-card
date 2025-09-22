import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageSaveService {
  static final ImageSaveService _instance = ImageSaveService._internal();
  factory ImageSaveService() => _instance;
  ImageSaveService._internal();

  /// 保存卡片到相册
  Future<bool> saveCardToGallery(GlobalKey repaintBoundaryKey) async {
    try {
      // 检查权限
      if (!await _requestPermission()) {
        return false;
      }

      // 获取渲染边界
      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      
      // 转换为图片
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        return false;
      }

      // 保存到相册
      await Gal.putImageBytes(
        byteData.buffer.asUint8List(),
        name: 'AI诗意卡片_${DateTime.now().millisecondsSinceEpoch}',
      );

      return true;
    } catch (e) {
      print('保存图片失败: $e');
      return false;
    }
  }

  /// 保存文件到相册
  Future<bool> saveFileToGallery(File file) async {
    try {
      // 检查权限
      if (!await _requestPermission()) {
        return false;
      }

      // 保存到相册
      await Gal.putImage(file.path);

      return true;
    } catch (e) {
      print('保存文件失败: $e');
      return false;
    }
  }

  /// 请求相册权限
  Future<bool> _requestPermission() async {
    // 检查当前权限状态
    var status = await Permission.photos.status;
    
    if (status.isGranted) {
      return true;
    }

    // 请求权限
    status = await Permission.photos.request();
    
    if (status.isGranted) {
      return true;
    }

    // 如果权限被拒绝，尝试打开设置
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
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
