import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';
import 'package:ai_poetry_card/widgets/common/fallback_background.dart';
import '../providers/app_state.dart';

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
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
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

                      const SizedBox(height: 16),

                      // 底部信息
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 情绪标签（根据设置显示）
                          Consumer<AppState>(
                            builder: (context, appState, child) {
                              // 如果开启显示情绪标签且卡片有保存的情绪标签，显示情绪标签
                              if (appState.showMoodTagOnCard &&
                                  card.moodTag != null &&
                                  card.moodTag!.isNotEmpty) {
                                // 如果包含多个标签，只显示第一个
                                final displayTag =
                                    card.moodTag!.split(',').first;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    displayTag,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                              // 不显示
                              return const SizedBox.shrink();
                            },
                          ),

                          // 二维码和网页链接（根据设置显示）
                          Consumer<AppState>(
                            builder: (context, appState, child) {
                              if (!appState.showQrCode) {
                                return const SizedBox.shrink();
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // 二维码
                                  Image.asset(
                                    'assets/images/qrcode.jpg',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 4),
                                  // 网页链接
                                  Text(
                                    'softed.cn',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
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
    }
  }

  /// 构建背景图片，支持本地文件和网络URL
  Widget _buildBackgroundImage(PoetryCard card) {
    return FutureBuilder<ImageProvider?>(
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
  }

  /// 智能获取图片Provider：优先本地图片，其次云端图片
  Future<ImageProvider?> _getImageProvider(PoetryCard card) async {
    // 1. 优先尝试本地图片路径
    final localPaths = card.metadata['localImagePaths'] as List<dynamic>?;
    if (localPaths != null && localPaths.isNotEmpty) {
      for (var path in localPaths) {
        try {
          final localFile = File(path.toString());
          if (await localFile.exists()) {
            print('🖼️ 使用本地图片: $path');
            return FileImage(localFile);
          }
        } catch (e) {
          print('⚠️ 本地图片检查失败: $path, 错误: $e');
        }
      }
    }

    // 2. 尝试云端图片URL
    final cloudUrls = card.metadata['cloudImageUrls'] as List<dynamic>?;
    if (cloudUrls != null && cloudUrls.isNotEmpty) {
      for (var url in cloudUrls) {
        if (url.toString().startsWith('http')) {
          print('🖼️ 使用云端图片: $url');
          return NetworkImage(url.toString());
        }
      }
    }

    // 3. 使用卡片当前的图片路径
    if (card.image.path.startsWith('http')) {
      print('🖼️ 使用卡片URL图片: ${card.image.path}');
      return NetworkImage(card.image.path);
    } else {
      // 检查本地文件是否存在
      try {
        if (await card.image.exists()) {
          print('🖼️ 使用卡片本地图片: ${card.image.path}');
          return FileImage(card.image);
        }
      } catch (e) {
        print('⚠️ 卡片图片检查失败: ${card.image.path}, 错误: $e');
      }
    }

    // 4. 都不可用，返回null使用备用背景
    print('⚠️ 所有图片源都不可用，将使用备用背景');
    return null;
  }
}
