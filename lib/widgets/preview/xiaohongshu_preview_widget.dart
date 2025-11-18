import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/poetry_card.dart';
import '../../services/language_service.dart';
import 'package:intl/intl.dart';
import 'phone_status_bar.dart';

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
  Widget build(BuildContext context) => _buildXiaohongshuContent(context);

  /// 构建小红书内容
  Widget _buildXiaohongshuContent(BuildContext context) => Container(
        color: Colors.white,
        child: Stack(
          children: [
            // 主内容区域（可滚动）
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部占位（状态栏44px + 头部高度约48px）
                  const SizedBox(height: 92),

                  // 图片区域
                  _buildImageSection(),

                  // 文案内容
                  if (widget.card.xiaohongshu != null &&
                      widget.card.xiaohongshu!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Text(
                        widget.card.xiaohongshu!,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                  // 时间、地点
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Text(
                      '${_formatDate(widget.card.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                  // 分隔线
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Divider(height: 1, color: Colors.grey[200]),
                  ),

                  // 评论数量显示
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Row(
                      children: [
                        Text(
                          context.l10n('共 2 条评论'),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildCommentsList(context),
                  ),

                  const SizedBox(height: 80), // 留出底部互动栏空间
                ],
              ),
            ),

            // 底部互动栏（固定在底部）
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                    12, 6, 12, 16), // 上padding从8改为6，下padding从20改为16
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: _buildInteractionBar(context),
              ),
            ),

            // 固定顶部区域（状态栏+头部，整体白色背景）
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white, // 整体白色背景
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 状态栏
                    const PhoneStatusBar(
                      textColor: Colors.black,
                    ),

                    // 头部用户信息
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Row(
                        children: [
                          // 返回按钮
                          const Icon(Icons.arrow_back_ios,
                              size: 18, color: Colors.black),
                          const SizedBox(width: 4),

                          // 头像
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 28,
                                height: 28,
                                color: Colors.grey[300],
                                child: const Icon(Icons.person,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // 昵称
                          Text(
                            context.l10n('拾光记'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),

                          const Spacer(),

                          // 关注按钮（红色边框）
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFf93a4b),
                                width: 0.4,
                              ),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Text(
                              context.l10n('关注'),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFf93a4b),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // 分享按钮
                          Image.asset(
                            'assets/images/xiaohongshu_share.png',
                            width: 20,
                            height: 20,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.shortcut,
                                    size: 20, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  /// 构建图片区域
  Widget _buildImageSection() {
    final images = _getImages();

    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalImages = images.length > 9 ? 9 : images.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // 让子组件占满宽度
      children: [
        // 图片轮播（宽高比3:4，图片contain，空余部分白色）
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = width * 1.33; // 宽高比3:4，即高度是宽度的1.33倍

            return Container(
              height: height,
              width: double.infinity, // 明确设置为占满宽度
              color: Colors.white, // 空余部分白色背景
              child: Stack(
                children: [
                  // 图片PageView
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: totalImages,
                    itemBuilder: (context, index) => _buildImage(images[index]),
                  ),

                  // 右上角图片张数显示
                  if (totalImages > 1)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/$totalImages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        // 图片指示器（小红点样式）- 在图片下方
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalImages,
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
          fit: BoxFit.contain, // 使用contain完整展示图片，不裁剪
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    }

    // 网络图片
    return Image.network(
      imageSource.path,
      fit: BoxFit.contain, // 使用contain完整展示图片，不裁剪
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
  Widget _buildPlaceholder() => Container(
        color: Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 60,
            color: Colors.grey[400],
          ),
        ),
      );

  /// 构建模拟评论列表
  Widget _buildCommentsList(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentItem(
            context,
            context.l10n('momo'),
            context.l10n('好美！！！'),
            context.l10n('5天前 深圳'),
            avatarPath: 'assets/images/avatar.png', // 使用西瓜恐龙头像
          ),
          const SizedBox(height: 12),
          _buildCommentItem(
            context,
            context.l10n('拾光记'),
            context.l10n('记录生活'),
            context.l10n('5天前 深圳'),
            isAuthor: true,
          ),
        ],
      );

  /// 构建单条评论
  Widget _buildCommentItem(
    BuildContext context,
    String userName,
    String comment,
    String time, {
    bool isAuthor = false,
    String? avatarPath, // 可选的头像路径参数
  }) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              avatarPath ?? 'assets/images/logo.png', // 使用自定义头像或默认头像
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
                    fontSize: 12,
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

  /// 构建底部互动栏
  Widget _buildInteractionBar(BuildContext context) => Row(
        children: [
          // 左侧：输入框（带编辑icon）- 占40%宽度
          Flexible(
            flex: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 编辑icon（铅笔图标）
                  Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  // 输入提示文字（不换行）
                  Flexible(
                    child: Text(
                      context.l10n('说点什么...'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 右侧：互动数据 - 占60%宽度
          Flexible(
            flex: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildInteractionButton(Icons.favorite_border, '948'),
                const SizedBox(width: 10), // 从12改为10
                _buildInteractionButton(Icons.star_border, '744'),
                const SizedBox(width: 10), // 从12改为10
                _buildInteractionButton(Icons.chat_bubble_outline, '2'),
              ],
            ),
          ),
        ],
      );

  /// 构建单个互动按钮
  Widget _buildInteractionButton(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.black87), // 从22改回20
        const SizedBox(width: 3), // 从4改为3
        Text(
          count,
          style: const TextStyle(
            fontSize: 12, // 从13改回12
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

    // 使用统一的方法获取本地图片路径
    final localPaths = widget.card.getLocalImagePaths();
    for (final path in localPaths) {
      images.add(ImageSource(path: path, isLocal: true));
    }

    return images;
  }

  /// 格式化日期
  String _formatDate(DateTime date) => DateFormat('MM-dd').format(date);
}

/// 图片来源
class ImageSource {
  final String path;
  final bool isLocal;

  ImageSource({required this.path, required this.isLocal});
}
