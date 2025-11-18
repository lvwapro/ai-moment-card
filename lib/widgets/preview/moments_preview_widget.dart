import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../../models/poetry_card.dart';
import '../../services/language_service.dart';
import 'package:intl/intl.dart';
import 'phone_status_bar.dart';

/// 朋友圈预览组件
/// 模拟微信朋友圈的显示效果
class MomentsPreviewWidget extends StatelessWidget {
  final PoetryCard card;

  const MomentsPreviewWidget({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) => _buildMomentsContent(context);

  /// 构建朋友圈内容
  Widget _buildMomentsContent(BuildContext context) => Container(
        color: Colors.white, // 改为白色背景
        child: Stack(
          children: [
            // 主内容区域（可以往上拉）
            SingleChildScrollView(
              physics:
                  const ClampingScrollPhysics(), // 使用ClampingScrollPhysics，防止过度滚动
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头部留白区域、内容卡片和头像组合
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        children: [
                          // 头部留白区域（朋友圈背景图）
                          Container(
                            height: 280,
                            clipBehavior: Clip.none, // 允许子元素超出边界
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/wechat_background.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Stack(
                              clipBehavior: Clip.none, // 允许子元素超出边界
                              children: [
                                // 昵称（右下）
                                Positioned(
                                  right: 64, // 头像宽度64 + 间距16
                                  bottom: -4, // 调整为正值，避免被裁剪
                                  child: Text(
                                    context.l10n('拾光记'),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 朋友圈内容卡片
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.fromLTRB(
                                16, 48, 16, 16), // 顶部留出头像空间
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 头像
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    width: 32, // 从36改为32
                                    height: 32,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: 32,
                                      height: 32,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // 昵称、文案、图片和时间
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 昵称
                                      Text(
                                        context.l10n('拾光记'),
                                        style: const TextStyle(
                                          fontSize: 14, // 从16改为14
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF576B95), // 微信蓝
                                        ),
                                      ),
                                      const SizedBox(height: 4), // 从8改为4

                                      // 文案内容
                                      if (card.pengyouquan != null &&
                                          card.pengyouquan!.isNotEmpty) ...[
                                        Text(
                                          card.pengyouquan!,
                                          style: const TextStyle(
                                            fontSize: 15, // 从16改为15
                                            height: 1.4,
                                            color: Color(0xFF333333),
                                            fontWeight: FontWeight.w500, // 加粗
                                          ),
                                        ),
                                        const SizedBox(height: 8), // 文案和图片之间的间距
                                      ],

                                      // 图片网格
                                      _buildImageGrid(),

                                      const SizedBox(height: 8),

                                      // 时间、地点和操作按钮行
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center, // 垂直居中
                                        children: [
                                          // 左侧：时间和地点
                                          Expanded(
                                            child: Row(
                                              children: [
                                                // 时间
                                                Text(
                                                  _formatTime(
                                                      card.createdAt, context),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),

                                                // 地点（如果有）
                                                if (card.selectedPlace !=
                                                    null) ...[
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

                                          // 右侧：更多操作按钮（••）
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF7F7F7),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 1, // 从3改为1，更扁平
                                            ),
                                            alignment: Alignment.center, // 内容居中
                                            child: Text(
                                              '••',
                                              style: TextStyle(
                                                color: Color(
                                                    0xFF576B95), // 改为微信蓝，和昵称颜色一致
                                                fontSize: 18,
                                                height: 1.0,
                                                letterSpacing:
                                                    0.5, // 从2.0改为0.5，两个点之间距离更小
                                              ),
                                              textAlign: TextAlign.center,
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
                          ),
                        ],
                      ),

                      // 头像（跨越色块和白色区域的交界线，放在最后以显示在最上层）
                      Positioned(
                        right: 16,
                        top: 280 - 32, // 调整位置，让头像小一点后位置协调
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 48, // 从64改为48，变小
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[600],
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 分隔线
                  Container(
                    height: 1,
                    color: Color(0xFFF5F5F5), // 浅灰色背景
                  ),

                  // 添加一条虚假的朋友圈作为占位
                  _buildPlaceholderMoment(context),
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

            // 固定的顶部导航栏图标（不随内容滚动）
            const Positioned(
              top: 44 + 16, // 状态栏高度44 + 顶部间距16 (往上移)
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
                  Spacer(),
                  Icon(Icons.camera_alt_outlined,
                      size: 18, color: Colors.white),
                ],
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

    final imageCount = images.length > 9 ? 9 : images.length; // 最多显示9张

    // 单张图片时特殊处理 - 显示更大，固定比例
    if (imageCount == 1) {
      return _buildSingleImage(images[0]);
    }

    // 确定列数：4张图片时用2列，其他情况用3列
    final crossAxisCount = imageCount == 4 ? 2 : 3;

    // 4张图片时限制宽度，其他情况填满
    final gridWidget = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero, // 去掉默认padding
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // 4张图片时2列，其他情况3列
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1, // 1:1 正方形
      ),
      itemCount: imageCount,
      itemBuilder: (context, index) {
        return _buildImage(images[index]); // 多图不使用圆角
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

    // 其他多图情况，限制宽度不要占满整行
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.85, // 限制为85%宽度，右边留出空间
        child: gridWidget,
      ),
    );
  }

  /// 构建单张大图
  Widget _buildSingleImage(String imagePath) {
    return FutureBuilder<Size>(
      future: _getImageSize(imagePath),
      builder: (context, snapshot) {
        // 默认使用3:2比例（横图）
        double aspectRatio = 3 / 2;

        if (snapshot.hasData) {
          final size = snapshot.data!;
          // 判断是横图还是竖图
          if (size.width > size.height) {
            // 横图 3:2
            aspectRatio = 3 / 2;
          } else {
            // 竖图 2:3
            aspectRatio = 2 / 3;
          }
        }

        return Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.65, // 限制宽度为65%，参考真实朋友圈效果
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildImage(imagePath),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 获取图片尺寸
  Future<Size> _getImageSize(String imagePath) async {
    final isUrl = imagePath.startsWith('http');

    if (isUrl) {
      // 网络图片
      final imageProvider = NetworkImage(imagePath);
      final completer = Completer<Size>();
      final stream = imageProvider.resolve(const ImageConfiguration());

      stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }));

      return completer.future;
    } else {
      // 本地文件
      final file = File(imagePath);
      if (!file.existsSync()) {
        return const Size(3, 2); // 默认横图
      }

      final imageProvider = FileImage(file);
      final completer = Completer<Size>();
      final stream = imageProvider.resolve(const ImageConfiguration());

      stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }));

      return completer.future;
    }
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
    // 使用统一的方法获取本地图片路径
    return card.getLocalImagePaths();
  }

  /// 格式化时间显示
  String _formatTime(DateTime time, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return context.l10n('刚刚');
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}${context.l10n('分钟前')}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}${context.l10n('小时前')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}${context.l10n('天前')}';
    } else {
      return DateFormat('MM月dd日').format(time);
    }
  }

  /// 构建点赞和评论互动区域
  Widget _buildInteractionSection(BuildContext context) => Container(
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Divider(height: 1, color: Colors.grey[300]),
            ),
            _buildCommentSection(context),
          ],
        ),
      );

