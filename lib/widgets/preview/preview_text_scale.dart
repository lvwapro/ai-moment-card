import 'package:flutter/material.dart';

/// 预览文本缩放包装器
/// 用于统一缩小预览中的文字大小
class PreviewTextScale extends StatelessWidget {
  final Widget child;
  final double scaleFactor;

  const PreviewTextScale({
    super.key,
    required this.child,
    this.scaleFactor = 0.9, // 默认缩小到90%
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scaleFactor),
      ),
      child: child,
    );
  }
}
