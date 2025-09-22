import 'package:flutter/material.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';

class HistoryFilterBar extends StatelessWidget {
  final String searchQuery;
  final PoetryStyle? selectedStyle;
  final CardTemplate? selectedTemplate;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<PoetryStyle?> onStyleChanged;
  final ValueChanged<CardTemplate?> onTemplateChanged;

  const HistoryFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedStyle,
    required this.selectedTemplate,
    required this.onSearchChanged,
    required this.onStyleChanged,
    required this.onTemplateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            decoration: InputDecoration(
              hintText: '搜索文案内容...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
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
              // 风格筛选
              Expanded(
                child: _FilterChip(
                  label: '风格',
                  value: selectedStyle != null
                      ? _getStyleName(selectedStyle!)
                      : null,
                  onTap: () => _showStyleFilter(context),
                ),
              ),

              const SizedBox(width: 8),

              // 模板筛选
              Expanded(
                child: _FilterChip(
                  label: '模板',
                  value: selectedTemplate != null
                      ? _getTemplateName(selectedTemplate!)
                      : null,
                  onTap: () => _showTemplateFilter(context),
                ),
              ),

              const SizedBox(width: 8),

              // 清除筛选
              if (selectedStyle != null || selectedTemplate != null)
                IconButton(
                  onPressed: () {
                    onStyleChanged(null);
                    onTemplateChanged(null);
                  },
                  icon: const Icon(Icons.clear_all),
                  tooltip: '清除筛选',
                ),
            ],
          ),
        ],
      ),
    );
  }

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
                '选择风格',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...PoetryStyle.values.map((style) {
                final isSelected = selectedStyle == style;
                return ListTile(
                  title: Text(_getStyleName(style)),
                  subtitle: Text(_getStyleDescription(style)),
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
                  title: const Text('清除筛选'),
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

  void _showTemplateFilter(BuildContext context) {
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
                '选择模板',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...CardTemplate.values.map((template) {
                final isSelected = selectedTemplate == template;
                return ListTile(
                  title: Text(_getTemplateName(template)),
                  subtitle: Text(_getTemplateDescription(template)),
                  leading: Radio<CardTemplate>(
                    value: template,
                    groupValue: selectedTemplate,
                    onChanged: (value) {
                      onTemplateChanged(value);
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    onTemplateChanged(isSelected ? null : template);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              if (selectedTemplate != null) ...[
                const Divider(),
                ListTile(
                  title: const Text('清除筛选'),
                  leading: const Icon(Icons.clear),
                  onTap: () {
                    onTemplateChanged(null);
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

  String _getTemplateName(CardTemplate template) {
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

  String _getTemplateDescription(CardTemplate template) {
    switch (template) {
      case CardTemplate.minimal:
        return '简洁大方，突出内容';
      case CardTemplate.elegant:
        return '优雅精致，彰显品味';
      case CardTemplate.romantic:
        return '浪漫温馨，充满爱意';
      case CardTemplate.vintage:
        return '复古怀旧，时光沉淀';
      case CardTemplate.nature:
        return '自然清新，回归本真';
      case CardTemplate.urban:
        return '现代都市，时尚前卫';
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
  Widget build(BuildContext context) {
    return InkWell(
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
                color: value != null
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade600,
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
}
