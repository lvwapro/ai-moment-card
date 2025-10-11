import 'package:flutter/material.dart';
import 'package:ai_poetry_card/services/language_service.dart';

class DescriptionInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String description;
  final VoidCallback onClear;

  const DescriptionInputWidget({
    super.key,
    required this.controller,
    required this.description,
    required this.onClear,
  });

  @override
  State<DescriptionInputWidget> createState() => _DescriptionInputWidgetState();
}

class _DescriptionInputWidgetState extends State<DescriptionInputWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n('添加描述（可选）'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFe5e3e2), // 与搜索框相同的灰色背景
                borderRadius: BorderRadius.circular(20), // 圆角
                boxShadow: _isFocused
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
                focusNode: _focusNode,
                controller: widget.controller,
                maxLines: 3,
                style: const TextStyle(color: Color(0xFF333333)), // 深色输入文字
                decoration: InputDecoration(
                  hintText: context.l10n('描述这张图片的内容、情感或想要表达的意思...'),
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 162, 161, 161), // 与搜索框相同的提示文字颜色
                    fontSize: 14,
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
