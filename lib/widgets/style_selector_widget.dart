import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/poetry_card.dart';
import 'package:ai_poetry_card/services/language_service.dart';
import '../utils/style_utils.dart';

//hct
class StyleSelectorWidget extends StatelessWidget {
  const StyleSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) => Container(
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
              context.l10n('选择风格'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Consumer<AppState>(
              builder: (context, appState, child) {
                final styleOptions = StyleUtils.getStyleOptions(context);
                final styleRows = StyleUtils.groupStylesIntoRows(styleOptions);

                return Column(
                  children: styleRows.asMap().entries.map((entry) {
                    final rowIndex = entry.key;
                    final row = entry.value;

                    return Column(
                      children: [
                        Row(
                          children: row.asMap().entries.map((itemEntry) {
                            final itemIndex = itemEntry.key;
                            final item = itemEntry.value;

                            return Expanded(
                              child: item.isEmpty
                                  ? Container() // 空占位符
                                  : Padding(
                                      padding: EdgeInsets.only(
                                        right: itemIndex < 2
                                            ? 8.0
                                            : 0.0, // 前两个添加右边距
                                      ),
                                      child: _StyleOption(
                                        title: item['title'] as String,
                                        isSelected: appState.selectedStyle ==
                                            item['style'],
                                        onTap: () => appState.setSelectedStyle(
                                            item['style'] as PoetryStyle),
                                      ),
                                    ),
                            );
                          }).toList(),
                        ),
                        if (rowIndex < styleRows.length - 1)
                          const SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      );
}

class _StyleOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 60, // 固定高度
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.15)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
}
