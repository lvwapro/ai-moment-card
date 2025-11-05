import 'package:flutter/material.dart';

import '../../models/time_filter.dart';
import 'time_filter_widget.dart';
import '../../theme/app_theme.dart';
import 'package:ai_poetry_card/services/language_service.dart';

class HistoryFilterBar extends StatefulWidget {
  final String searchQuery;
  final TimeFilterType? selectedTimeFilter;
  final bool isGridView;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TimeFilterType?> onTimeFilterChanged;
  final ValueChanged<bool> onViewModeChanged;

  const HistoryFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedTimeFilter,
    required this.isGridView,
    required this.onSearchChanged,
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
