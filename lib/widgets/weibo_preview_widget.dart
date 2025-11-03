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
  Widget _buildWeiboContent(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FA), // 微博背景色
      child: Stack(
        children: [
          // 主内容区域（可滚动）
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部导航栏（状态栏下方44px处开始）
                const SizedBox(height: 44),

                // 顶部导航栏
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.arrow_back_ios,
                          size: 20, color: Colors.black),
                      Text(
                        context.l10n('微博正文'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.more_horiz,
                          size: 24, color: Colors.black),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 微博内容卡片
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 顶部用户信息
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          const SizedBox(width: 10),

                          // 用户名和时间信息
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 用户名和VIP标识
                                Row(
                                  children: [
                                    Text(
                                      context.l10n('迹见文案'),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFD76D43),
                                      ),
                                    ),
                                    // VIP图标
                                    Image.asset(
                                      'assets/weibo_vip.png',
                                      height: 16,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // 时间和来源
                                Text(
                                  '${_formatDate(card.createdAt)} ${context.l10n('来自')} iPhone 17 pro',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 右侧关注按钮
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: const Color(0xFFf79c49),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add,
                                  size: 14,
                                  color: Color(0xFFD98E38),
                                ),
                                Text(
                                  context.l10n('关注'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFD98E38),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 文案内容
                      if (card.weibo != null && card.weibo!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            card.weibo!,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                      // 图片展示
                      _buildImageGrid(),

                      const SizedBox(height: 12),

                      // 评论输入框
                      _buildCommentInput(context),

                      const SizedBox(height: 8),

                      // 底部互动栏
                      _buildInteractionBar(context),
                    ],
                  ),
                ),

                const SizedBox(height: 80), // 留出底部空间
              ],
            ),
          ),

          // 手机状态栏（透明，叠加在最顶层）
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: PhoneStatusBar(),
          ),
        ],
      ),
    );
  }

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
        borderRadius: BorderRadius.circular(4),
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
        childAspectRatio: 1, // 正方形
      ),
      itemCount: imageCount,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
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
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.white, size: 40),
        ),
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

  /// 构建底部互动栏
  Widget _buildInteractionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 6, left: 16, right: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 转发
          _buildActionButton(
            icon: Icons.repeat,
            label: '1',
            color: Colors.grey[700]!,
          ),

          // 评论
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            label: '10',
            color: Colors.grey[700]!,
          ),

          // 点赞
          _buildActionButton(
            icon: Icons.favorite_border,
            label: '531',
            color: Colors.grey[700]!,
          ),
        ],
      ),
    );
  }

  /// 构建单个操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 构建评论输入框
  Widget _buildCommentInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // 用户头像
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/logo.png',
              width: 28,
              height: 28,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 28,
                height: 28,
                color: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.white, size: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 输入框
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                context.l10n('友善评论，文明发言'),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      ),
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
    if (images.isEmpty && card.image.existsSync()) {
      images.add(card.image.path);
    }

    return images;
  }

  /// 从 metadata 中获取列表
  List<String> _getListFromMetadata(String key) {
    final metadata = card.metadata;
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
  String _formatDate(DateTime date) => DateFormat('MM-dd').format(date);
}
