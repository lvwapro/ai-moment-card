import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_poetry_card/providers/app_state.dart';
import 'package:ai_poetry_card/providers/card_generator.dart';
import 'package:ai_poetry_card/providers/history_manager.dart';
import 'package:ai_poetry_card/screens/home_screen.dart';
import 'package:ai_poetry_card/theme/app_theme.dart';

void main() {
  runApp(const PoetryCardApp());
}

class PoetryCardApp extends StatelessWidget {
  const PoetryCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => CardGenerator()),
        ChangeNotifierProvider(create: (_) => HistoryManager()),
      ],
      child: MaterialApp(
        title: 'AI诗意瞬间卡片',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
