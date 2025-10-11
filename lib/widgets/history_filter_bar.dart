import 'package:ai_poetry_card/models/poetry_card.dart';
import 'package:flutter/material.dart';

import '../models/time_filter.dart';
import 'time_filter_widget.dart';
import '../utils/style_utils.dart';
import '../theme/app_theme.dart';
import 'package:ai_poetry_card/services/language_service.dart';

class HistoryFilterBar extends StatefulWidget {
  final String searchQuery;
  final PoetryStyle? selectedStyle;
  final TimeFilterType? selectedTimeFilter;
  final bool isGridView;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<PoetryStyle?> onStyleChanged;
  final ValueChanged<TimeFilterType?> onTimeFilterChanged;
  final ValueChanged<bool> onViewModeChanged;

  const HistoryFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedStyle,
    required this.selectedTimeFilter,
    required this.isGridView,
    required this.onSearchChanged,
    required this.onStyleChanged,
    required this.onTimeFilterChanged,
    required this.onViewModeChanged,
  });

  @override
  State<HistoryFilterBar> createState() => _HistoryFilterBarState();
}

class _HistoryFilterBarState extends State<HistoryFilterBar> {
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

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
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: _isSearchFocused
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null, // 只在获得焦点时显示阴影
              ),
              child: TextField(
                focusNode: _searchFocusNode,
                onChanged: widget.onSearchChanged,
                style: const TextStyle(color: Color(0xFF333333)), // 输入文字颜色
                decoration: InputDecoration(
                  filled: true,
                  hintText: context.l10n('搜索文案内容...'),
                  hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 162, 161, 161)), // 提示文字颜色
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF666666), // 搜索图标颜色
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 筛选器
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                // 风格筛选
                _FilterChip(
                  label: context.l10n('风格'),
                  value: widget.selectedStyle != null
                      ? StyleUtils.getStyleDisplayName(widget.selectedStyle!)
                      : null,
                  onTap: () => _showStyleFilter(context),
                ),
                // 时间筛选
                _FilterChip(
                  label: context.l10n('时间'),
                  value: widget.selectedTimeFilter != null
                      ? TimeFilterWidget.getTimeFilterDisplayValue(
                          widget.selectedTimeFilter)
                      : null,
                  onTap: () => TimeFilterWidget.showTimeFilter(
                    context,
                    selectedTimeFilter: widget.selectedTimeFilter,
                    onTimeFilterChanged: widget.onTimeFilterChanged,
                  ),
                ),
                // 视图切换按钮
                _ViewModeButton(
                  isGridView: widget.isGridView,
                  onTap: () => widget.onViewModeChanged(!widget.isGridView),
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
              Center(
                child: Text(
                  context.l10n('选择风格'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              ...PoetryStyle.values.map((style) {
                final isSelected = widget.selectedStyle == style;
                return Container(
                  margin: const EdgeInsets.only(bottom: 4), // 减小间距
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white // 选中背景为白色
                        : Colors.transparent, // 未选中透明
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null, // 选中时有阴影
                  ),
                  child: ListTile(
                    title: Center(
                      child: Text(
                        StyleUtils.getStyleDisplayName(style),
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryColor // 主题色选中文字
                              : const Color(0xFF666666), // 灰色未选中文字
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    onTap: () {
                      widget.onStyleChanged(isSelected ? null : style);
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
              if (widget.selectedStyle != null) ...[
                const Divider(),
                InkWell(
                  onTap: () {
                    widget.onStyleChanged(null);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.clear,
                          color: Color(0xFF666666), // 与文字颜色一致
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n('清除筛选'),
                          style: const TextStyle(
                            color: Color(0xFF666666), // 灰色文字
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
          // height: 42, // 适中高度
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 适中内边距
          decoration: BoxDecoration(
            color: value != null
                ? Theme.of(context).primaryColor // 选中状态深色背景
                : Colors.white, // 白色未选中背景
            borderRadius: BorderRadius.circular(20), // 适中圆角
            boxShadow: [
              BoxShadow(
                color: value != null
                    ? AppTheme.primaryDark.withOpacity(0.3) // 选中状态深色阴影
                    : Colors.black.withOpacity(0.1), // 未选中状态浅色阴影
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: value != null
                      ? Colors.white // 白色选中文字
                      : const Color(0xFF333333), // 深色未选中文字
                  fontSize: 14, // 适中字号
                  fontWeight: value != null ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 5),
                Text(
                  ': $value',
                  style: const TextStyle(
                    color: Colors.white, // 白色选中值文字
                    fontSize: 14, // 适中字号
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(width: 6), // 增大间距
              Icon(
                Icons.keyboard_arrow_down,
                size: 18, // 适中图标
                color: value != null
                    ? Colors.white // 白色选中图标
                    : const Color(0xFF999999), // 中灰色未选中图标
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
