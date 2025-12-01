import 'package:ai_poetry_card/providers/app_state.dart';
import 'package:ai_poetry_card/screens/main_screen.dart';
import 'package:ai_poetry_card/screens/welcome_screen.dart';
import 'package:ai_poetry_card/services/user_profile_service.dart';
import 'package:ai_poetry_card/services/cos_upload_service.dart';
import 'package:ai_poetry_card/services/init_service.dart';
import 'services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/card_generator.dart';
import 'providers/history_manager.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 加载 .env 文件
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('.env 文件加载失败: $e');
  }

  // 初始化语言服务
  try {
    await LanguageService().initialize();
  } catch (e) {
    print('语言服务初始化失败: $e');
  }

  // 初始化应用（包括网络、用户、RevenueCat等）
  try {
    await InitService.initApp();
  } catch (e) {
    print('应用初始化失败: $e');
  }

  // 初始化腾讯云COS服务
  try {
    await CosUploadService.initialize();
  } catch (e) {
    print('COS服务初始化失败: $e');
  }

  runApp(const PoetryCardApp());
}

class PoetryCardApp extends StatelessWidget {
  const PoetryCardApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageService()),
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => CardGenerator()),
          ChangeNotifierProvider(create: (_) => HistoryManager()),
          ChangeNotifierProvider(create: (_) => UserProfileService()),
        ],
        child: Consumer2<LanguageService, AppState>(
          builder: (context, languageService, appState, _) => MaterialApp(
            title: 'AI诗意瞬间卡片',
            theme: AppTheme.getLightTheme(appState.fontFamilyName),
            darkTheme: AppTheme.getDarkTheme(appState.fontFamilyName),
            themeMode: ThemeMode.light, // 强制浅色模式
            home: const AppInitializer(),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', 'CN'),
              Locale('en', 'US'),
            ],
            locale: languageService.currentLocale, // 使用当前设置的语言
          ),
        ),
      );
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    // 等待用户信息服务初始化
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(context.l10n('正在初始化...')),
            ],
          ),
        ),
      );
    }

    return Consumer<UserProfileService>(
      builder: (context, userProfileService, child) {
        // 检查用户是否已完成欢迎页面（是否有用户配置）
        if (!userProfileService.hasProfile) {
          return const WelcomeScreen();
        }

        // 设置CardGenerator的用户信息服务
        final cardGenerator =
            Provider.of<CardGenerator>(context, listen: false);
        cardGenerator.setUserProfileService(userProfileService);

        return const MainScreen();
      },
    );
  }
}
