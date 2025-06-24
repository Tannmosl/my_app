import 'package:flutter/material.dart';
import 'time_range_picker.dart';

class ScheduleSetting {
  final List<dynamic> apps;
  final List<String> urls;
  final List<TimeRange> timeRanges;
  final List<bool> selectedDays;
  // ★★★ 新しく追加 ★★★
  // スケジュールの有効/無効状態を保持するプロパティ
  bool isActive;

  ScheduleSetting({
    required this.apps,
    required this.urls,
    required this.timeRanges,
    required this.selectedDays,
    // 新しく作るスケジュールはデフォルトで有効(true)にする
    this.isActive = true,
  });

  String get daysAsString {
    const dayLabels = ['月', '火', '水', '木', '金', '土', '日'];
    final selectedLabels = <String>[];
    for (int i = 0; i < selectedDays.length; i++) {
      if (selectedDays[i]) {
        selectedLabels.add(dayLabels[i]);
      }
    }
    if (selectedLabels.isEmpty) return '曜日未設定';
    return selectedLabels.join(', ');
  }
}