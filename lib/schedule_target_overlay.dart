import 'package:flutter/material.dart';
import 'app.dart';
import 'url.dart';

// スケジュールのロック対象（アプリ/URL）を選択するための画面
class ScheduleTargetOverlay extends StatefulWidget {
  const ScheduleTargetOverlay({super.key});

  @override
  State<ScheduleTargetOverlay> createState() => _ScheduleTargetOverlayState();
}

class _ScheduleTargetOverlayState extends State<ScheduleTargetOverlay> {
  List<dynamic> _selectedApps = [];
  List<String> _selectedUrls = [];

  void _openAppSelection() async {
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
                child: Text('戻る', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
              ),
              const Text('ロック対象を選択', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  // 選択したアプリとURLをMap形式で前の画面に返す
                  final result = {
                    'apps': _selectedApps,
                    'urls': _selectedUrls,
                  };
                  Navigator.of(context).pop(result);
                },
                // ボタンのテキストを変更
                child: const Text('時間設定へ', style: TextStyle(fontSize: 18, color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('スケジュールロック', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const Text('自動でロックしたいアプリやWebサイトを選択してください', style: TextStyle(color: Colors.grey)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({required String text, required String trailingText, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Text(text, style: const TextStyle(fontSize: 20)),
            const Spacer(),
            Text(trailingText, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}