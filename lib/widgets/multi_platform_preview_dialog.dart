import 'package:flutter/material.dart';
import '../models/poetry_card.dart';
import '../providers/app_state.dart';
import 'douyin_preview_widget.dart';
import 'moments_preview_widget.dart';
import 'weibo_preview_widget.dart';
import 'xiaohongshu_preview_widget.dart';
import 'duilian_preview_widget.dart';
import 'preview_text_scale.dart';

/// 多平台预览弹窗
/// 支持单个或多个平台的预览，左右切换
class MultiPlatformPreviewDialog extends StatefulWidget {
  final PoetryCard card;
  final List<PlatformType> platforms; // 要预览的平台列表
  final int initialIndex;

  // 手机外框配置
  final double contentWidth;
  final double aspectRatio;
  final double phoneScale;

  /// 创建多平台预览（默认显示所有平台）
  /// 会根据卡片数据动态过滤平台列表（例如：只有有对联数据时才显示对联）
  MultiPlatformPreviewDialog({
    super.key,
    required this.card,
    List<PlatformType>? platforms,
    this.initialIndex = 0,
    this.contentWidth = 300,
    this.aspectRatio = 163.4 / 78,
    this.phoneScale = 0.82,
  }) : platforms = platforms ??
            _getDefaultPlatforms(card);

  /// 根据卡片数据获取默认平台列表
  /// 只包含卡片有数据的平台
  static List<PlatformType> _getDefaultPlatforms(PoetryCard card) {
    final platforms = <PlatformType>[
      PlatformType.pengyouquan,
      if (card.xiaohongshu != null && card.xiaohongshu!.isNotEmpty)
        PlatformType.xiaohongshu,
      if (card.weibo != null && card.weibo!.isNotEmpty) PlatformType.weibo,
      if (card.douyin != null && card.douyin!.isNotEmpty) PlatformType.douyin,
      // 只有有对联数据时才显示对联
      if (card.duilian != null) PlatformType.duilian,
    ];
    return platforms;
  }

  /// 创建单平台预览
  factory MultiPlatformPreviewDialog.single({
    required PoetryCard card,
    required PlatformType platform,
    double contentWidth = 300,
    double aspectRatio = 163.4 / 78,
    double phoneScale = 0.82,
  }) {
    return MultiPlatformPreviewDialog(
      card: card,
      platforms: [platform],
      initialIndex: 0,
      contentWidth: contentWidth,
      aspectRatio: aspectRatio,
      phoneScale: phoneScale,
    );
  }

  @override
  State<MultiPlatformPreviewDialog> createState() =>
      _MultiPlatformPreviewDialogState();
}

class _MultiPlatformPreviewDialogState
    extends State<MultiPlatformPreviewDialog> {
  late PageController _pageController;
  int _currentIndex = 0;

  // 平台名称映射
  static const Map<PlatformType, String> _platformNames = {
    PlatformType.pengyouquan: '朋友圈',
    PlatformType.xiaohongshu: '小红书',
    PlatformType.weibo: '微博',
    PlatformType.douyin: '抖音',
    PlatformType.duilian: '对联',
  };

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 根据平台类型创建对应的预览组件
  Widget _buildPlatformWidget(PlatformType platform) {
    Widget content;
    switch (platform) {
      case PlatformType.pengyouquan:
        content = MomentsPreviewWidget(card: widget.card);
        break;
      case PlatformType.xiaohongshu:
        content = XiaohongshuPreviewWidget(card: widget.card);
        break;
      case PlatformType.weibo:
        content = WeiboPreviewWidget(card: widget.card);
        break;
      case PlatformType.douyin:
        content = DouyinPreviewWidget(card: widget.card);
        break;
      case PlatformType.shiju:
        // 如果需要诗句预览，可以添加对应组件
        content = MomentsPreviewWidget(card: widget.card); // 临时使用朋友圈
        break;
      case PlatformType.duilian:
        content = DuilianPreviewWidget(card: widget.card);
        break;
    }

    // 应用文本缩放
    return PreviewTextScale(
      scaleFactor: 0.88, // 缩小到88%
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentHeight = widget.contentWidth * widget.aspectRatio;
    final isMultiPlatform = widget.platforms.length > 1;

    // 间距
    final contentToBarSpacing = isMultiPlatform ? 40.0 : 0.0; // 减少到40px

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7), // 加深背景颜色到70%
      body: Stack(
        children: [
          // 主要内容区域（垂直水平居中）
          Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(), // 禁止滚动，只是为了防止溢出
              child: Padding(
                padding: const EdgeInsets.only(top: 60), // 增加顶部padding，让内容往下移
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 手机预览区域
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50), // 添加水平padding，防止边框被裁剪
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 手机屏幕内容（底层，有20px顶部偏移）
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                              width: widget.contentWidth,
                              height: contentHeight,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(38),
                                child: isMultiPlatform
                                    ? PageView.builder(
                                        controller: _pageController,
                                        onPageChanged: (index) {
                                          setState(() {
                                            _currentIndex = index;
                                          });
                                        },
                                        itemCount: widget.platforms.length,
                                        itemBuilder: (context, index) {
                                          return _buildPlatformWidget(
                                              widget.platforms[index]);
                                        },
                                      )
                                    : _buildPlatformWidget(widget.platforms[0]),
                              ),
                            ),
                          ),

                          // 手机边框图片（最上层，但不拦截触摸事件）
                          Positioned(
                            top: -32,
                            left: -38,
                            child: IgnorePointer(
                              child: SizedBox(
                                width: widget.contentWidth / widget.phoneScale,
                                height: contentHeight / widget.phoneScale - 41,
                                child: Image.asset(
                                  'assets/phone_border.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 内容到bar的间距
                    SizedBox(height: contentToBarSpacing),

                    // 平台指示器（仅多平台时显示）
                    if (isMultiPlatform)
                      GestureDetector(
                        onTap: () {
                          // 点击切换到下一个平台
                          final nextIndex =
                              (_currentIndex + 1) % widget.platforms.length;
                          _pageController.animateToPage(
                            nextIndex,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6F6F6F),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              widget.platforms.length,
                              (index) => GestureDetector(
                                onTap: () {
                                  // 点击具体平台名称切换到该平台
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    _platformNames[widget.platforms[index]] ??
                                        '',
                                    style: TextStyle(
                                      color: _currentIndex == index
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.5),
                                      fontSize:
                                          _currentIndex == index ? 15 : 13,
                                      fontWeight: _currentIndex == index
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // 关闭按钮
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF6F6F6F),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 左右切换提示箭头（仅多平台时显示）
          if (isMultiPlatform && _currentIndex > 0)
            Positioned(
              left: 5,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // 点击左箭头切换到上一个平台
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6F6F6F),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

          if (isMultiPlatform && _currentIndex < widget.platforms.length - 1)
            Positioned(
              right: 5,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // 点击右箭头切换到下一个平台
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6F6F6F),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
