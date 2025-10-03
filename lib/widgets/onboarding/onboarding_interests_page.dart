import 'package:ai_poetry_card/services/language_service.dart';

import 'package:flutter/material.dart';

class OnboardingInterestsPage extends StatelessWidget {
  final List<String> selectedInterests;
  final Function(String) onInterestToggled;

  const OnboardingInterestsPage({
    super.key,
    required this.selectedInterests,
    required this.onInterestToggled,
  });

  static const List<String> _interestOptions = [
    '摄影',
    '旅行',
    '美食',
    '音乐',
    '阅读',
    '运动',
    '电影',
    '绘画',
    '写作',
    '游戏',
    '科技',
    '时尚',
    '宠物',
    '园艺',
    '手工',
    '舞蹈',
    '瑜伽',
    '咖啡',
  ];

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n('您的兴趣爱好？'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n('选择您感兴趣的内容，这将丰富文案的主题'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _interestOptions.length,
                itemBuilder: (context, index) {
                  final interest = _interestOptions[index];
                  final isSelected = selectedInterests.contains(interest);

                  return GestureDetector(
                    onTap: () => onInterestToggled(interest),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          interest,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
}
