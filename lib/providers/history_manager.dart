import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';

/// 历史记录管理器
///
/// 职责：
/// - 管理卡片历史记录的增删改查
/// - 提供多选功能
/// - 持久化存储
class HistoryManager extends ChangeNotifier {
  static const String _historyKey = 'poetry_cards_history';
  static const int _maxHistoryCount = 100;

  List<PoetryCard> _cards = [];
  Set<String> _selectedCardIds = {};

  // ==================== Getters ====================

  List<PoetryCard> get cards => List.unmodifiable(_cards);
  List<PoetryCard> get recentCards => _cards.take(10).toList();
  int get totalCount => _cards.length;

  // 多选相关
  Set<String> get selectedCardIds => Set.unmodifiable(_selectedCardIds);
  bool get isMultiSelectMode => _selectedCardIds.isNotEmpty;
  int get selectedCount => _selectedCardIds.length;

  // ==================== 初始化 ====================

  HistoryManager() {
    _loadHistory();
  }

  // ==================== 持久化 ====================

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);

      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        _cards = historyList.map((json) => PoetryCard.fromJson(json)).toList();
        _sortCardsByDate();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ 加载历史记录失败: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        _cards.map((card) => card.toJson()).toList(),
      );
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      debugPrint('❌ 保存历史记录失败: $e');
    }
  }

  // ==================== 卡片管理 ====================

  /// 添加或更新卡片
  Future<void> addCard(PoetryCard card) async {
    final existingIndex = _cards.indexWhere((c) => c.id == card.id);

    if (existingIndex != -1) {
      _cards[existingIndex] = card;
    } else {
      _cards.insert(0, card);
    }

    _limitHistorySize();
    await _saveHistory();
    notifyListeners();
  }

  /// 删除单个卡片
  Future<void> deleteCard(String cardId) async {
    _cards.removeWhere((card) => card.id == cardId);
    await _saveHistory();
    notifyListeners();
  }

  /// 删除选中的卡片
  Future<void> deleteSelectedCards() async {
    _cards.removeWhere((card) => _selectedCardIds.contains(card.id));
    _selectedCardIds.clear();
    await _saveHistory();
    notifyListeners();
  }

  /// 清空所有历史记录
  Future<void> clearHistory() async {
    _cards.clear();
    _selectedCardIds.clear();
    await _saveHistory();
    notifyListeners();
  }

  /// 移除卡片（已废弃，使用 deleteCard）
  @Deprecated('Use deleteCard instead')
  Future<void> removeCard(String cardId) async {
    await deleteCard(cardId);
  }

  // ==================== 查询 ====================

  /// 根据ID获取卡片
  PoetryCard? getCardById(String cardId) {
    try {
      return _cards.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  /// 根据风格获取卡片列表
  List<PoetryCard> getCardsByStyle(PoetryStyle style) {
    return _cards.where((card) => card.style == style).toList();
  }

  /// 搜索卡片
  List<PoetryCard> searchCards(String query) {
    if (query.isEmpty) return _cards;

    final lowercaseQuery = query.toLowerCase();
    return _cards.where((card) {
      return card.poetry.toLowerCase().contains(lowercaseQuery) ?? false;
    }).toList();
  }

  /// 获取统计信息
  Map<String, int> getStatistics() {
    final stats = <String, int>{};

    // 按风格统计
    for (final style in PoetryStyle.values) {
      stats['style_${style.name}'] = getCardsByStyle(style).length;
    }

    // 总数量
    stats['total'] = _cards.length;

    return stats;
  }

  // ==================== 多选功能 ====================

  /// 切换卡片选中状态
  void toggleCardSelection(String cardId) {
    if (_selectedCardIds.contains(cardId)) {
      _selectedCardIds.remove(cardId);
    } else {
      _selectedCardIds.add(cardId);
    }
    notifyListeners();
  }

  /// 全选
  void selectAllCards() {
    _selectedCardIds = _cards.map((card) => card.id).toSet();
    notifyListeners();
  }

  /// 清空选择
  void clearSelection() {
    _selectedCardIds.clear();
    notifyListeners();
  }

  /// 检查卡片是否被选中
  bool isCardSelected(String cardId) {
    return _selectedCardIds.contains(cardId);
  }

  // ==================== 私有辅助方法 ====================

  /// 按创建时间排序（最新的在前）
  void _sortCardsByDate() {
    _cards.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 限制历史记录数量
  void _limitHistorySize() {
    if (_cards.length > _maxHistoryCount) {
      _cards = _cards.take(_maxHistoryCount).toList();
    }
  }
}
