import 'package:flutter/material.dart';
import 'dart:io';
import '../models/poetry_card.dart';
import '../services/language_service.dart';
import 'phone_status_bar.dart';

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
  final ScrollController _navScrollController = ScrollController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // 延迟滚动到最右边，让右侧内容优先显示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_navScrollController.hasClients) {
        _navScrollController
            .jumpTo(_navScrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _buildDouyinContent(context);

  /// 构建抖音内容
  Widget _buildDouyinContent(BuildContext context) => Container(
        color: Colors.black,
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

            // 底部导航栏
            _buildBottomNavBar(context),

            // 状态栏（固定在最顶层）
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: PhoneStatusBar(
                textColor: Colors.white, // 抖音背景是黑色，使用白色文字
              ),
            ),
          ],
        ),
      );

  /// 构建内容区域（图片/视频）
  Widget _buildContentArea() {
    final images = _getImages();

    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
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
        width: double.infinity,
        height: double.infinity,
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
      width: double.infinity,
      height: double.infinity,
      child: _buildImage(images[0]),
    );
  }

  /// 构建单张图片
  Widget _buildImage(String imagePath) {
    final isUrl = imagePath.startsWith('http');

    if (isUrl) {
      return Center(
        child: Image.network(
          imagePath,
          fit: BoxFit.contain,
          width: double.infinity,
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

      return Center(
        child: Image.file(
          file,
          fit: BoxFit.contain,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.black,
            child:
                const Icon(Icons.broken_image, color: Colors.white38, size: 60),
          ),
        ),
      );
    }
  }

  /// 构建顶部导航栏
  Widget _buildTopNavBar(BuildContext context) => Positioned(
        top: 44, // 状态栏高度
        left: 0,
        right: 0,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 左侧菜单图标
              SizedBox(
                width: 36,
                height: 36,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),

              // 中间导航标签
              Expanded(
                child: SingleChildScrollView(
                  controller: _navScrollController,
                  scrollDirection: Axis.horizontal,
                  reverse: false,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildNavTab(context, context.l10n('深圳'),
                            isSelected: false),
                        const SizedBox(width: 12),
                        _buildNavTab(context, context.l10n('团购'),
                            isSelected: false),
                        const SizedBox(width: 12),
                        _buildNavTab(context, context.l10n('关注'),
                            isSelected: false),
                        const SizedBox(width: 12),
                        _buildNavTab(context, context.l10n('商城'),
                            isSelected: false),
                        const SizedBox(width: 12),
                        _buildNavTab(context, context.l10n('经验'),
                            isSelected: false),
                        const SizedBox(width: 12),
                        _buildNavTab(context, context.l10n('推荐'),
                            isSelected: true),
                      ],
                    ),
                  ),
                ),
              ),

              // 右侧搜索图标
              SizedBox(
                width: 36,
                height: 36,
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      );

  /// 构建单个导航标签
  Widget _buildNavTab(
    BuildContext context,
    String text, {
    bool isSelected = false,
  }) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: isSelected ? 16 : 13,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          // 选中指示器
          if (isSelected)
            Container(
              width: 20,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
              ),
            )
          else
            const SizedBox(height: 2),
        ],
      );

  /// 构建图片指示器
  Widget _buildImageIndicator() {
    final images = _getImages();
    final imageCount = images.length > 9 ? 9 : images.length;

    return Positioned(
      bottom: 75,
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
    final images = _getImages();
    final hasImageIndicator = images.length > 1;
    final bottomOffset = hasImageIndicator ? 90.0 : 75.0;

    return Positioned(
      bottom: bottomOffset,
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // 文案内容
          if (widget.card.douyin != null && widget.card.douyin!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: widget.card.douyin!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  TextSpan(
                    text: ' ${context.l10n('展开')}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ],
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
              color: const Color(0xFF282828).withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/douyin_share.png',
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
                const SizedBox(width: 6),
                // 小头像
                ClipOval(
                  child: Image.asset(
                    'assets/images/avatar.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 20,
                      height: 20,
                      color: Colors.grey,
                      child: const Icon(Icons.person,
                          size: 12, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
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
    final images = _getImages();
    final hasImageIndicator = images.length > 1;
    final bottomOffset = hasImageIndicator ? 90.0 : 75.0;

    return Positioned(
      right: 12,
      bottom: bottomOffset,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头像
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36,
                height: 36,
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
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
              // 关注按钮
              Positioned(
                bottom: -8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: const Color(0xFFfd3661),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
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
            Icons.comment,
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
                'assets/images/douyin_share.png',
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
                  fontSize: 11,
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
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 构建底部导航栏
  Widget _buildBottomNavBar(BuildContext context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: const Color(0xFF1a1a1a), // 深灰色，不是纯黑
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 导航栏
              Container(
                height: 65,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 首页（选中状态）
                    _buildNavBarItem(context, context.l10n('首页'), true),

                    // 朋友
                    _buildNavBarItem(context, context.l10n('朋友'), false),

                    // 中间加号
                    Container(
                      width: 30,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),

                    // 消息
                    _buildNavBarItem(context, context.l10n('消息'), false),

                    // 我
                    _buildNavBarItem(context, context.l10n('我'), false),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  /// 构建导航栏单个项目
  Widget _buildNavBarItem(
          BuildContext context, String label, bool isSelected) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 2),
            Container(
              width: 16,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ],
      );

  /// 获取图片列表
  List<String> _getImages() {
    // 使用统一的方法获取本地图片路径
    return widget.card.getLocalImagePaths();
  }
}
