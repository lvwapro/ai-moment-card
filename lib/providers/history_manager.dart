import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';
import '../utils/style_utils.dart';

class HistoryManager extends ChangeNotifier {
  static const String _historyKey = 'poetry_cards_history';
  List<PoetryCard> _cards = [];
  Set<String> _selectedCardIds = {};

  List<PoetryCard> get cards => List.unmodifiable(_cards);
  List<PoetryCard> get recentCards => _cards.take(10).toList();
  int get totalCount => _cards.length;

  // 多选相关
  Set<String> get selectedCardIds => Set.unmodifiable(_selectedCardIds);
  bool get isMultiSelectMode => _selectedCardIds.isNotEmpty;
  int get selectedCount => _selectedCardIds.length;

  HistoryManager() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);

      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        _cards = historyList.map((json) => PoetryCard.fromJson(json)).toList();

        // 按创建时间排序（最新的在前）
        _cards.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        notifyListeners();
      }
    } catch (e) {
      debugPrint('加载历史记录失败: $e');
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
      debugPrint('保存历史记录失败: $e');
    }
  }

  Future<void> addCard(PoetryCard card) async {
    // 检查是否已存在相同的卡片
    final existingIndex = _cards.indexWhere((c) => c.id == card.id);

    if (existingIndex != -1) {
      // 更新现有卡片
      _cards[existingIndex] = card;
    } else {
      // 添加新卡片到开头
      _cards.insert(0, card);
    }

    // 限制历史记录数量（最多保存100张）
    if (_cards.length > 100) {
      _cards = _cards.take(100).toList();
    }

    await _saveHistory();
    notifyListeners();
  }

  Future<void> removeCard(String cardId) async {
    _cards.removeWhere((card) => card.id == cardId);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _cards.clear();
    await _saveHistory();
    notifyListeners();
  }

  PoetryCard? getCardById(String cardId) {
    try {
      return _cards.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  List<PoetryCard> getCardsByStyle(PoetryStyle style) {
    return _cards.where((card) => card.style == style).toList();
  }

  List<PoetryCard> searchCards(String query) {
    if (query.isEmpty) return _cards;

    final lowercaseQuery = query.toLowerCase();
    return _cards.where((card) {
      return card.poetry.toLowerCase().contains(lowercaseQuery) ||
          StyleUtils.getStyleDisplayName(card.style)
              .toLowerCase()
              .contains(lowercaseQuery);
    }).toList();
  }

  // 多选相关方法
  void toggleCardSelection(String cardId) {
    if (_selectedCardIds.contains(cardId)) {
      _selectedCardIds.remove(cardId);
    } else {
      _selectedCardIds.add(cardId);
    }
    notifyListeners();
  }

  void selectAllCards() {
    _selectedCardIds = _cards.map((card) => card.id).toSet();
    notifyListeners();
  }

  void clearSelection() {
    _selectedCardIds.clear();
    notifyListeners();
  }

  bool isCardSelected(String cardId) {
    return _selectedCardIds.contains(cardId);
  }

  Future<void> deleteSelectedCards() async {
    _cards.removeWhere((card) => _selectedCardIds.contains(card.id));
    _selectedCardIds.clear();
    await _saveHistory();
    notifyListeners();
  }

  // 获取统计信息
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
}
