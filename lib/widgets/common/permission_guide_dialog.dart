import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/language_service.dart';
import '../../theme/app_theme.dart';

/// 权限引导弹窗
/// 当用户拒绝权限时，显示引导弹窗，提示用户手动开启权限
class PermissionGuideDialog extends StatelessWidget {
  final String title;
  final String description;
  final String permissionType; // 'location', 'photos', 'camera'
  final VoidCallback? onOpenSettings;

  const PermissionGuideDialog({
    super.key,
    required this.title,
    required this.description,
    required this.permissionType,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              _getIcon(),
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n(title),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n(description),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getSettingHint(context),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              context.l10n('取消'),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              onOpenSettings?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(context.l10n('去设置')),
          ),
        ],
      );

  IconData _getIcon() {
    switch (permissionType) {
      case 'location':
        return Icons.location_on;
      case 'photos':
        return Icons.photo_library;
      case 'camera':
        return Icons.camera_alt;
      default:
        return Icons.settings;
    }
  }

  String _getSettingHint(BuildContext context) {
    switch (permissionType) {
      case 'location':
        return context.l10n('在设置中找到"位置服务"并开启');
      case 'photos':
        return context.l10n('在设置中找到"照片"并开启');
      case 'camera':
        return context.l10n('在设置中找到"相机"并开启');
      default:
        return context.l10n('在设置中找到"权限"并开启');
    }
  }

  /// 显示位置权限引导弹窗
  static Future<bool?> showLocationPermissionDialog(BuildContext context) =>
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PermissionGuideDialog(
          title: '需要位置权限',
          description: '获取您的位置信息，为您推荐附近地点和基于位置的氛围标签，提供更个性化的文案生成体验。',
          permissionType: 'location',
          onOpenSettings: () async {
            await Geolocator.openAppSettings();
          },
        ),
      );

  /// 显示相册权限引导弹窗
  static Future<bool?> showPhotosPermissionDialog(BuildContext context) =>
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PermissionGuideDialog(
          title: '需要相册权限',
          description: '访问您的相册以选择图片，生成个性化的文案卡片。',
          permissionType: 'photos',
          onOpenSettings: () async {
            await Geolocator.openAppSettings();
          },
        ),
      );

  /// 显示相机权限引导弹窗
  static Future<bool?> showCameraPermissionDialog(BuildContext context) =>
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PermissionGuideDialog(
          title: '需要相机权限',
          description: '使用相机拍摄照片，生成个性化的文案卡片。',
          permissionType: 'camera',
          onOpenSettings: () async {
            await Geolocator.openAppSettings();
          },
        ),
      );
}
