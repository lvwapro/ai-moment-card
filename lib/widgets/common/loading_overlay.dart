import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ai_poetry_card/services/language_service.dart';

/// 通用的Loading遮罩层组件
/// 用于首页生成和详情页重新生成时显示
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black.withOpacity(0.6), // 半透明黑色背景
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                height: 150,
                child: Lottie.asset(
                  'assets/animation/Live chatbot.json',
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
              ),
              Text(
                context.l10n('AI小助手努力创作中...'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
}
