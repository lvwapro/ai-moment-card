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
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF8B0000),
                  child: const Center(
                    child: Text(
                      '对联背景图加载失败',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              // 对联文字内容 - 相对于图片固定位置
              // 横批（顶部横幅位置）- 占图片宽度的百分比，内容占满该区域
              Positioned(
                top: imageHeight * 0.04, // 固定位置：再往上移，约4%处
                left: imageWidth * 0.3, // 左侧边距，进一步缩小横批宽度
                right: imageWidth * 0.3, // 右侧边距
                child: SizedBox(
                  width: imageWidth * 0.4, // 占图片宽度的40%，进一步缩小宽度
                  height: 55, // 增加高度，给字体更多空间
                  child: FittedBox(
                    fit: BoxFit.fitWidth, // 占满宽度，确保文字填满整个区域
                    alignment: Alignment.center,
                    child: Text(
                      duilian.horizontal,
                      style: const TextStyle(
                        fontFamily: 'YanShiXiaXingKai',
                        fontSize: 50, // 大幅增加字体基准值，即使缩放后也会更大
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0), // 金色
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

              // 上联（左侧垂直面板）- 使用图片高度百分比，文字占满高度
              Positioned(
                top: imageHeight * 0.12, // 固定位置：再往上移，约12%处
                left: imageWidth * 0.01, // 左侧边距，更往外移
                child: SizedBox(
                  width: imageWidth * 0.25, // 固定宽度
                  height: imageHeight * 0.72, // 占图片高度的72%，增加高度
                  child: FittedBox(
                    fit: BoxFit.fitHeight, // 文字占满高度
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 均匀分布
                      children: upperChars
                          .map((char) => Text(
                                char,
                                style: const TextStyle(
                                  fontFamily: 'YanShiXiaXingKai',
                                  fontSize: 20, // 基准字体大小
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 0, 0, 0), // 金色
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
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),

              // 下联（右侧垂直面板）- 使用图片高度百分比，文字占满高度
              Positioned(
                top: imageHeight * 0.12, // 固定位置：再往上移，与上联对齐，约12%处
                right: imageWidth * 0.01, // 右侧边距，更往外移
                child: SizedBox(
                  width: imageWidth * 0.25, // 固定宽度
                  height: imageHeight * 0.72, // 占图片高度的72%，与上联一致，增加高度
                  child: FittedBox(
                    fit: BoxFit.fitHeight, // 文字占满高度
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 均匀分布
                      children: lowerChars
                          .map((char) => Text(
                                char,
                                style: const TextStyle(
                                  fontFamily: 'YanShiXiaXingKai',
                                  fontSize: 20, // 基准字体大小
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 0, 0, 0), // 金色
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
                              ))
                          .toList(),
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
