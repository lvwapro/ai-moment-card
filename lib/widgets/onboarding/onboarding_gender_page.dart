import 'package:flutter/material.dart';
import 'package:ai_poetry_card/models/user_profile.dart';

class OnboardingGenderPage extends StatelessWidget {
  final Gender? selectedGender;
  final Function(Gender) onGenderSelected;

  const OnboardingGenderPage({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '您的性别是？',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '这将帮助我们调整文案的语言风格',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Column(
              children: Gender.values.map((gender) {
                final isSelected = selectedGender == gender;
                String genderText;
                IconData genderIcon;

                switch (gender) {
                  case Gender.male:
                    genderText = '男性';
                    genderIcon = Icons.male;
                    break;
                  case Gender.female:
                    genderText = '女性';
                    genderIcon = Icons.female;
                    break;
                  case Gender.other:
                    genderText = '其他';
                    genderIcon = Icons.person;
                    break;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => onGenderSelected(gender),
                    child: Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Row(
                        children: [
                          Icon(
                            genderIcon,
                            size: 32,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            genderText,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
