import 'package:flutter/material.dart';
import 'package:ai_poetry_card/services/language_service.dart';

/// 时间筛选类型
enum TimeFilterType {
  today, // 今天
  thisWeek, // 本周
  thisMonth, // 本月
  last3Months, // 近3个月
  lastYear, // 一年内
  beforeLastYear, // 一年前
}

/// 时间筛选辅助类
class TimeFilterHelper {
  /// 获取时间筛选类型的显示名称（支持多语言）
  static String getTimeFilterName(TimeFilterType type) {
    switch (type) {
      case TimeFilterType.today:
        return LanguageService.to.getText('今天');
      case TimeFilterType.thisWeek:
        return LanguageService.to.getText('本周');
      case TimeFilterType.thisMonth:
        return LanguageService.to.getText('本月');
      case TimeFilterType.last3Months:
        return LanguageService.to.getText('近3个月');
      case TimeFilterType.lastYear:
        return LanguageService.to.getText('一年内');
      case TimeFilterType.beforeLastYear:
        return LanguageService.to.getText('一年前');
    }
  }

  /// 根据时间筛选类型获取时间范围
  static DateTimeRange? getTimeRange(TimeFilterType type) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (type) {
      case TimeFilterType.today:
        return DateTimeRange(
          start: today,
          end: today
              .add(const Duration(days: 1))
              .subtract(const Duration(milliseconds: 1)),
        );
      case TimeFilterType.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(start: startOfWeek, end: now);
      case TimeFilterType.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: startOfMonth, end: now);
      case TimeFilterType.last3Months:
        final startOf3MonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return DateTimeRange(start: startOf3MonthsAgo, end: now);
      case TimeFilterType.lastYear:
        final startOfLastYear = DateTime(now.year - 1, now.month, now.day);
        return DateTimeRange(start: startOfLastYear, end: now);
      case TimeFilterType.beforeLastYear:
        final endOfBeforeLastYear = DateTime(now.year - 1, now.month, now.day);
        return DateTimeRange(
            start: DateTime(2000, 1, 1), end: endOfBeforeLastYear);
    }
  }

  /// 检查日期是否在时间范围内
  static bool isDateInRange(DateTime date, DateTimeRange? range) {
    if (range == null) return true;
    return date
            .isAfter(range.start.subtract(const Duration(milliseconds: 1))) &&
        date.isBefore(range.end.add(const Duration(milliseconds: 1)));
  }
}
