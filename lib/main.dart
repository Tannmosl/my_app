import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'pomodoro.dart';
import 'profile.dart';
import 'home_screen.dart';

void main() {
  // アプリ起動時にThemeNotifierを準備
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Providerを介してThemeNotifierの状態を監視
    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) {
        return MaterialApp(
          title: '学習ロック',
          // ★★★ ここからがテーマ設定 ★★★
          theme: ThemeData( // ライトモード用のテーマ
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.blue[50], // ライトモードの背景色
            cardColor: Colors.white, // カードの色
            appBarTheme: AppBarTheme( // AppBarのテーマ
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData( // ダークモード用のテーマ
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF121212), // ダークモードの標準的な背景色
            cardColor: const Color(0xFF1E1E1E), // カードの色
            appBarTheme: AppBarTheme( // AppBarのテーマ
              backgroundColor: const Color(0xFF1E1E1E),
            ),
          ),
          themeMode: theme.themeMode, // Notifierの状態をテーマモードに反映
          // ★★★ ここまで ★★★
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const PomodoroScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'ポモドーロ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'その他',
          ),
        ],
      ),
    );
  }
}