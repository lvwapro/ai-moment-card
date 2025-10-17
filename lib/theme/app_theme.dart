import 'package:flutter/material.dart';

class AppTheme {
  // 经典复古配色 - 深棕金色系
  static const Color primaryColor = Color(0xFF8B4513); // 马鞍棕 - 主色调
  static const Color primaryLight = Color(0xFFCD853F); // 秘鲁色
  static const Color primaryDark = Color(0xFF654321); // 深棕色

  // 辅助色 - 复古金色系
  static const Color accentColor = Color(0xFFDAA520); // 金棒色
  static const Color accentLight = Color(0xFFFFD700); // 金色
  static const Color accentDark = Color(0xFFB8860B); // 深金色
  static const Color successColor = Color(0xFF228B22); // 森林绿
  static const Color errorColor = Color(0xFFB22222); // 火砖红

  // 中性色 - 复古米色系
  static const Color backgroundColor = Color(0xFFFDF5E6); // 老蕾丝色背景
  static const Color surfaceColor = Color(0xFFFFFACD); // 柠檬绸色表面
  static const Color cardColor = Color(0xFFFFF8DC); // 玉米丝色卡片

  // 文字颜色 - 复古深色系
  static const Color textPrimary = Color(0xFF2F1B14); // 深棕色
  static const Color textSecondary = Color(0xFF8B4513); // 马鞍棕
  static const Color textTertiary = Color(0xFFA0522D); // 赭石色

  // 组件统一颜色 - 复古风格
  static const Color chipBackground = Color(0xFFFFFACD); // 柠檬绸色 - 标签背景
  static const Color chipBorder = Color(0xFFD2B48C); // 浅棕色 - 标签边框
  static const Color chipText = Color(0xFF8B4513); // 马鞍棕 - 标签文字
  static const Color borderColor = Color(0xFFD2B48C); // 浅棕色 - 通用边框
  static const Color shadowColor = Color(0x1A8B4513); // 马鞍棕 - 阴影
  static const Color dividerColor = Color(0xFFD2B48C); // 浅棕色 - 分割线
  static const Color selectionColor = Color(0xFFDAA520); // 金棒色 - 选中状态

  // 兼容旧代码的静态 getter
  static ThemeData get lightTheme => getLightTheme('JiangxiZhuokai');

  // 新的带字体参数的方法（fontFamily为null时使用系统默认字体）
  static ThemeData getLightTheme(String? fontFamily) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily, // 使用传入的字体，null表示系统默认
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor.withOpacity(0.3), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: shadowColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F0F0), // 浅灰色背景
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          color: primaryColor, // 主题色文字
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor; // 主题色选中
          }
          return const Color(0xFFCCCCCC); // 浅灰色未选中
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor; // 主题色选中
          }
          return const Color(0xFFCCCCCC); // 浅灰色未选中
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFFCCCCCC), width: 2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor; // 主题色选中
          }
          return const Color(0xFFCCCCCC); // 浅灰色未选中
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.3); // 主题色轨道
          }
          return const Color(0xFFE0E0E0); // 浅灰色轨道
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white, // 白色背景
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB0B0B0), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFF999999), // 中性灰色提示文字
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textTertiary,
        ),
      ),
    );
  }

  // 兼容旧代码的静态 getter
  static ThemeData get darkTheme => getDarkTheme('JiangxiZhuokai');

  // 新的带字体参数的方法（fontFamily为null时使用系统默认字体）
  static ThemeData getDarkTheme(String? fontFamily) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily, // 使用传入的字体，null表示系统默认
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF2F1B14), // 深棕色背景
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFFFFD700), // 金色标题
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF654321), // 深棕色卡片
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor.withOpacity(0.2), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDAA520), // 金棒色
          foregroundColor: const Color(0xFF2F1B14), // 深棕色
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFFD700), // 金色
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF404040), // 深灰色背景
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFFE0E0E0), // 浅灰色文字
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF606060), width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFFDAA520); // 金棒色选中
          }
          return const Color(0xFF666666); // 深灰色未选中
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFFDAA520); // 金棒色选中
          }
          return const Color(0xFF666666); // 深灰色未选中
        }),
        checkColor: MaterialStateProperty.all(const Color(0xFF2F1B14)),
        side: const BorderSide(color: Color(0xFF666666), width: 2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFFDAA520); // 金棒色选中
          }
          return const Color(0xFF666666); // 深灰色未选中
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFFDAA520).withOpacity(0.3); // 金棒色轨道
          }
          return const Color(0xFF404040); // 深灰色轨道
        }),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
            fontFamily: fontFamily,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8B6914)), // 深金棕色
        displayMedium: TextStyle(
            fontFamily: fontFamily,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8B6914)),
        displaySmall: TextStyle(
            fontFamily: fontFamily,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8B6914)),
        headlineLarge: TextStyle(
            fontFamily: fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8B6914)),
        headlineMedium: TextStyle(
            fontFamily: fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8B6914)),
        headlineSmall: TextStyle(
            fontFamily: fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8B6914)),
        titleLarge: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCD853F)), // 秘鲁色
        titleMedium: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFCD853F)),
        titleSmall: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFCD853F)),
        bodyLarge: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: const Color(0xFFE6D3B7)), // 深奶油色
        bodyMedium: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF8B4513)), // 马鞍棕
        bodySmall: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF8B4513)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5), // 浅灰色背景
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB0B0B0), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFF999999), // 中性灰色提示文字
        ),
      ),
    );
  }
}
