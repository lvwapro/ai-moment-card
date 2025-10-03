import 'package:flutter/material.dart';
import 'package:ai_poetry_card/models/time_filter.dart';
import 'package:ai_poetry_card/services/language_service.dart';

/// 时间筛选相关的UI组件
class TimeFilterWidget {
  /// 显示时间筛选弹窗
  static void showTimeFilter(
    BuildContext context, {
    required TimeFilterType? selectedTimeFilter,
    required DateTimeRange? customTimeRange,
    required ValueChanged<TimeFilterType?> onTimeFilterChanged,
    required ValueChanged<DateTimeRange?> onCustomTimeRangeChanged,
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
              Text(
                context.l10n('选择时间范围'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...TimeFilterType.values.map(
                (type) => _buildTimeFilterOption(
                  context,
                  type,
                  selectedTimeFilter,
                  customTimeRange,
                  onTimeFilterChanged,
                  onCustomTimeRangeChanged,
                ),
              ),
              if (selectedTimeFilter != null) ...[
                const Divider(),
                ListTile(
                  title: Text(context.l10n('清除筛选')),
                  leading: const Icon(Icons.clear),
                  onTap: () {
                    onTimeFilterChanged(null);
                    onCustomTimeRangeChanged(null);
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

  /// 构建时间过滤器选项
  static Widget _buildTimeFilterOption(
    BuildContext context,
    TimeFilterType type,
    TimeFilterType? selectedTimeFilter,
    DateTimeRange? customTimeRange,
    ValueChanged<TimeFilterType?> onTimeFilterChanged,
    ValueChanged<DateTimeRange?> onCustomTimeRangeChanged,
  ) {
    final isSelected = selectedTimeFilter == type;

    return ListTile(
      title: Text(TimeFilterHelper.getTimeFilterName(type)),
      subtitle: Text(TimeFilterHelper.getTimeFilterDescription(type)),
      leading: Radio<TimeFilterType>(
        value: type,
        groupValue: selectedTimeFilter,
        onChanged: (value) => _handleTimeFilterSelection(
          context,
          value,
          customTimeRange,
          onTimeFilterChanged,
          onCustomTimeRangeChanged,
        ),
      ),
      onTap: () => _handleTimeFilterSelection(
        context,
        isSelected ? null : type,
        customTimeRange,
        onTimeFilterChanged,
        onCustomTimeRangeChanged,
      ),
    );
  }

  /// 处理时间过滤器选择
  static void _handleTimeFilterSelection(
    BuildContext context,
    TimeFilterType? value,
    DateTimeRange? customTimeRange,
    ValueChanged<TimeFilterType?> onTimeFilterChanged,
    ValueChanged<DateTimeRange?> onCustomTimeRangeChanged,
  ) {
    if (value == TimeFilterType.custom) {
      _showCustomTimeRangePicker(
        context,
        customTimeRange: customTimeRange,
        onTimeFilterChanged: onTimeFilterChanged,
        onCustomTimeRangeChanged: onCustomTimeRangeChanged,
      );
    } else {
      onTimeFilterChanged(value);
      onCustomTimeRangeChanged(null);
      Navigator.pop(context);
    }
  }

  /// 显示自定义时间范围选择器
  static Future<void> _showCustomTimeRangePicker(
    BuildContext context, {
    required DateTimeRange? customTimeRange,
    required ValueChanged<TimeFilterType?> onTimeFilterChanged,
    required ValueChanged<DateTimeRange?> onCustomTimeRangeChanged,
  }) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, 1);
    final lastDate = now.add(const Duration(days: 1));

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: customTimeRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
      locale: const Locale('zh', 'CN'),
    );

    if (picked != null) {
      onTimeFilterChanged(TimeFilterType.custom);
      onCustomTimeRangeChanged(picked);
      Navigator.pop(context);
    }
  }

  /// 获取时间筛选的显示值
  static String getTimeFilterDisplayValue(
    TimeFilterType? selectedTimeFilter,
    DateTimeRange? customTimeRange,
  ) {
    if (selectedTimeFilter == null) return '';

    if (selectedTimeFilter == TimeFilterType.custom &&
        customTimeRange != null) {
      final start = customTimeRange.start;
      final end = customTimeRange.end;
      return '${start.month}/${start.day} - ${end.month}/${end.day}';
    }

    return TimeFilterHelper.getTimeFilterName(selectedTimeFilter);
  }
}
