import 'package:flutter/material.dart';
import 'dart:io';
import '../models/poetry_card.dart';
import '../services/language_service.dart';
import 'package:intl/intl.dart';

/// 朋友圈预览组件
/// 模拟微信朋友圈的显示效果
class MomentsPreviewWidget extends StatelessWidget {
  final PoetryCard card;

  const MomentsPreviewWidget({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
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
                  color: Colors.grey[100],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n('朋友圈预览'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

              // 朋友圈内容
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 用户信息行
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 头像 (使用logo)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
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
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // 昵称、文案、图片和时间
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 昵称
                                  Text(
                                    context.l10n('迹见文案'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF576B95), // 微信蓝
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // 文案内容
                                  if (card.pengyouquan != null &&
                                      card.pengyouquan!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        card.pengyouquan!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.4,
                                          color: Colors.grey[850],
                                        ),
                                      ),
                                    ),

                                  // 图片网格
                                  _buildImageGrid(),

                                  const SizedBox(height: 8),

                                  // 时间、地点和操作按钮行
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // 左侧：时间和地点
                                      Expanded(
                                        child: Row(
                                          children: [
                                            // 时间
                                            Text(
                                              _formatTime(card.createdAt),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[500],
                                              ),
                                            ),

                                            // 地点（如果有）
                                            if (card.selectedPlace != null) ...[
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  card.selectedPlace!.name,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(
                                                        0xFF576B95), // 微信蓝
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // 右侧：更多操作按钮（...）
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF7F7F7),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: Icon(
                                          Icons.more_horiz,
                                          size: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // 点赞和评论列表
                                  const SizedBox(height: 8),
                                  _buildInteractionSection(context),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  /// 构建图片网格
  Widget _buildImageGrid() {
    final images = _getImages();

    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    final imageCount = images.length > 9 ? 9 : images.length; // 最多显示9张

    // 确定列数：4张图片时用2列，其他情况用3列
    final crossAxisCount = imageCount == 4 ? 2 : 3;

    // 4张图片时限制宽度，其他情况填满
    final gridWidget = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // 4张图片时2列，其他情况3列
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1, // 1:1 正方形
      ),
      itemCount: imageCount,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: _buildImage(images[index]),
        );
      },
    );

    // 4张图片时，限制网格宽度为3列布局的2/3
    if (imageCount == 4) {
      return Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: 0.67, // 约为3列中2列的宽度
          child: gridWidget,
        ),
      );
    }

    return gridWidget;
  }

  /// 构建单个图片
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
          // 网络图片加载失败时静默处理
          return Container(
            color: Colors.grey[300],
            child:
                const Icon(Icons.broken_image, color: Colors.white, size: 30),
          );
        },
      );
    } else {
      // 本地文件，先检查文件是否存在
      final file = File(imagePath);
      if (!file.existsSync()) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.white, size: 30),
        );
      }

      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // 本地图片加载失败时静默处理
          return Container(
            color: Colors.grey[300],
            child:
                const Icon(Icons.broken_image, color: Colors.white, size: 30),
          );
        },
      );
    }
  }

  /// 获取所有图片路径
  List<String> _getImages() {
    final images = <String>[];

    // 1. 优先尝试本地图片路径
    final localPaths = _getListFromMetadata('localImagePaths');
    for (final path in localPaths) {
      if (_isValidPath(path)) {
        images.add(path);
      }
    }

    // 2. 如果没有可用的本地图片，尝试云端图片
    if (images.isEmpty) {
      final cloudUrls = _getListFromMetadata('cloudImageUrls');
      for (final url in cloudUrls) {
        if (_isValidPath(url)) {
          images.add(url);
        }
      }
    }

    // 3. 最后的备选方案：使用卡片原始图片
    if (images.isEmpty) {
      final originalPath = card.image.path;
      if (originalPath.isNotEmpty) {
        images.add(originalPath);
      }
    }

    return images;
  }

  /// 从 metadata 中安全获取列表
  List<String> _getListFromMetadata(String key) {
    final data = card.metadata[key];
    if (data == null) return [];

    if (data is List) {
      return data.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }

    return [];
  }

  /// 验证路径是否有效
  bool _isValidPath(String path) {
    if (path.isEmpty) return false;

    // 如果是网络图片，检查URL格式
    if (path.startsWith('http')) {
      return path.startsWith('http://') || path.startsWith('https://');
    }

    // 如果是本地图片，检查文件是否存在
    try {
      return File(path).existsSync();
    } catch (e) {
      return false;
    }
  }

  /// 格式化时间显示
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return DateFormat('MM月dd日').format(time);
    }
  }

  /// 构建点赞和评论互动区域
  Widget _buildInteractionSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 点赞列表
          _buildLikeSection(context),

          // 评论列表
          if (_hasMockComments()) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Divider(height: 1, color: Colors.grey[300]),
            ),
            _buildCommentSection(context),
          ],
        ],
      ),
    );
  }

  /// 构建点赞区域
  Widget _buildLikeSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.favorite,
          size: 14,
          color: Color(0xFFE94444),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: context.l10n('迹见文案'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF576B95),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_shouldShowMultipleLikes()) ...[
                  TextSpan(
                    text: '，${context.l10n('AI助手')}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF576B95),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建评论区域
  Widget _buildCommentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentItem(context.l10n('AI助手'), context.l10n('真不错！👍')),
        if (card.selectedPlace != null)
          _buildCommentItem(
            context.l10n('迹见文案'),
            context
                .l10n('回复 AI助手：谢谢！在{place}拍的')
                .replaceAll('{place}', card.selectedPlace!.name),
          ),
      ],
    );
  }

  /// 构建单条评论
  Widget _buildCommentItem(String userName, String comment) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: userName,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF576B95),
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: '：$comment',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 判断是否显示多个点赞
  bool _shouldShowMultipleLikes() {
    // 如果有地点信息，显示两个点赞
    return card.selectedPlace != null;
  }

  /// 判断是否显示评论
  bool _hasMockComments() {
    // 总是显示至少一条评论
    return true;
  }
}
