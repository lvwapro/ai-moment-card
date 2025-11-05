import 'package:flutter/material.dart';
import '../../models/poetry_card.dart';

/// 对联预览组件
/// 使用 duilian.png 作为底图，展示对联内容
class DuilianPreviewWidget extends StatelessWidget {
  final PoetryCard card;

  const DuilianPreviewWidget({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final duilian = card.duilian;

    if (duilian == null) {
      return Container(
        color: const Color(0xFF8B0000), // 深红色背景
        child: const Center(
          child: Text(
            '暂无对联数据',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // 固定图片尺寸
    const double imageWidth = 280.0;
    const double imageHeight = 400.0;

    // 将字符串拆分成字符列表，用于垂直展示
    final upperChars = duilian.upper.split('');
    final lowerChars = duilian.lower.split('');

    return Container(
      width: double.infinity,
      color: const Color(0xFF8B0000), // 深红色背景
      child: Center(
        child: SizedBox(
          width: imageWidth,
          height: imageHeight,
          child: Stack(
            children: [
              // 背景图片（duilian.png）- 固定尺寸，居中显示
              Image.asset(
                'assets/images/duilian.png',
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.contain, // 使用 contain 确保不拉伸，完整显示
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF8B0000),
                    child: const Center(
                      child: Text(
                        '对联背景图加载失败',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),

              // 对联文字内容 - 相对于图片固定位置
              // 横批（顶部横幅位置）
              Positioned(
                top: imageHeight * 0.12, // 固定位置：约12%处
                left: imageWidth * 0.1,
                right: imageWidth * 0.1,
                child: SizedBox(
                  width: imageWidth * 0.8,
                  height: 40,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        duilian.horizontal,
                        style: const TextStyle(
                          fontSize: 24, // 固定字体大小
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700), // 金色
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              // 上联（左侧垂直面板）
              Positioned(
                top: imageHeight * 0.28, // 固定位置：约28%处
                left: imageWidth * 0.08, // 左侧边距
                child: SizedBox(
                  width: imageWidth * 0.25, // 固定宽度
                  height: imageHeight * 0.5, // 固定高度
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: upperChars.map((char) {
                        return Text(
                          char,
                          style: const TextStyle(
                            fontSize: 20, // 基准字体大小
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD700), // 金色
                            height: 1.8, // 行高
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // 下联（右侧垂直面板）
              Positioned(
                top: imageHeight * 0.28, // 固定位置：约28%处
                right: imageWidth * 0.08, // 右侧边距
                child: SizedBox(
                  width: imageWidth * 0.25, // 固定宽度
                  height: imageHeight * 0.5, // 固定高度
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: lowerChars.map((char) {
                        return Text(
                          char,
                          style: const TextStyle(
                            fontSize: 20, // 基准字体大小
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD700), // 金色
                            height: 1.8, // 行高
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
