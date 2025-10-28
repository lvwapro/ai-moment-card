import 'package:flutter/material.dart';
import 'dart:io';
import '../models/poetry_card.dart';
import '../services/language_service.dart';
import 'package:intl/intl.dart';

/// 小红书预览组件
/// 模拟小红书的显示效果
class XiaohongshuPreviewWidget extends StatefulWidget {
  final PoetryCard card;

  const XiaohongshuPreviewWidget({
    super.key,
    required this.card,
  });

  @override
  State<XiaohongshuPreviewWidget> createState() =>
      _XiaohongshuPreviewWidgetState();
}

class _XiaohongshuPreviewWidgetState extends State<XiaohongshuPreviewWidget> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
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
              // 标题栏
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
                      context.l10n('小红书预览'),
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

              // 内容区域（可滚动）
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 顶部用户信息
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              // 返回按钮
                              Icon(Icons.arrow_back_ios,
                                  size: 20, color: Colors.black),
                              const SizedBox(width: 6),

                              // 头像
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.person,
                                        color: Colors.white, size: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // 昵称
                              Text(
                                context.l10n('迹见文案'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const Spacer(),

                              // 关注按钮（红色边框）
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFf93a4b),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  context.l10n('关注'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFf93a4b),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // 分享按钮
                              Image.asset(
                                'assets/xiaohongshu_share.png',
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.shortcut,
                                        size: 24, color: Colors.black),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 图片区域（不加额外padding，保持全宽）
                        _buildImageSection(),

                        // 文案内容
                        if (widget.card.xiaohongshu != null &&
                            widget.card.xiaohongshu!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                            child: Text(
                              widget.card.xiaohongshu!,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                        // 时间、地点
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                          child: Text(
                            '${_formatDate(widget.card.createdAt)} ${_getCityName()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),

                        // 分隔线
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Divider(height: 1, color: Colors.grey[200]),
                        ),

                        // 评论数量显示
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                          child: Row(
                            children: [
                              Text(
                                context.l10n('共 13 条评论'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),

                        // 模拟评论列表
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildCommentsList(context),
                        ),

                        const SizedBox(height: 16),

                        // 底部互动栏
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildInteractionBar(context),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  /// 构建图片区域
  Widget _buildImageSection() {
    final images = _getImages();

    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // 图片轮播（固定高度）
        SizedBox(
          height: 400, // 固定高度
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
        ),

        // 图片指示器（小红点样式）- 在图片下方
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length > 9 ? 9 : images.length,
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? const Color(0xFFf93a4b) // 红色小点表示当前图片
                        : Colors.grey[300], // 灰色表示其他图片
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 构建单张图片
  Widget _buildImage(ImageSource imageSource) {
    if (imageSource.isLocal) {
      final file = File(imageSource.path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    }

    // 网络图片
    return Image.network(
      imageSource.path,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  /// 构建占位符
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: 60,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  /// 构建模拟评论列表
  Widget _buildCommentsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentItem(
          context,
          'Xinxxxg',
          '有靠谱团吗',
          '5天前 重庆',
        ),
        const SizedBox(height: 12),
        _buildCommentItem(
          context,
          context.l10n('迹见文案'),
          '已回',
          '5天前 重庆',
          isAuthor: true,
        ),
      ],
    );
  }

  /// 构建单条评论
  Widget _buildCommentItem(
    BuildContext context,
    String userName,
    String comment,
    String time, {
    bool isAuthor = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 头像
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/logo.png',
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 32,
              height: 32,
              color: Colors.grey[300],
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // 评论内容
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isAuthor) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf93a4b),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        context.l10n('作者'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),

        // 点赞
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 16, color: Colors.grey[600]),
          ],
        ),
      ],
    );
  }

  /// 构建底部互动栏
  Widget _buildInteractionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 左侧：输入框
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                context.l10n('说点什么...'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 右侧：互动数据
          _buildInteractionButton(Icons.favorite_border, '848'),
          const SizedBox(width: 12),
          _buildInteractionButton(Icons.star_border, '343'),
          const SizedBox(width: 12),
          _buildInteractionButton(Icons.chat_bubble_outline, '13'),
        ],
      ),
    );
  }

  /// 构建单个互动按钮
  Widget _buildInteractionButton(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 获取图片列表
  List<ImageSource> _getImages() {
    final List<ImageSource> images = [];

    // 1. 优先使用本地图片路径
    final localPaths = _getListFromMetadata('localImagePaths');
    for (final path in localPaths) {
      if (_isValidPath(path)) {
        images.add(ImageSource(path: path, isLocal: true));
      }
    }

    // 2. 如果本地图片不够，补充云端图片
    if (images.isEmpty) {
      final cloudUrls = _getListFromMetadata('cloudImageUrls');
      for (final url in cloudUrls) {
        if (_isValidPath(url)) {
          images.add(ImageSource(path: url, isLocal: false));
        }
      }
    }

    // 3. 如果还是没有图片，使用原始图片
    if (images.isEmpty && widget.card.image.existsSync()) {
      images.add(ImageSource(path: widget.card.image.path, isLocal: true));
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

  /// 格式化日期
  String _formatDate(DateTime date) {
    return DateFormat('MM-dd').format(date);
  }

  /// 获取城市名称
  String _getCityName() {
    if (widget.card.selectedPlace != null) {
      // 从地点名称中提取城市，去掉"·"后面的部分
      final placeName = widget.card.selectedPlace!.name;
      if (placeName.contains('·')) {
        return placeName.split('·')[0];
      }
      return placeName;
    }
    // 默认城市
    return '深圳';
  }
}

/// 图片来源
class ImageSource {
  final String path;
  final bool isLocal;

  ImageSource({required this.path, required this.isLocal});
}