  /// 构建点赞区域
  Widget _buildLikeSection(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0), // 从2改为0，往上移
            child: Image.asset(
              'assets/images/weixin_love.png',
              width: 18, // 放大从16到18
              height: 18,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.favorite,
                size: 18,
                color: Color(0xFF5C80C5),
              ),
            ),
          ),
          const SizedBox(width: 2), // 从6改为4，减小间距
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: context.l10n('拾光记'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF576B95),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  /// 构建评论区域
  Widget _buildCommentSection(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentItem(context.l10n('AI助手'), context.l10n('真不错！👍')),
          _buildCommentReplyItem(
            context.l10n('拾光记'),
            context.l10n('AI助手'),
            '哈哈哈哈🌹',
          ),
        ],
      );

  /// 构建单条评论
  Widget _buildCommentItem(String userName, String comment) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: userName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF576B95),
                ),
              ),
              TextSpan(
                text: '：$comment',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );

  /// 构建回复评论
  Widget _buildCommentReplyItem(
          String userName, String replyTo, String comment) =>
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: userName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF576B95),
                ),
              ),
              TextSpan(
                text: '回复',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              TextSpan(
                text: replyTo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF576B95),
                ),
              ),
              TextSpan(
                text: '：$comment',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );

  /// 构建占位朋友圈（虚假内容）
  Widget _buildPlaceholderMoment(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16), // 顶部从16改为8，让横线更靠近
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 32, // 从36改为32
                height: 32,
                color: Colors.grey[400],
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 昵称
                  Text(
                    context.l10n('好友'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF576B95),
                    ),
                  ),
                  const SizedBox(height: 4), // 从8改为4

                  // 文案
                  Text(
                    context.l10n('生活就像一场旅行，不在乎目的地，在乎的是沿途的风景...'),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 时间
                  Text(
                    context.l10n('1天前'),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
