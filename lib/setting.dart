// setting.dart

import 'package:flutter/material.dart';
import 'lock_setting.dart';
import 'app.dart';
import 'url.dart';
import 'setting2.dart';

class SettingOverlay extends StatefulWidget {
  const SettingOverlay({super.key});

  @override
  State<SettingOverlay> createState() => _SettingOverlayState();
}

class _SettingOverlayState extends State<SettingOverlay> {
  // Applicationクラスが使えないため、List<dynamic>に変更
  List<dynamic> _selectedApps = [];
  List<String> _selectedUrls = [];
  Duration _selectedDuration = const Duration(minutes: 30);

  void _openAppSelection() async {
    // 戻り値の型も List<dynamic> に変更
    final result = await showModalBottomSheet<List<dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppSelectionOverlay(initialApps: _selectedApps),
    );
    if (result != null) {
      setState(() => _selectedApps = result);
    }
  }

  void _openUrlInput() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UrlInputOverlay(initialUrls: _selectedUrls),
    );
    if (result != null) {
      setState(() => _selectedUrls = result);
    }
  }

  void _openTimeSetting() async {
    final duration = await showModalBottomSheet<Duration>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          TimeSettingOverlay(initialDuration: _selectedDuration),
    );

    if (duration != null) {
      setState(() {
        _selectedDuration = duration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4F8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('戻る',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600])),
              ),
              const Text('基本設定',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  final finalSetting = LockSetting(
                    duration: _selectedDuration,
                    apps: _selectedApps,
                    urls: _selectedUrls,
                  );
                  Navigator.of(context).pop(finalSetting);
                },
                child: const Text('完了',
                    style: TextStyle(fontSize: 18, color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('ロック',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const Text('ロックをかけたいアプリ、Webサイト、時間を選択',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Column(
              children: [
                _buildListItem(
                  text: 'アプリ',
                  trailingText: '${_selectedApps.length}個 選択',
                  onTap: _openAppSelection,
                ),
                const Divider(height: 1, indent: 16),
                _buildListItem(
                  text: 'Webサイト',
                  trailingText: '${_selectedUrls.length}個 選択',
                  onTap: _openUrlInput,
                ),
                const Divider(height: 1, indent: 16),
                _buildListItem(
                  text: '時間',
                  trailingText:
                      '${_selectedDuration.inHours}h ${_selectedDuration.inMinutes % 60}m',
                  onTap: _openTimeSetting,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
      {required String text,
      required String trailingText,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Text(text, style: const TextStyle(fontSize: 20)),
            const Spacer(),
            Text(trailingText,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}