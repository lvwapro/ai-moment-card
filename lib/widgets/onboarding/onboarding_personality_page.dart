import 'package:flutter/material.dart';
import 'package:ai_poetry_card/utils/localization_extension.dart';
import 'package:ai_poetry_card/models/user_profile.dart';

class OnboardingPersonalityPage extends StatelessWidget {
  final List<PersonalityType> selectedPersonalities;
  final Function(PersonalityType) onPersonalityToggled;

  const OnboardingPersonalityPage({
    super.key,
    required this.selectedPersonalities,
    required this.onPersonalityToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n('您的性格特点？'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n('可以选择多个，这将影响文案的风格和语调'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: PersonalityType.values.length,
              itemBuilder: (context, index) {
                final personality = PersonalityType.values[index];
                final isSelected = selectedPersonalities.contains(personality);
                String personalityText;

                switch (personality) {
                  case PersonalityType.introverted:
                    personalityText = context.l10n('内向');
                    break;
                  case PersonalityType.extroverted:
                    personalityText = context.l10n('外向');
                    break;
                  case PersonalityType.artistic:
                    personalityText = context.l10n('文艺');
                    break;
                  case PersonalityType.practical:
                    personalityText = context.l10n('实用主义');
                    break;
                  case PersonalityType.romantic:
                    personalityText = context.l10n('浪漫主义');
                    break;
                  case PersonalityType.humorous:
                    personalityText = context.l10n('幽默风趣');
                    break;
                  case PersonalityType.philosophical:
                    personalityText = context.l10n('哲学思辨');
                    break;
                  case PersonalityType.adventurous:
                    personalityText = context.l10n('冒险精神');
                    break;
                }

                return GestureDetector(
                  onTap: () => onPersonalityToggled(personality),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        personalityText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
}
