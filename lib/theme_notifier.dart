import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  SharedPreferences? _prefs;
  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    // デフォルトはシステムのテーマに合わせる
    _themeMode = ThemeMode.system;
    _loadFromPrefs();
  }

  // 設定を切り替える
  void setMode(ThemeMode mode) {
    _themeMode = mode;
    _saveToPrefs();
    notifyListeners(); // 変更をUIに通知
  }

  // 起動時に設定を読み込む
  _loadFromPrefs() async {
    await _initPrefs();
    int themeIndex = _prefs!.getInt(key) ?? 0; // 0:System, 1:Light, 2:Dark
    switch (themeIndex) {
      case 1:
        _themeMode = ThemeMode.light;
        break;
      case 2:
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  // 設定を保存する
  _saveToPrefs() async {
    await _initPrefs();
    int themeIndex = 0; // System
    if (_themeMode == ThemeMode.light) {
      themeIndex = 1;
    } else if (_themeMode == ThemeMode.dark) {
      themeIndex = 2;
    }
    _prefs!.setInt(key, themeIndex);
  }

  // SharedPreferencesの初期化
  _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
}