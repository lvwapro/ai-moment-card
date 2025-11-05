import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';
import 'package:ai_poetry_card/widgets/common/fallback_background.dart';
import '../../providers/app_state.dart';
import '../../services/language_service.dart';

class PoetryCardWidget extends StatelessWidget {
  final PoetryCard card;
  final bool showControls;
  final VoidCallback? onTap;

  const PoetryCardWidget({
    super.key,
    required this.card,
    this.showControls = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 320,
          height: 480,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // 背景图片
                Positioned.fill(
                  child: _buildBackgroundImage(card),
                ),

                // 渐变遮罩
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                  ),
                ),

                // 应用名称（根据设置显示）
                Positioned(
                  top: 12,
                  left: 20,
                  child: Consumer<AppState>(
                    builder: (context, appState, child) {
                      // 如果开启显示情绪标签，显示应用名称
                      if (appState.showMoodTagOnCard) {
                        // 根据语言选择对应的图片
                        final imagePath = context.isChinese
                            ? 'assets/images/appName_zh.png'
                            : 'assets/images/appName_en.png';
                        return Image.asset(
                          imagePath,
                          height: 64,
                          fit: BoxFit.contain,
                        );
                      }
                      // 不显示
                      return const SizedBox.shrink();
                    },
                  ),
                ),

                // 二维码和网页链接（根据设置显示）
                Positioned(
                  top: 12,
                  right: 20,
                  child: Consumer<AppState>(
                    builder: (context, appState, child) {
                      if (!appState.showQrCode) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 二维码
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/qrcode.jpg',
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 网页链接
                          const Text(
                            'softed.cn',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // 文案内容
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 主要文案（根据默认平台显示）
                      Consumer<AppState>(
                        builder: (context, appState, child) {
                          final content =
                              _getDisplayContent(appState.defaultPlatform);
                          // 根据文字长度动态调整字体大小
                          double fontSize = 18;
                          double lineHeight = 1.4;

                          if (content.length > 200) {
                            fontSize = 14;
                            lineHeight = 1.2;
                          } else if (content.length > 100) {
                            fontSize = 16;
                            lineHeight = 1.3;
                          }

                          return Text(
                            content,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                              height: lineHeight,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  /// 根据默认平台获取要显示的文案内容
  String _getDisplayContent(PlatformType platform) {
    switch (platform) {
      case PlatformType.douyin:
        return card.douyin ?? card.poetry;
      case PlatformType.xiaohongshu:
        return card.xiaohongshu ?? card.poetry;
      case PlatformType.weibo:
        return card.weibo ?? card.poetry;
      case PlatformType.pengyouquan:
        return card.pengyouquan ?? card.poetry;
      case PlatformType.shiju:
        return card.shiju ?? card.poetry;
      case PlatformType.duilian:
        if (card.duilian != null) {
          return '${card.duilian!.horizontal}\n${card.duilian!.upper}\n${card.duilian!.lower}';
        }
        return card.poetry;
    }
  }

  /// 构建背景图片，支持本地文件和网络URL
  Widget _buildBackgroundImage(PoetryCard card) =>
      FutureBuilder<ImageProvider?>(
        future: _getImageProvider(card),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return Image(
              image: snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('❌ 图片加载失败，使用备用背景');
                return FallbackBackgrounds.cardPreview();
              },
            );
          } else {
            return FallbackBackgrounds.cardPreview();
          }
        },
      );

  /// 智能获取图片Provider：使用统一的 getFirstImagePath() 方法
  Future<ImageProvider?> _getImageProvider(PoetryCard card) async {
    // 使用统一的 getFirstImagePath() 方法获取首图
    final firstImagePath = card.getFirstImagePath();

    // 判断是本地图片还是网络 URL
    if (firstImagePath.startsWith('http')) {
      return NetworkImage(firstImagePath);
    } else {
      try {
        final localFile = File(firstImagePath);
        if (await localFile.exists()) {
          return FileImage(localFile);
        }
      } catch (e) {
        print('⚠️ 图片检查失败: $firstImagePath, 错误: $e');
      }
    }

    // 都不可用，返回null使用备用背景
    print('⚠️ 图片不可用，将使用备用背景');
    return null;
  }
}
