import 'package:flutter/material.dart';
import 'package:ai_poetry_card/services/language_service.dart';

class GenerateButtonWidget extends StatelessWidget {
  final bool isGenerating;
  final bool hasImages;
  final VoidCallback onPressed;

  const GenerateButtonWidget({
    super.key,
    required this.isGenerating,
    required this.hasImages,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: (isGenerating || !hasImages) ? null : onPressed,
          icon: isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(
            isGenerating
                ? context.l10n('AI创作中...')
                : !hasImages
                    ? context.l10n('请先选择图片')
                    : context.l10n('生成文案'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: (isGenerating || !hasImages)
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: (isGenerating || !hasImages) ? 0 : 4, // 禁用状态无阴影，启用状态有阴影
            shadowColor:
                Theme.of(context).primaryColor.withOpacity(0.3), // 阴影颜色
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // 增加圆角
            ),
          ),
        ),
      );
}
