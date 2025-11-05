import 'package:flutter/material.dart';
import 'package:ai_poetry_card/models/time_filter.dart';
import 'package:ai_poetry_card/services/language_service.dart';
import '../../theme/app_theme.dart';

/// 时间筛选相关的UI组件
class TimeFilterWidget {
  /// 显示时间筛选弹窗
  static void showTimeFilter(
    BuildContext context, {
    required TimeFilterType? selectedTimeFilter,
    required ValueChanged<TimeFilterType?> onTimeFilterChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  context.l10n('选择时间范围'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              ...TimeFilterType.values.map(
                (type) => _buildTimeFilterOption(
                  context,
                  type,
                  selectedTimeFilter,
                  onTimeFilterChanged,
                ),
              ),
              if (selectedTimeFilter != null) ...[
                const Divider(),
                InkWell(
                  onTap: () {
                    onTimeFilterChanged(null);
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

  /// 构建时间过滤器选项
  static Widget _buildTimeFilterOption(
    BuildContext context,
    TimeFilterType type,
    TimeFilterType? selectedTimeFilter,
    ValueChanged<TimeFilterType?> onTimeFilterChanged,
  ) {
    final isSelected = selectedTimeFilter == type;

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
            TimeFilterHelper.getTimeFilterName(type),
            style: TextStyle(
              color: isSelected
                  ? AppTheme.primaryColor // 主题色选中文字
                  : const Color(0xFF666666), // 灰色未选中文字
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        onTap: () {
          onTimeFilterChanged(isSelected ? null : type);
          Navigator.pop(context);
        },
      ),
    );
  }

  /// 获取时间筛选的显示值
  static String getTimeFilterDisplayValue(
    TimeFilterType? selectedTimeFilter,
  ) {
    if (selectedTimeFilter == null) return '';
    return TimeFilterHelper.getTimeFilterName(selectedTimeFilter);
  }
}
