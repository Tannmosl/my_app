import 'package:flutter/material.dart';
// ★★★ 1. 必要なパッケージとファイルをインポートします ★★★
import 'package:provider/provider.dart';
import 'package:in_app_review/in_app_review.dart';
import 'theme_notifier.dart';
import 'sound_setting_screen.dart'; // 通知サウンド設定画面（すでにある場合）

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('その他'),
      ),
      body: ListView(
        children: [
          // --- 設定セクション ---
          _buildSectionHeader('設定'),
          _buildListTile(
            icon: Icons.music_note,
            title: '通知サウンド設定',
            onTap: () {
              // 通知サウンド設定画面へ遷移
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SoundSettingScreen()),
              );
            },
          ),
          _buildListTile(
            icon: Icons.brightness_6,
            title: 'ダークモード設定',
            // ★★★ 2. ダークモード設定の処理を記述 ★★★
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ThemeSelectionDialog(),
              );
            },
          ),
          _buildListTile(
            icon: Icons.notifications,
            title: '通知の管理',
            onTap: () { /* TODO: 通知管理画面へ */ },
          ),
          const Divider(),

          // --- サポートセクション ---
          _buildSectionHeader('サポート & フィードバック'),
          _buildListTile(
            icon: Icons.help_outline,
            title: '使い方ガイド',
            onTap: () { /* TODO: オンボーディングを再表示 */ },
          ),
          _buildListTile(
            icon: Icons.star_outline,
            title: 'レビューで応援する',
            // ★★★ 3. レビュー依頼の処理を記述 ★★★
            onTap: () async {
              final InAppReview inAppReview = InAppReview.instance;
              
              if (await inAppReview.isAvailable()) {
                // ストアのレビューダイアログをアプリ内で表示
                inAppReview.requestReview();
              }
            },
          ),
          _buildListTile(
            icon: Icons.mail_outline,
            title: 'お問い合わせ・ご意見',
            onTap: () { /* TODO: メールやフォームを開く */ },
          ),
          const Divider(),

          // --- このアプリについてセクション ---
          _buildSectionHeader('このアプリについて'),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'プライバシーポリシー',
            onTap: () { /* TODO: プライバシーポリシーのWebページを開く */ },
          ),
          _buildListTile(
            icon: Icons.article_outlined,
            title: '利用規約',
            onTap: () { /* TODO: 利用規約のWebページを開く */ },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('現在のバージョン'),
            trailing: const Text('1.0.0'), // TODO: アプリのバージョンを動的に取得
          ),
        ],
      ),
    );
  }

  // セクションのヘッダーを作るためのヘルパーウィジェット (変更なし)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  // ListTileを共通化するためのヘルパーウィジェット (変更なし)
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// ★★★ 4. テーマ選択ダイアログのWidgetをファイル末尾に追加 ★★★
class ThemeSelectionDialog extends StatelessWidget {
  const ThemeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Providerを介してThemeNotifierにアクセス
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    return AlertDialog(
      title: const Text('ダークモード設定'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('システム設定に従う'),
            value: ThemeMode.system,
            groupValue: themeNotifier.themeMode,
            onChanged: (value) {
              if (value != null) themeNotifier.setMode(value);
              Navigator.of(context).pop();
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('ライトモード'),
            value: ThemeMode.light,
            groupValue: themeNotifier.themeMode,
            onChanged: (value) {
              if (value != null) themeNotifier.setMode(value);
              Navigator.of(context).pop();
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('ダークモード'),
            value: ThemeMode.dark,
            groupValue: themeNotifier.themeMode,
            onChanged: (value) {
              if (value != null) themeNotifier.setMode(value);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}