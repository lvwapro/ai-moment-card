import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DescriptionInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String description;
  final bool isListening;
  final VoidCallback onStartListening;
  final VoidCallback onStopListening;
  final VoidCallback onClear;

  const DescriptionInputWidget({
    super.key,
    required this.controller,
    required this.description,
    required this.isListening,
    required this.onStartListening,
    required this.onStopListening,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '添加描述（可选）',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '描述这张图片的内容、情感或想要表达的意思...',
              hintStyle: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.6),
                fontSize: 14,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              suffixIcon: _buildSuffixIcon(context),
            ),
          ),
          if (isListening) _buildListeningIndicator(),
        ],
      ),
    );
  }

  Widget _buildSuffixIcon(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (description.isNotEmpty)
          IconButton(
            icon: Icon(Icons.clear, color: AppTheme.textSecondary),
            onPressed: onClear,
          ),
        IconButton(
          icon: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            color: isListening ? Colors.red : Theme.of(context).primaryColor,
          ),
          onPressed: isListening ? onStopListening : onStartListening,
        ),
      ],
    );
  }

  Widget _buildListeningIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '正在听取语音...',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
