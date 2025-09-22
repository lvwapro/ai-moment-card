import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';
import 'package:ai_poetry_card/services/card_design_service.dart';

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
  Widget build(BuildContext context) {
    final designService = CardDesignService();
    final config = designService.getTemplateConfig(card.template);

    return GestureDetector(
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
                child: Image.file(
                  card.image,
                  fit: BoxFit.cover,
                ),
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
                  children: [
                    // 主要文案
                    Text(
                      card.poetry,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: config['fontSize']?.toDouble() ?? 18,
                        fontWeight: config['fontWeight'] ?? FontWeight.w500,
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // 底部信息
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 风格标签
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getStyleDisplayName(card.style),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // 二维码（如果启用）
                        if (card.qrCodeData != null)
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: QrImageView(
                                data: card.qrCodeData!,
                                version: QrVersions.auto,
                                size: 32,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // 水印
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '诗意瞬间',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // 模板标签
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    designService.getTemplateName(card.template),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
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

  String _getStyleDisplayName(PoetryStyle style) {
    switch (style) {
      case PoetryStyle.modernPoetic:
        return '现代诗意';
      case PoetryStyle.classicalElegant:
        return '古风雅韵';
      case PoetryStyle.humorousPlayful:
        return '幽默俏皮';
      case PoetryStyle.warmLiterary:
        return '文艺暖心';
      case PoetryStyle.minimalTags:
        return '极简摘要';
      case PoetryStyle.sciFiImagination:
        return '科幻想象';
      case PoetryStyle.deepPhilosophical:
        return '深沉哲思';
      case PoetryStyle.blindBox:
        return '盲盒';
    }
  }
}
