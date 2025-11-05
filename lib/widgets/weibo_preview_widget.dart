import 'package:flutter/material.dart';
import 'dart:io';
import '../models/poetry_card.dart';
import '../services/language_service.dart';
import 'package:intl/intl.dart';
import 'phone_status_bar.dart';

/// 微博预览组件
/// 模拟微博的显示效果
class WeiboPreviewWidget extends StatelessWidget {
  final PoetryCard card;

  const WeiboPreviewWidget({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) => _buildWeiboContent(context);

  /// 构建微博内容
  Widget _buildWeiboContent(BuildContext context) => Container(
        color: Colors.white, // 微博背景色为白色
        child: Stack(
          children: [
            // 主内容区域（可滚动）
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部留白（状态栏44 + 导航栏高度约36 + 横线1）
                  const SizedBox(height: 81),

                  // 微博内容卡片
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(
                        top: 16, left: 16, right: 16, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 用户信息行
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 头像（带V徽章）
                            SizedBox(
                              width: 36,
                              height: 36,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // 头像
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        width: 36,
                                        height: 36,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.person,
                                            color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ),
                                  // V徽章（右下角）
                                  Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'V',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),

                            // 用户名、徽章和时间信息
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 用户名和徽章
                                  Row(
                                    children: [
                                      Text(
                                        context.l10n('迹见文案'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFbc7b4b),
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      // VIP徽章图片
                                      Image.asset(
                                        'assets/images/weibo_vip.png',
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  // 时间和来源信息
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 2,
                                    children: [
                                      Text(
                                        _formatDateTime(card.createdAt),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                          height: 1.2,
                                        ),
                                      ),
                                      Text(
                                        context.l10n('来自') +
                                            ' ${context.l10n('iPhone 17 Pro Max')}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // 发布于信息（单独一行）
                                  Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: Text(
                                      context.l10n('发布于') + context.l10n('深圳'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 右侧收藏按钮（空心星星）
                            const Icon(
                              Icons.star_border,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 文案内容
                        if (card.weibo != null && card.weibo!.isNotEmpty)
                          Text(
                            card.weibo!,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),

                        // 图片展示（与文案有间距）
                        if (card.weibo != null && card.weibo!.isNotEmpty)
                          const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildImageGrid(),
                        ),

                        const SizedBox(height: 12),

                        // "大家都在搜"部分
                        _buildTrendingSearches(context),

                        const SizedBox(height: 12),

                        // "点赞是美意，赞赏是鼓励"文字
                        Text(
                          context.l10n('点赞是美意,赞赏是鼓励'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 4),

                        // 奖励图标部分
                        _buildRewardSection(context),
                      ],
                    ),
                  ),

                  // 互动栏（转发、评论、赞）- 移到padding外面以便边框贴满
                  _buildInteractionBar(context),

                  // 评论区域 - 移到padding外面
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildCommentSection(context),
                  ),

                  const SizedBox(height: 60), // 留出底部空间
                ],
              ),
            ),

            // 固定顶部区域（状态栏+导航栏，整体白色背景）
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

                    // 顶部导航栏
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: SizedBox(
                        height: 20,
                        child: Stack(
                          children: [
                            // 左侧返回按钮
                            Align(
                              alignment: Alignment.centerLeft,
                              child: const Icon(Icons.arrow_back_ios,
                                  size: 16, color: Colors.black),
                            ),
                            // 中间标题（真正居中）
                            Center(
                              child: Text(
                                context.l10n('微博正文'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            // 右侧三个图标（缩小并拥挤）
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.headphones_outlined,
                                      size: 16, color: Colors.black),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.search,
                                      size: 16, color: Colors.black),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.more_horiz,
                                      size: 18, color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 横线分隔
                    Container(
                      height: 1,
                      color: Colors.grey[200],
                    ),
                  ],
                ),
              ),
            ),

            // 底部导航栏（固定在底部）
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                padding: const EdgeInsets.only(top: 0, bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomNavItem(Icons.repeat, '3'),
                    _buildBottomNavItem(Icons.chat_bubble_outline, '4'),
                    _buildBottomNavItem(Icons.favorite_border, '172'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  /// 构建图片网格
  Widget _buildImageGrid() {
    final images = _getImages();

    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    final imageCount = images.length > 9 ? 9 : images.length;

    // 根据图片数量决定布局
    if (imageCount == 1) {
      // 单张图片，使用固定宽高，比例为3:2
      return ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          width: 240,
          height: 160,
          child: _buildImage(images[0]),
        ),
      );
    }

    // 多张图片使用网格布局
    final crossAxisCount = imageCount == 2 ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero, // 确保没有默认padding
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
        childAspectRatio: 1, // 正方形
      ),
      itemCount: imageCount,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: _buildImage(images[index]),
        );
      },
    );
  }

  /// 构建单张图片
  Widget _buildImage(String imagePath) {
    final isUrl = imagePath.startsWith('http');

    if (isUrl) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // 静默处理网络图片加载错误（404等），不输出到控制台
          return Container(
            color: Colors.grey[300],
            child:
                const Icon(Icons.broken_image, color: Colors.white, size: 40),
          );
        },
        // 添加frameBuilder来更优雅地处理错误
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    } else {
      final file = File(imagePath);
      if (!file.existsSync()) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.white, size: 40),
        );
      }

      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.white, size: 40),
        ),
      );
    }
  }

  /// 构建"大家都在搜"部分
  Widget _buildTrendingSearches(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n('大家都在搜'),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSearchChip(context.l10n('迹见文案')),
              _buildSearchChip(context.l10n('迹见文案-AI文案助手')),
            ],
          ),
        ],
      );

  /// 构建搜索气泡
  Widget _buildSearchChip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      );

  /// 构建奖励图标部分
  Widget _buildRewardSection(BuildContext context) => Image.asset(
        'assets/images/weibo_share.jpg',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );

  /// 构建互动栏
  Widget _buildInteractionBar(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey[200]!, width: 6),
          ),
        ),
        child: Column(
          children: [
            // 第一行：转发、评论（左），赞（右）
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildInteractionItem(context.l10n('转发'), '3', false),
                      const SizedBox(width: 24),
                      _buildInteractionItem(context.l10n('评论'), '4', true),
                    ],
                  ),
                  _buildInteractionItem(context.l10n('赞'), '172', false),
                ],
              ),
            ),
          ],
        ),
      );

  /// 构建互动项
  Widget _buildInteractionItem(String label, String count, bool isActive) =>
      Stack(
        clipBehavior: Clip.none,
        children: [
          Text(
            '$label $count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.black87 : Colors.grey[500],
            ),
          ),
          // 自定义下划线（位置更靠下）
          if (isActive)
            Positioned(
              left: 0,
              right: 0,
              bottom: -2,
              child: Container(
                height: 2.0,
                color: Colors.orange,
              ),
            ),
        ],
      );

  /// 构建评论区域
  Widget _buildCommentSection(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一条评论
          _buildCommentItem(
            context,
            avatarPath: 'assets/images/avatar.png',
            userName: 'haohaoteuk1023',
            userNameColor: const Color.fromARGB(255, 58, 58, 58),
            comment: context.l10n('真不错'),
            time: '11-3 20:27',
            location: '${context.l10n('来自')} ${context.l10n('日本')}',
            likeCount: '2',
          ),
        ],
      );

  /// 构建单条评论
  Widget _buildCommentItem(
    BuildContext context, {
    required String avatarPath,
    required String userName,
    Color userNameColor = Colors.black87,
    Widget? badge,
    required String comment,
    required String time,
    required String location,
    required String likeCount,
    Widget? rightBadge,
  }) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像和徽章
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  avatarPath,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 32,
                    height: 32,
                    color: Colors.grey[300],
                    child:
                        const Icon(Icons.person, size: 20, color: Colors.white),
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 4),
                badge,
              ],
            ],
          ),
          const SizedBox(width: 8),

          // 评论内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户名
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: userNameColor,
                  ),
                ),
                const SizedBox(height: 4),
                // 评论内容和右侧徽章（单行显示）
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        comment,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (rightBadge != null) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: rightBadge,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // 时间地点和三个icon在一行
                Row(
                  children: [
                    // 时间和地点（左侧）
                    Expanded(
                      child: Text(
                        '$time $location',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    // 三个互动图标（右侧，更小）
                    Icon(Icons.share_outlined,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Icon(Icons.chat_bubble_outline,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    if (likeCount.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.thumb_up_outlined,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            likeCount,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    else
                      Icon(Icons.thumb_up_outlined,
                          size: 14, color: Colors.grey[600]),
                  ],
                ),
              ],
            ),
          ),
        ],
      );

  /// 构建底部导航项
  Widget _buildBottomNavItem(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 获取图片列表
  List<String> _getImages() {
    // 使用统一的方法获取本地图片路径
    return card.getLocalImagePaths();
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime date) {
    return DateFormat('yy-M-d HH:mm').format(date);
  }
}
