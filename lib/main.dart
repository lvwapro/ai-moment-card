import 'package:ai_poetry_card/providers/app_state.dart';
import 'package:ai_poetry_card/screens/history_screen.dart';
import 'package:ai_poetry_card/screens/home_screen.dart';
import 'package:ai_poetry_card/screens/onboarding_screen.dart';
import 'package:ai_poetry_card/services/user_profile_service.dart';
import 'package:ai_poetry_card/services/cos_upload_service.dart';
import 'package:ai_poetry_card/services/network_service.dart';
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

  // 初始化网络服务
  try {
    await NetworkService().initializeAuth();
  } catch (e) {
    print('网络服务初始化失败: $e');
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
        child: Consumer<LanguageService>(
          builder: (context, languageService, _) => MaterialApp(
            title: 'AI诗意瞬间卡片',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const AppInitializer(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/history': (context) => const HistoryScreen(),
            },
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
        // 检查用户是否已完成信息收集
        if (!userProfileService.isProfileComplete) {
          return const OnboardingScreen();
        }

        // 设置CardGenerator的用户信息服务
        final cardGenerator =
            Provider.of<CardGenerator>(context, listen: false);
        cardGenerator.setUserProfileService(userProfileService);

        return const HomeScreen();
      },
    );
  }
}
