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
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(context.l10n('设置')),
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
