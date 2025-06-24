import 'package:flutter/material.dart';

// --- 開発者向けメモ ---
// ビルドエラーを解決するため、一時的にアプリ選択機能を無効化しています。

class AppSelectionOverlay extends StatefulWidget {
  final List<dynamic> initialApps;
  const AppSelectionOverlay({super.key, required this.initialApps});

  @override
  State<AppSelectionOverlay> createState() => _AppSelectionOverlayState();
}

class _AppSelectionOverlayState extends State<AppSelectionOverlay> {
  late Set<String> _selectedPackageNames;

  @override
  void initState() {
    super.initState();
    _selectedPackageNames = {};
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("戻る"),
                ),
                const Text("アプリを選択", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop([]);
                  },
                  child: const Text("完了"),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "現在、アプリ選択機能は一時的に無効化されています。\nビルドの問題を解決した後、この機能は復活します。",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}