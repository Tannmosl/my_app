import 'package:flutter/material.dart';
import 'app.dart';
import 'url.dart';
import 'count_limit_setting.dart'; // ステップ1で作成したクラスをインポート

class NumberOfTimesOverlay extends StatefulWidget {
  const NumberOfTimesOverlay({super.key});

  @override
  State<NumberOfTimesOverlay> createState() => _NumberOfTimesOverlayState();
}

class _NumberOfTimesOverlayState extends State<NumberOfTimesOverlay> {
  List<dynamic> _selectedApps = [];
  List<String> _selectedUrls = [];
  int _limitCount = 3; // 回数の初期値

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

  void _increment() {
    setState(() {
      _limitCount++;
    });
  }

  void _decrement() {
    if (_limitCount > 1) {
      setState(() {
        _limitCount--;
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
        children: [
          // ヘッダー
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('戻る', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
              ),
              const Text('回数設定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  final newSetting = CountLimitSetting(
                    apps: _selectedApps,
                    urls: _selectedUrls,
                    limitCount: _limitCount,
                  );
                  Navigator.of(context).pop(newSetting);
                },
                child: const Text('完了', style: TextStyle(fontSize: 18, color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 設定リスト
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('対象を選択', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                  const SizedBox(height: 24),
                  const Text('上限回数を設定', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                  // 回数設定カード
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 32),
                            onPressed: _decrement,
                            color: Colors.grey[600],
                          ),
                          Text(
                            '${_limitCount}x',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 32),
                            onPressed: _increment,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
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