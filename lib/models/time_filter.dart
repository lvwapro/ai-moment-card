import 'package:flutter/material.dart';

/// 时间筛选类型
enum TimeFilterType {
  all, // 全部
  today, // 今天
  thisWeek, // 本周
  thisMonth, // 本月
  last3Months, // 近3个月
  custom, // 自定义
}

/// 时间筛选辅助类
class TimeFilterHelper {
  /// 获取时间筛选类型的显示名称
  static String getTimeFilterName(TimeFilterType type) {
    switch (type) {
      case TimeFilterType.all:
        return '全部';
      case TimeFilterType.today:
        return '今天';
      case TimeFilterType.thisWeek:
        return '本周';
      case TimeFilterType.thisMonth:
        return '本月';
      case TimeFilterType.last3Months:
        return '近3个月';
      case TimeFilterType.custom:
        return '自定义';
    }
  }

  /// 获取时间筛选类型的描述
  static String getTimeFilterDescription(TimeFilterType type) {
    switch (type) {
      case TimeFilterType.all:
        return '显示所有时间';
      case TimeFilterType.today:
        return '今天创建的卡片';
      case TimeFilterType.thisWeek:
        return '本周创建的卡片';
      case TimeFilterType.thisMonth:
        return '本月创建的卡片';
      case TimeFilterType.last3Months:
        return '近3个月创建的卡片';
      case TimeFilterType.custom:
        return '自定义时间范围';
    }
  }

  /// 根据时间筛选类型获取时间范围
  static DateTimeRange? getTimeRange(TimeFilterType type) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (type) {
      case TimeFilterType.all:
        return null; // 不限制时间范围
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
      case TimeFilterType.custom:
        return null; // 需要用户自定义选择
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
