import 'package:flutter/material.dart';
import 'package:ai_poetry_card/services/language_service.dart';
import '../widgets/user_info_card_widget.dart';
import '../widgets/settings/preferences_section.dart';
import '../widgets/settings/data_section.dart';
import '../widgets/settings/about_section.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Text(
            context.l10n('设置'),
            style: const TextStyle(color: AppTheme.primaryColor),
          ),
        ),
        body: ListView(
          children: [
            const UserInfoCardWidget(),
            const SizedBox(height: 16),
            const PreferencesSection(),
            const SizedBox(height: 16),
            const DataSection(),
            const SizedBox(height: 16),
            const AboutSection(),
            const SizedBox(height: 32),
          ],
        ),
      );
}
