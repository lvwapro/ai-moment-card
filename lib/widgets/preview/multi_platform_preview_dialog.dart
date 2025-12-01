import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/poetry_card.dart';
import '../../providers/app_state.dart';
import '../../services/language_service.dart';
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
  
  /// 根据常用文案（默认平台）重新排序平台列表
  /// 常用文案排在第一位
  static List<PlatformType> _reorderPlatforms(
      List<PlatformType> platforms, PlatformType defaultPlatform) {
    final reordered = <PlatformType>[];
    final addedPlatforms = <PlatformType>{};
    
    // 首先添加常用文案（默认平台），如果在列表中
    if (platforms.contains(defaultPlatform)) {
      reordered.add(defaultPlatform);
      addedPlatforms.add(defaultPlatform);
    }
    
    // 然后按顺序添加其他平台
    for (final platform in platforms) {
      if (!addedPlatforms.contains(platform)) {
        reordered.add(platform);
      }
    }
    
    return reordered;
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
  List<PlatformType>? _orderedPlatforms;

  // 获取平台名称（使用翻译）
  String _getPlatformName(BuildContext context, PlatformType platform) {
    switch (platform) {
      case PlatformType.pengyouquan:
        return context.l10n('朋友圈');
      case PlatformType.xiaohongshu:
        return context.l10n('小红书');
      case PlatformType.weibo:
        return context.l10n('微博');
      case PlatformType.douyin:
        return context.l10n('抖音');
      case PlatformType.duilian:
        return context.l10n('对联');
      case PlatformType.shiju:
        return context.l10n('诗句');
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = 0; // 总是从第一个（常用文案）开始
    _pageController = PageController(initialPage: 0);
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
    // 在 build 方法中获取 AppState 并排序平台列表
    final appState = Provider.of<AppState>(context, listen: false);
    final orderedPlatforms = _orderedPlatforms ??=
        MultiPlatformPreviewDialog._reorderPlatforms(
      widget.platforms,
      appState.defaultPlatform,
    );
    
    final contentHeight = widget.contentWidth * widget.aspectRatio;
    final isMultiPlatform = orderedPlatforms.length > 1;

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
                                        itemCount: orderedPlatforms.length,
                                        itemBuilder: (context, index) {
                                          return _buildPlatformWidget(
                                              orderedPlatforms[index]);
                                        },
                                      )
                                    : _buildPlatformWidget(orderedPlatforms[0]),
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
                                  'assets/images/phone_border.png',
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
                              (_currentIndex + 1) % orderedPlatforms.length;
                          _pageController.animateToPage(
                            nextIndex,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6F6F6F),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                orderedPlatforms.length,
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
                                      _getPlatformName(
                                          context, orderedPlatforms[index]),
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
                      ),

                    // 单平台时关闭按钮前的额外间距
                    if (!isMultiPlatform) const SizedBox(height: 30),

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

          if (isMultiPlatform && _currentIndex < orderedPlatforms.length - 1)
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
