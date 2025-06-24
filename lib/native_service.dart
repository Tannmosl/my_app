// native_service.dart

import 'package:flutter/services.dart';
import 'lock_setting.dart';

class NativeService {
  static const _platform = MethodChannel('com.example.my_app/lock_service');

  static Future<void> startLock(LockSetting setting) async {
    try {
      final args = <String, dynamic>{
        'duration_millis': setting.duration.inMilliseconds,
        // 'device_apps'が無効なため、空のリストを渡して一時的にエラーを回避します。
        'app_packages': <String>[],
        'urls': setting.urls,
      };

      await _platform.invokeMethod('startLock', args);
    } on PlatformException catch (e) {
      print("ネイティブ呼び出しに失敗しました: '${e.message}'.");
    }
  }

  static Future<bool> arePermissionsGranted() async {
    try {
      final bool isGranted = await _platform.invokeMethod('checkPermissions');
      return isGranted;
    } on PlatformException catch (e) {
      print("権限チェックに失敗しました: '${e.message}'.");
      return false;
    }
  }

  static Future<void> openAccessibilitySettings() async {
    try {
      await _platform.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (e) {
      print("設定画面を開けませんでした: '${e.message}'.");
    }
  }
}