import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'services/auth_provider.dart';
import 'services/match_provider.dart';
import 'services/geo_provider.dart';
import 'services/karma_provider.dart';
import 'services/chat_provider.dart';
import 'services/profile_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const QingtengApp());
}

class QingtengApp extends StatelessWidget {
  const QingtengApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => GeoProvider()),
        ChangeNotifierProvider(create: (_) => KarmaProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()..init()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: '青藤之恋',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _AuthGate(),
        routes: {
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

/// 认证网关：检查本地 Token 决定跳转登录页还是主页
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final auth = context.read<AuthProvider>();
    await auth.checkLoginStatus();
    if (mounted) {
      setState(() => _checking = false);
      if (auth.isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const LoginScreen();
  }
}