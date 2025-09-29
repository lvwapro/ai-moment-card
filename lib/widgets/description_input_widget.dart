import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/localization_extension.dart';

//hct
class DescriptionInputWidget extends StatelessWidget {
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
  Widget build(BuildContext context) => Container(
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
              context.l10n('添加描述（可选）'),
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
                hintText: context.l10n('描述这张图片的内容、情感或想要表达的意思...'),
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ],
        ),
      );
}
