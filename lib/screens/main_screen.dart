import 'package:flutter/material.dart';
import 'dart:ui';
import 'history_screen.dart';
import 'home_screen.dart';
import 'footprint_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // 默认选中首页

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const FootprintScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false, // 防止键盘弹出时底部导航栏上移
        body: Stack(
          children: [
            // 主内容区域
            SafeArea(
              bottom: false, // 底部不需要SafeArea，因为导航栏是悬浮的
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
            // 悬浮的底部导航栏
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3), // 半透明黑色
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          _buildBottomItem(Icons.home, "首页", 0),
                          _buildBottomItem(Icons.history, "历史", 1),
                          _buildBottomItem(Icons.location_on, "足迹", 2),
                          _buildBottomItem(Icons.settings, "设置", 3),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  // 底部导航按钮组件 - 只显示图标
  Widget _buildBottomItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _currentIndex = index),
            customBorder: const CircleBorder(), // 圆形涟漪
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: isSelected ? Colors.pink : Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
