import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';

class HistoryManager extends ChangeNotifier {
  static const String _historyKey = 'poetry_cards_history';
  List<PoetryCard> _cards = [];

  List<PoetryCard> get cards => List.unmodifiable(_cards);
  List<PoetryCard> get recentCards => _cards.take(10).toList();
  int get totalCount => _cards.length;

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

  List<PoetryCard> getCardsByTemplate(CardTemplate template) {
    return _cards.where((card) => card.template == template).toList();
  }

  List<PoetryCard> searchCards(String query) {
    if (query.isEmpty) return _cards;

    final lowercaseQuery = query.toLowerCase();
    return _cards.where((card) {
      return card.poetry.toLowerCase().contains(lowercaseQuery) ||
          _getStyleDisplayName(card.style)
              .toLowerCase()
              .contains(lowercaseQuery) ||
          _getTemplateDisplayName(card.template)
              .toLowerCase()
              .contains(lowercaseQuery);
    }).toList();
  }

  String _getStyleDisplayName(PoetryStyle style) {
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

  String _getTemplateDisplayName(CardTemplate template) {
    switch (template) {
      case CardTemplate.minimal:
        return '极简';
      case CardTemplate.elegant:
        return '优雅';
      case CardTemplate.romantic:
        return '浪漫';
      case CardTemplate.vintage:
        return '复古';
      case CardTemplate.nature:
        return '自然';
      case CardTemplate.urban:
        return '都市';
    }
  }

  // 获取统计信息
  Map<String, int> getStatistics() {
    final stats = <String, int>{};

    // 按风格统计
    for (final style in PoetryStyle.values) {
      stats['style_${style.name}'] = getCardsByStyle(style).length;
    }

    // 按模板统计
    for (final template in CardTemplate.values) {
      stats['template_${template.name}'] = getCardsByTemplate(template).length;
    }

    // 总数量
    stats['total'] = _cards.length;

    return stats;
  }
}
