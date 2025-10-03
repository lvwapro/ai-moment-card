import 'package:ai_poetry_card/models/user_profile.dart';
import 'package:ai_poetry_card/screens/home_screen.dart';
import 'package:ai_poetry_card/services/user_profile_service.dart';
import 'package:ai_poetry_card/widgets/onboarding/onboarding_age_page.dart';
import 'package:ai_poetry_card/widgets/onboarding/onboarding_complete_page.dart';
import 'package:ai_poetry_card/widgets/onboarding/onboarding_gender_page.dart';
import '../widgets/onboarding/onboarding_interests_page.dart';
import 'package:ai_poetry_card/widgets/onboarding/onboarding_optional_info_page.dart';
import '../widgets/onboarding/onboarding_personality_page.dart';
import 'package:ai_poetry_card/widgets/onboarding/onboarding_welcome_page.dart';
import 'package:ai_poetry_card/services/language_service.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 用户信息
  int? _age;
  Gender? _gender;
  final List<PersonalityType> _selectedPersonalities = [];
  final List<String> _selectedInterests = [];
  String? _occupation;
  String? _location;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    const OnboardingWelcomePage(),
                    OnboardingAgePage(
                      selectedAge: _age,
                      onAgeSelected: (age) {
                        setState(() {
                          _age = age;
                        });
                      },
                    ),
                    OnboardingGenderPage(
                      selectedGender: _gender,
                      onGenderSelected: (gender) {
                        setState(() {
                          _gender = gender;
                        });
                      },
                    ),
                    OnboardingPersonalityPage(
                      selectedPersonalities: _selectedPersonalities,
                      onPersonalityToggled: (personality) {
                        setState(() {
                          if (_selectedPersonalities.contains(personality)) {
                            _selectedPersonalities.remove(personality);
                          } else {
                            _selectedPersonalities.add(personality);
                          }
                        });
                      },
                    ),
                    OnboardingInterestsPage(
                      selectedInterests: _selectedInterests,
                      onInterestToggled: (interest) {
                        setState(() {
                          if (_selectedInterests.contains(interest)) {
                            _selectedInterests.remove(interest);
                          } else {
                            _selectedInterests.add(interest);
                          }
                        });
                      },
                    ),
                    OnboardingOptionalInfoPage(
                      occupation: _occupation,
                      location: _location,
                      onOccupationChanged: (value) {
                        setState(() {
                          _occupation = value;
                        });
                      },
                      onLocationChanged: (value) {
                        setState(() {
                          _location = value;
                        });
                      },
                    ),
                    const OnboardingCompletePage(),
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      );

  Widget _buildProgressIndicator() => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  context.l10n('完善个人信息'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  '${_currentPage + 1}/7',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (_currentPage + 1) / 7,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      );

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text(context.l10n('上一步')),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _handleNext : null,
              child: Text(
                  _currentPage == 6 ? context.l10n('完成') : context.l10n('下一步')),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return true; // 欢迎页面
      case 1:
        return _age != null; // 年龄页面
      case 2:
        return _gender != null; // 性别页面
      case 3:
        return _selectedPersonalities.isNotEmpty; // 性格页面
      case 4:
        return true; // 兴趣页面（可选）
      case 5:
        return true; // 其他信息页面（可选）
      case 6:
        return true; // 完成页面
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentPage == 6) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() async {
    try {
      final profile = UserProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        age: _age,
        gender: _gender,
        personalityTypes: _selectedPersonalities,
        interests: _selectedInterests,
        occupation: _occupation,
        location: _location,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final userProfileService =
          Provider.of<UserProfileService>(context, listen: false);
      await userProfileService.saveProfile(profile);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n('保存信息失败：$e'))),
        );
      }
    }
  }
}
