import 'package:flutter/material.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // 默认选中中间的生成页面

  final List<Widget> _screens = [
    const HistoryScreen(),
    const HomeScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        // 悬浮按钮的位置 - 自定义位置往左偏移
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // 悬浮按钮 - 圆形粉色，无点击效果
        floatingActionButton: GestureDetector(
          onTap: () => setState(() => _currentIndex = 1),
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.pink,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
        // 底部导航栏 - 悬浮效果
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 30), // 悬浮边距
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomAppBar(
              color: Colors.black,
              height: 40, // 进一步降低高度
              shape: const CircularNotchedRectangle(),
              notchMargin: 4.0, // 调整凹槽边距
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: _buildBottomItem(Icons.history, "历史", 0),
                  ),
                  const SizedBox(width: 100), // 为中间按钮留出更多空间，凹槽往左
                  Padding(
                    padding: const EdgeInsets.only(right: 60),
                    child: _buildBottomItem(Icons.person, "我的", 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // 底部导航按钮组件 - 只显示图标，无点击效果
  Widget _buildBottomItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Icon(
          icon,
          color: _currentIndex == index ? Colors.pink : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
