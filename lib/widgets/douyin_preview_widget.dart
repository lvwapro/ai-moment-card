import 'package:flutter/material.dart';
import 'dart:io';
import '../models/poetry_card.dart';
import '../services/language_service.dart';

/// 抖音预览组件
/// 模拟抖音的显示效果
class DouyinPreviewWidget extends StatefulWidget {
  final PoetryCard card;

  const DouyinPreviewWidget({
    super.key,
    required this.card,
  });

  @override
  State<DouyinPreviewWidget> createState() => _DouyinPreviewWidgetState();
}

class _DouyinPreviewWidgetState extends State<DouyinPreviewWidget> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部标题栏
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n('抖音预览'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // 抖音主内容区域
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Stack(
                      children: [
                        // 背景图片/视频区域
                        _buildContentArea(),

                        // 顶部导航栏
                        _buildTopNavBar(context),

                        // 图片指示器（多图时显示）
                        if (_getImages().length > 1) _buildImageIndicator(),

                        // 左下角信息栏
                        _buildBottomLeftInfo(context),

                        // 右侧互动栏
                        _buildRightInteractionBar(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  /// 构建内容区域（图片/视频）
  Widget _buildContentArea() {
    final images = _getImages();

    if (images.isEmpty) {
      return Container(
        height: 500,
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 60,
            color: Colors.white38,
          ),
        ),
      );
    }

    // 多张图片时使用 PageView
    if (images.length > 1) {
      return SizedBox(
        height: 500,
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: images.length > 9 ? 9 : images.length,
          itemBuilder: (context, index) {
            return _buildImage(images[index]);
          },
        ),
      );
    }

    // 单张图片
    return SizedBox(
      height: 500,
      child: _buildImage(images[0]),
    );
  }

  /// 构建单张图片
  Widget _buildImage(String imagePath) {
    final isUrl = imagePath.startsWith('http');

    if (isUrl) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.black,
          child:
              const Icon(Icons.broken_image, color: Colors.white38, size: 60),
        ),
      );
    } else {
      final file = File(imagePath);
      if (!file.existsSync()) {
        return Container(
          color: Colors.black,
          child:
              const Icon(Icons.broken_image, color: Colors.white38, size: 60),
        );
      }

      return Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.black,
          child:
              const Icon(Icons.broken_image, color: Colors.white38, size: 60),
        ),
      );
    }
  }

  /// 构建顶部导航栏
  Widget _buildTopNavBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.4),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 关注
            Text(
              context.l10n('关注'),
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 32),
            // 推荐（选中状态）
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n('推荐'),
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图片指示器
  Widget _buildImageIndicator() {
    final images = _getImages();
    final imageCount = images.length > 9 ? 9 : images.length;

    return Positioned(
      bottom: 22,
      left: 0,
      right: 0,
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: List.generate(
            imageCount,
            (index) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建左下角信息栏
  Widget _buildBottomLeftInfo(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 16,
      right: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 用户名和图文标签
          Row(
            children: [
              Text(
                '@${context.l10n('迹见文案')}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  context.l10n('图文'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // 文案内容
          if (widget.card.douyin != null && widget.card.douyin!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.card.douyin!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 8),

          // 分享给按钮
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/douyin_share.png',
                  width: 16,
                  height: 16,
                  color: Colors.white,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.share_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n('分享给'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  context.l10n('AI助手'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建右侧互动栏
  Widget _buildRightInteractionBar(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: 45,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头像
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[700],
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 点赞
          _buildInteractionButton(
            Icons.favorite,
            '13.8w',
            Colors.white,
          ),

          const SizedBox(height: 16),

          // 评论
          _buildInteractionButton(
            Icons.chat_bubble,
            '2341',
            Colors.white,
          ),

          const SizedBox(height: 16),

          // 收藏
          _buildInteractionButton(
            Icons.star,
            '95',
            Colors.white,
          ),

          const SizedBox(height: 16),

          // 分享
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/douyin_share.png',
                width: 24,
                height: 24,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '1261',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建单个互动按钮
  Widget _buildInteractionButton(IconData icon, String count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 2),
        Text(
          count,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 获取图片列表
  List<String> _getImages() {
    final images = <String>[];

    // 1. 优先使用本地图片路径
    final localPaths = _getListFromMetadata('localImagePaths');
    for (final path in localPaths) {
      if (_isValidPath(path)) {
        images.add(path);
      }
    }

    // 2. 如果本地图片不够，补充云端图片
    if (images.isEmpty) {
      final cloudUrls = _getListFromMetadata('cloudImageUrls');
      for (final url in cloudUrls) {
        if (_isValidPath(url)) {
          images.add(url);
        }
      }
    }

    // 3. 如果还是没有图片，使用原始图片
    if (images.isEmpty && widget.card.image.existsSync()) {
      images.add(widget.card.image.path);
    }

    return images;
  }

  /// 从 metadata 中获取列表
  List<String> _getListFromMetadata(String key) {
    final metadata = widget.card.metadata;
    if (metadata.containsKey(key)) {
      final value = metadata[key];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
    }
    return [];
  }

  /// 验证路径是否有效
  bool _isValidPath(String path) {
    if (path.isEmpty) return false;
    // 检查是否是网络URL
    if (path.startsWith('http')) return true;
    // 检查本地文件是否存在
    return File(path).existsSync();
  }
}
