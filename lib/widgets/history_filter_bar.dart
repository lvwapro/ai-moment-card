import 'package:ai_poetry_card/models/poetry_card.dart';
import 'package:flutter/material.dart';

import '../models/time_filter.dart';
import 'time_filter_widget.dart';
import 'package:ai_poetry_card/services/language_service.dart';

class HistoryFilterBar extends StatelessWidget {
  final String searchQuery;
  final PoetryStyle? selectedStyle;
  final TimeFilterType? selectedTimeFilter;
  final DateTimeRange? customTimeRange;
  final bool isGridView;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<PoetryStyle?> onStyleChanged;
  final ValueChanged<TimeFilterType?> onTimeFilterChanged;
  final ValueChanged<DateTimeRange?> onCustomTimeRangeChanged;
  final ValueChanged<bool> onViewModeChanged;

  const HistoryFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedStyle,
    required this.selectedTimeFilter,
    required this.customTimeRange,
    required this.isGridView,
    required this.onSearchChanged,
    required this.onStyleChanged,
    required this.onTimeFilterChanged,
    required this.onCustomTimeRangeChanged,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 搜索框
            TextField(
              onChanged: onSearchChanged,
              style: TextStyle(color: Theme.of(context).primaryColor),
              decoration: InputDecoration(
                hintText: context.l10n('搜索文案内容...'),
                hintStyle: TextStyle(
                    color: Theme.of(context).primaryColor.withOpacity(0.6)),
                prefixIcon:
                    Icon(Icons.search, color: Theme.of(context).primaryColor),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: Theme.of(context).primaryColor),
                        onPressed: () => onSearchChanged(''),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 筛选器
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // 风格筛选
                      _FilterChip(
                        label: context.l10n('风格'),
                        value: selectedStyle != null
                            ? _getStyleName(selectedStyle!)
                            : null,
                        onTap: () => _showStyleFilter(context),
                      ),

                      // 时间筛选
                      _FilterChip(
                        label: context.l10n('时间'),
                        value: selectedTimeFilter != null
                            ? TimeFilterWidget.getTimeFilterDisplayValue(
                                selectedTimeFilter, customTimeRange)
                            : null,
                        onTap: () => TimeFilterWidget.showTimeFilter(
                          context,
                          selectedTimeFilter: selectedTimeFilter,
                          customTimeRange: customTimeRange,
                          onTimeFilterChanged: onTimeFilterChanged,
                          onCustomTimeRangeChanged: onCustomTimeRangeChanged,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 展示样式按钮
                _ViewModeButton(
                  isGridView: isGridView,
                  onTap: () => onViewModeChanged(!isGridView),
                ),
              ],
            ),
          ],
        ),
      );

  void _showStyleFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n('选择风格'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...PoetryStyle.values.map((style) {
                final isSelected = selectedStyle == style;
                return ListTile(
                  title: Text(context.l10n(_getStyleName(style))),
                  subtitle: Text(context.l10n(_getStyleDescription(style))),
                  leading: Radio<PoetryStyle>(
                    value: style,
                    groupValue: selectedStyle,
                    onChanged: (value) {
                      onStyleChanged(value);
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    onStyleChanged(isSelected ? null : style);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              if (selectedStyle != null) ...[
                const Divider(),
                ListTile(
                  title: Text(context.l10n('清除筛选')),
                  leading: const Icon(Icons.clear),
                  onTap: () {
                    onStyleChanged(null);
                    Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getStyleName(PoetryStyle style) {
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

  String _getStyleDescription(PoetryStyle style) {
    switch (style) {
      case PoetryStyle.modernPoetic:
        return '空灵抽象，富有意象和哲思';
      case PoetryStyle.classicalElegant:
        return '古典诗词韵律，典雅有文化底蕴';
      case PoetryStyle.humorousPlayful:
        return '网络热梗，轻松有趣';
      case PoetryStyle.warmLiterary:
        return '治愈系语录，温暖细腻有共鸣';
      case PoetryStyle.minimalTags:
        return '极简标签，干净版面';
      case PoetryStyle.sciFiImagination:
        return '科幻视角，未来感宏大叙事';
      case PoetryStyle.deepPhilosophical:
        return '引发思考，理性深沉';
      case PoetryStyle.blindBox:
        return '随机惊喜，未知体验';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: value != null
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 4),
                Text(
                  ': $value',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: value != null
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      );
}

class _ViewModeButton extends StatelessWidget {
  final bool isGridView;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.isGridView,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            isGridView ? Icons.list : Icons.grid_view,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
      );
}
