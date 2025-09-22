import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/poetry_card.dart';
import '../theme/app_theme.dart';

class StyleSelectorWidget extends StatelessWidget {
  const StyleSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择风格',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Consumer<AppState>(
            builder: (context, appState, child) => Column(
              children: [
                // 第一行：盲盒 + 主流风格
                Row(
                  children: [
                    Expanded(
                      child: _StyleOption(
                        title: '盲盒',
                        description: '随机惊喜',
                        isSelected:
                            appState.selectedStyle == PoetryStyle.blindBox,
                        onTap: () =>
                            appState.setSelectedStyle(PoetryStyle.blindBox),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StyleOption(
                        title: '现代诗意',
                        description: '空灵抽象',
                        isSelected:
                            appState.selectedStyle == PoetryStyle.modernPoetic,
                        onTap: () =>
                            appState.setSelectedStyle(PoetryStyle.modernPoetic),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StyleOption(
                        title: '古风雅韵',
                        description: '古典诗词',
                        isSelected:
                            appState.selectedStyle ==
                            PoetryStyle.classicalElegant,
                        onTap: () => appState.setSelectedStyle(
                          PoetryStyle.classicalElegant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 第二行：情感风格
                Row(
                  children: [
                    Expanded(
                      child: _StyleOption(
                        title: '幽默俏皮',
                        description: '轻松有趣',
                        isSelected:
                            appState.selectedStyle ==
                            PoetryStyle.humorousPlayful,
                        onTap: () => appState.setSelectedStyle(
                          PoetryStyle.humorousPlayful,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StyleOption(
                        title: '文艺暖心',
                        description: '治愈系',
                        isSelected:
                            appState.selectedStyle == PoetryStyle.warmLiterary,
                        onTap: () =>
                            appState.setSelectedStyle(PoetryStyle.warmLiterary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StyleOption(
                        title: '极简摘要',
                        description: '干净版面',
                        isSelected:
                            appState.selectedStyle == PoetryStyle.minimalTags,
                        onTap: () =>
                            appState.setSelectedStyle(PoetryStyle.minimalTags),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 第三行：特殊风格
                Row(
                  children: [
                    Expanded(
                      child: _StyleOption(
                        title: '科幻想象',
                        description: '未来感',
                        isSelected:
                            appState.selectedStyle ==
                            PoetryStyle.sciFiImagination,
                        onTap: () => appState.setSelectedStyle(
                          PoetryStyle.sciFiImagination,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StyleOption(
                        title: '深沉哲思',
                        description: '理性思考',
                        isSelected:
                            appState.selectedStyle ==
                            PoetryStyle.deepPhilosophical,
                        onTap: () => appState.setSelectedStyle(
                          PoetryStyle.deepPhilosophical,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Container()), // 占位
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleOption extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleOption({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.15)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    ),
  );
}
