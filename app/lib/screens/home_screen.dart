import 'package:flutter/material.dart';
import 'discover/discover_screen.dart';
import 'chat/conversation_list_screen.dart';
import 'geo/geo_screen.dart';
import 'blindbox/blindbox_screen.dart';
import 'profile/profile_screen.dart';

/// 主页面 — 底部导航 Tab 切换
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _tabs = [
    _TabItem(Icons.explore_outlined, Icons.explore, '寻觅'),
    _TabItem(Icons.people_outline, Icons.people, '同乡'),
    _TabItem(Icons.casino_outlined, Icons.casino, '盲盒'),
    _TabItem(Icons.chat_outlined, Icons.chat, '消息'),
    _TabItem(Icons.person_outline, Icons.person, '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DiscoverScreen(),              // 寻觅 ✅
          GeoScreen(),                   // 同乡 ✅
          BlindboxScreen(),              // 盲盒 ✅
          ConversationListScreen(),      // 消息 ✅
          ProfileScreen(),               // 我的 ✅
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t.iconOutlined),
                  activeIcon: Icon(t.iconFilled),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

class _TabItem {
  final IconData iconOutlined;
  final IconData iconFilled;
  final String label;
  const _TabItem(this.iconOutlined, this.iconFilled, this.label);
}