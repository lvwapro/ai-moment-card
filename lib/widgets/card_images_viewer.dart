import 'dart:io';
import 'package:flutter/material.dart';
import '../models/poetry_card.dart';
import '../services/language_service.dart';

/// 卡片图片查看器
class CardImagesViewer extends StatefulWidget {
  final PoetryCard card;

  const CardImagesViewer({
    super.key,
    required this.card,
  });

  @override
  State<CardImagesViewer> createState() => _CardImagesViewerState();
}

class _CardImagesViewerState extends State<CardImagesViewer> {
  bool _isExpanded = false;
  List<ImageSource> _images = [];

  @override
  void initState() {
    super.initState();
    _images = _getAvailableImages();
    // 延迟预加载所有图片，等待 context 完全构建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImages();
    });
  }

  /// 预加载所有图片到缓存
  void _preloadImages() {
    if (!mounted) return;

    print('🚀 开始预加载 ${_images.length} 张图片...');
    for (var i = 0; i < _images.length; i++) {
      final imageSource = _images[i];
      if (!imageSource.isLocal && imageSource.path.startsWith('http')) {
        // 预加载网络图片
        precacheImage(NetworkImage(imageSource.path), context).then((_) {
          print('✅ 图片 ${i + 1} 预加载完成');
        }).catchError((error) {
          print('❌ 图片 ${i + 1} 预加载失败: $error');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和展开按钮
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.photo_library,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n('相关图片'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _images.length.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),

          // 图片网格
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return _buildImageThumbnail(_images[index], index);
                },
              ),
            ),
        ],
      ),
    );
  }

  /// 构建图片缩略图
  Widget _buildImageThumbnail(ImageSource imageSource, int index) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(imageSource, index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[100],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(imageSource),
              // 半透明遮罩和索引
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建图片组件
  Widget _buildImage(ImageSource imageSource) {
    if (imageSource.isLocal) {
      return Image.file(
        File(imageSource.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else {
      return Image.network(
        imageSource.path,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }
  }

  /// 构建错误占位符
  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 32,
      ),
    );
  }

  /// 显示全屏图片
  void _showFullScreenImage(ImageSource imageSource, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          images: _images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  /// 获取所有可用图片
  List<ImageSource> _getAvailableImages() {
    final images = <ImageSource>[];

    // 获取云端图片列表
    final cloudUrls = widget.card.metadata['cloudImageUrls'] as List<dynamic>?;

    // 添加所有云端图片
    if (cloudUrls != null && cloudUrls.isNotEmpty) {
      for (int i = 0; i < cloudUrls.length; i++) {
        final cloudUrl = cloudUrls[i].toString();
        if (cloudUrl.startsWith('http')) {
          images.add(ImageSource(path: cloudUrl, isLocal: false));
          print(
              '📸 图片 ${i + 1}: ${cloudUrl.substring(cloudUrl.length > 50 ? cloudUrl.length - 50 : 0)}');
        }
      }
    }

    // 如果没有云端图片，使用卡片原始图片作为后备
    if (images.isEmpty) {
      final originalPath = widget.card.image.path;
      images.add(ImageSource(
        path: originalPath,
        isLocal: !originalPath.startsWith('http'),
      ));
      print(
          '📸 图片 1: 使用原始图片 - ${originalPath.substring(originalPath.length > 50 ? originalPath.length - 50 : 0)}');
    }

    print('📸 总图片数量: ${images.length}');

    return images;
  }
}

/// 图片源
class ImageSource {
  final String path;
  final bool isLocal;

  ImageSource({required this.path, required this.isLocal});
}

/// 全屏图片查看器
class _FullScreenImageViewer extends StatefulWidget {
  final List<ImageSource> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imageSource = widget.images[index];
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: imageSource.isLocal
                  ? Image.file(
                      File(imageSource.path),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorWidget(),
                    )
                  : Image.network(
                      imageSource.path,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorWidget(),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.white54,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            '图片加载失败',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
