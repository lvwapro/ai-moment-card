import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/cos_upload_service.dart';
import '../services/language_service.dart';
import 'common/fallback_background.dart';

/// 增强版图片选择组件 - 集成腾讯云 COS 上传功能
class EnhancedImageSelectionWidget extends StatefulWidget {
  const EnhancedImageSelectionWidget({
    super.key,
    required this.onDataChanged, // 统一的数据变化回调
    required this.onUploadFailed,
  });
  final Function(List<String> cloudUrls, List<String> localPaths) onDataChanged;
  final Function(String) onUploadFailed;

  @override
  State<EnhancedImageSelectionWidget> createState() =>
      _EnhancedImageSelectionWidgetState();
}

class _EnhancedImageSelectionWidgetState
    extends State<EnhancedImageSelectionWidget> {
  final ImagePicker _picker = ImagePicker();
  final CosUploadService _uploadService = CosUploadService.instance;

  // 上传状态管理
  final Map<String, UploadStatus> _uploadStatuses = {};
  final Map<String, int> _uploadProgress = {};
  final Map<String, int> _totalSizes = {};
  final List<File> _tempSelectedImages = []; // 临时存储选中的图片，上传后删除
  final List<String> _uploadedLocalPaths = []; // 已上传图片的本地路径
  final List<String> _uploadedUrls = []; // 已上传的云端URL

  /// 通知父组件数据变化
  void _notifyDataChanged() {
    // 只传递已上传完成的图片路径，不包含正在上传的临时图片
    widget.onDataChanged(_uploadedUrls, _uploadedLocalPaths);
  }

  /// 从相机拍照
  Future<void> _pickImageFromCamera() async {
    try {
      // 检查相机权限
      final cameraStatus = await Permission.camera.status;
      if (cameraStatus.isDenied) {
        final result = await Permission.camera.request();
        if (result.isDenied) {
          _showCameraPermissionDeniedDialog();
          return;
        }
      }

      if (cameraStatus.isPermanentlyDenied) {
        _showCameraPermissionDeniedDialog();
        return;
      }

      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      widget.onUploadFailed('${LanguageService.to.getText('拍照失败：')}$e');
    }
  }

  /// 从相册选择
  Future<void> _pickImageFromGallery() async {
    try {
      // 检查相册权限
      final photosStatus = await Permission.photos.status;
      if (photosStatus.isDenied) {
        final result = await Permission.photos.request();
        if (result.isDenied) {
          _showPermissionDeniedDialog();
          return;
        }
      }

      if (photosStatus.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
        return;
      }

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      widget.onUploadFailed('${LanguageService.to.getText('选择图片失败：')}$e');
    }
  }

  /// 上传图片到腾讯云
  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _tempSelectedImages.add(imageFile);
      _uploadStatuses[imageFile.path] = UploadStatus.uploading;
      _uploadProgress[imageFile.path] = 0;
      _totalSizes[imageFile.path] = imageFile.lengthSync();
    });

    // 通知父组件数据变化
    _notifyDataChanged();

    try {
      final result = await _uploadService.uploadFile(
        filePath: imageFile.path,
        onStatus: (status) {
          setState(() {
            _uploadStatuses[imageFile.path] = status;
          });
        },
        onProgress: (completed, total) {
          setState(() {
            _uploadProgress[imageFile.path] = completed;
            _totalSizes[imageFile.path] = total;
          });
        },
      );

      final url = result['url'] as String;

      // 从临时列表中移除，但保留本地路径
      setState(() {
        _tempSelectedImages.remove(imageFile);
        _uploadedLocalPaths.add(imageFile.path); // 保存已上传图片的本地路径
        _uploadedUrls.add(url); // 添加到云端URL列表
        _uploadStatuses.remove(imageFile.path);
        _uploadProgress.remove(imageFile.path);
        _totalSizes.remove(imageFile.path);
      });

      // 通知父组件数据变化
      _notifyDataChanged();

      // 打印上传成功信息
      print('✅ 腾讯云上传成功， 照片链接: $url,文件大小: ${result['fileSize']} bytes');
    } catch (e) {
      setState(() {
        _uploadStatuses[imageFile.path] = UploadStatus.failed;
      });

      widget.onUploadFailed('${LanguageService.to.getText('上传失败：')}$e');
    }
  }

  /// 移除已上传的图片
  void _removeImage(int index) {
    if (index < _uploadedLocalPaths.length && index < _uploadedUrls.length) {
      setState(() {
        _uploadedLocalPaths.removeAt(index);
        _uploadedUrls.removeAt(index);
      });

      // 通知父组件数据变化
      _notifyDataChanged();
    }
  }

  /// 移除临时图片
  void _removeTempImage(File image) {
    setState(() {
      _tempSelectedImages.remove(image);
      _uploadStatuses.remove(image.path);
      _uploadProgress.remove(image.path);
      _totalSizes.remove(image.path);
    });

    // 通知父组件数据变化
    _notifyDataChanged();
  }

  /// 显示权限被拒绝的对话框
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n('需要相册权限')),
        content: Text(context.l10n('请在设置中允许访问相册，以便选择图片。')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n('取消')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(context.l10n('去设置')),
          ),
        ],
      ),
    );
  }

  /// 显示相机权限被拒绝的对话框
  void _showCameraPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n('需要相机权限')),
        content: Text(context.l10n('请在设置中允许访问相机，以便拍照。')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n('取消')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(context.l10n('去设置')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImages =
        _uploadedUrls.isNotEmpty || _tempSelectedImages.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hasImages) _EmptyState() else _ImageGrid(),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state =
        context.findAncestorStateOfType<_EnhancedImageSelectionWidgetState>()!;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: Theme.of(context).primaryColor.withOpacity(0.6),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n('上传图片'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                context: context,
                icon: Icons.camera_alt,
                label: context.l10n('拍照'),
                onTap: () => state._pickImageFromCamera(),
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                context: context,
                icon: Icons.photo_library,
                label: context.l10n('相册'),
                onTap: () => state._pickImageFromGallery(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 40, // 与风格选择按钮一致的高度
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white, // 白色背景
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // 浅色阴影
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ], // 所有按钮都有阴影
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF333333)), // 深色图标
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF333333), // 深色文字
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state =
        context.findAncestorStateOfType<_EnhancedImageSelectionWidgetState>()!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 图片网格
          Padding(
            padding: const EdgeInsets.all(4),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount:
                  state._uploadedUrls.length + state._tempSelectedImages.length,
              itemBuilder: (context, index) {
                // 先显示已上传的图片
                if (index < state._uploadedUrls.length) {
                  return _UploadedImageItem(
                    imageUrl: state._uploadedUrls[index],
                    onRemove: () => state._removeImage(index),
                  );
                }

                // 再显示临时图片
                final tempIndex = index - state._uploadedUrls.length;
                if (tempIndex < state._tempSelectedImages.length) {
                  final image = state._tempSelectedImages[tempIndex];
                  final uploadStatus = state._uploadStatuses[image.path] ??
                      UploadStatus.uploading;
                  final progress = state._uploadProgress[image.path] ?? 0;
                  final totalSize = state._totalSizes[image.path] ?? 0;

                  return _ImageItem(
                    image: image,
                    uploadStatus: uploadStatus,
                    progress: progress,
                    totalSize: totalSize,
                    onRemove: () => state._removeTempImage(image),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          // 添加更多图片按钮
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: InkWell(
              onTap: () => _showImageSourceDialog(context, state),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 40, // 与风格选择按钮一致的高度
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white, // 白色背景
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // 浅色阴影
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ], // 所有按钮都有阴影
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add,
                        size: 16, color: Color(0xFF333333)), // 深色图标
                    const SizedBox(width: 8),
                    Text(
                      context.l10n('添加更多图片'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF333333), // 深色文字
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(
      BuildContext context, _EnhancedImageSelectionWidgetState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n('选择图片来源')),
        content: Text(context.l10n('请选择您想要添加图片的方式')),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              state._pickImageFromCamera();
            },
            icon: const Icon(Icons.camera_alt),
            label: Text(context.l10n('拍照')),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              state._pickImageFromGallery();
            },
            icon: const Icon(Icons.photo_library),
            label: Text(context.l10n('相册')),
          ),
        ],
      ),
    );
  }
}

class _UploadedImageItem extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onRemove;

  const _UploadedImageItem({
    required this.imageUrl,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const FallbackBackground(),
              ),
            ),
            // 删除按钮
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 16),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ),
            ),
          ],
        ),
      );
}

class _ImageItem extends StatelessWidget {
  final File image;
  final UploadStatus uploadStatus;
  final int progress;
  final int totalSize;
  final VoidCallback onRemove;

  const _ImageItem({
    required this.image,
    required this.uploadStatus,
    required this.progress,
    required this.totalSize,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.file(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const FallbackBackground(),
              ),
            ),

            // 上传状态覆盖层
            if (uploadStatus == UploadStatus.uploading)
              _buildUploadingOverlay()
            else if (uploadStatus == UploadStatus.failed)
              _buildFailedOverlay(),

            // 删除按钮
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 16),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildUploadingOverlay() {
    final percentage = totalSize > 0 ? (progress / totalSize * 100).toInt() : 0;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedOverlay() => Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(
            Icons.error,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
}
