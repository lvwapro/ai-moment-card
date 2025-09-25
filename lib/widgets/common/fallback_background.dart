import 'package:flutter/material.dart';

/// 通用的fallback背景组件
class FallbackBackground extends StatelessWidget {
  final double? iconSize;
  final IconData? icon;
  final List<Color>? colors;

  const FallbackBackground({
    super.key,
    this.iconSize = 48,
    this.icon = Icons.image_not_supported,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColors = [
      Colors.blue.shade300,
      Colors.purple.shade300,
      Colors.pink.shade300,
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? defaultColors,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}

/// 为不同场景提供预设的fallback背景
class FallbackBackgrounds {
  /// 卡片预览用的fallback背景
  static Widget cardPreview() => const FallbackBackground(
        iconSize: 48,
        icon: Icons.image_not_supported,
      );

  /// 历史卡片用的fallback背景
  static Widget historyCard() => const FallbackBackground(
        iconSize: 24,
        icon: Icons.image_not_supported,
      );

  /// 图片选择用的fallback背景
  static Widget imageSelection() => const FallbackBackground(
        iconSize: 48,
        icon: Icons.broken_image,
        colors: [Colors.grey],
      );
}
