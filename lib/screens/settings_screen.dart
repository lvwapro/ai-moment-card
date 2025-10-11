import 'package:flutter/material.dart';
import 'package:ai_poetry_card/services/language_service.dart';
import '../widgets/user_info_card_widget.dart';
import '../widgets/settings/preferences_section.dart';
import '../widgets/settings/data_section.dart';
import '../widgets/settings/about_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n('设置'))),
        body: ListView(
          children: const [
            UserInfoCardWidget(),
            SizedBox(height: 16),
            PreferencesSection(),
            SizedBox(height: 16),
            DataSection(),
            SizedBox(height: 16),
            AboutSection(),
            SizedBox(height: 32),
          ],
        ),
      );
}
