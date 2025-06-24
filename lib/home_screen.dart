import 'package:flutter/material.dart';
import 'lock_setting.dart';
import 'native_service.dart';
import 'setting.dart';
import 'schedule_setting.dart';
import 'schedule_target_overlay.dart';
import 'day_of_week_setting.dart';
import 'number_of_times.dart';
import 'time_range_picker.dart';
import 'count_limit_setting.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<LockSetting> _lockSettings = [];
  final List<ScheduleSetting> _scheduleSettings = [];
  final List<CountLimitSetting> _countLimitSettings = [];

  // initStateは前回レビュー依頼機能で追加したものです。そのままで問題ありません。
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _checkAndRequestReview();
    // });
  }

  void _openBasicSettings() async {
    final newSetting = await showModalBottomSheet<LockSetting>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingOverlay(),
    );
    if (newSetting != null) {
      setState(() => _lockSettings.add(newSetting));
    }
  }

  void _openScheduleSettingsFlow() async {
    final targets = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ScheduleTargetOverlay(),
    );

    if (targets == null) return;

    final newSchedule = await showModalBottomSheet<ScheduleSetting>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayOfWeekSettingOverlay(
        apps: targets['apps']!,
        urls: targets['urls']!,
      ),
    );

    if (newSchedule != null) {
      setState(() {
        _scheduleSettings.add(newSchedule);
      });
    }
  }

  void _openNumberOfTimesSettings() async {
    final newSetting = await showModalBottomSheet<CountLimitSetting>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NumberOfTimesOverlay(),
    );

    if (newSetting != null) {
      setState(() {
        _countLimitSettings.add(newSetting);
      });
    }
  }

  void _onStartLockPressed(LockSetting setting) async {
    final bool permissionsGranted = await NativeService.arePermissionsGranted();
    if (!mounted) return;
    if (!permissionsGranted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('権限が必要です'),
          content: const Text('アプリのロック機能を使用するには、「ユーザー補助」サービスを有効にする必要があります。設定画面に移動しますか？'),
          actions: [
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('設定を開く'),
              onPressed: () {
                Navigator.of(context).pop();
                NativeService.openAccessibilitySettings();
              },
            ),
          ],
        ),
      );
      return;
    }
    await NativeService.startLock(setting);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ロックを開始しました。'), backgroundColor: Colors.green),
    );
  }

  void _toggleScheduleState(int index, bool newState) {
    setState(() {
      _scheduleSettings[index].isActive = newState;
    });
    // TODO: ここでネイティブ側にON/OFFの状態を通知し、実際のロック処理に反映させる
  }
  
  void _toggleCountLimitState(int index, bool newState) {
    setState(() {
      _countLimitSettings[index].isActive = newState;
    });
    // TODO: ネイティブ側に状態を通知
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ★★★ 修正点①: 固定色の指定を削除 ★★★
      // backgroundColor: Colors.blue[50], 
      // これでmain.dartのテーマ設定(scaffoldBackgroundColor)が自動的に適用されます
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text('学習ロック', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
            _buildSection(
              '基本設定',
              '制限したいアプリ、Webサイトをすぐにロックします',
              _openBasicSettings,
              _lockSettings.map((setting) => _buildLockSettingItem(setting)).toList(),
            ),
            const SizedBox(height: 30),
            _buildSection(
              '曜日設定',
              '指定した曜日・時間に自動でアプリをロックします',
              _openScheduleSettingsFlow,
              [
                for (int i = 0; i < _scheduleSettings.length; i++)
                  _buildScheduleSettingItem(_scheduleSettings[i], i)
              ],
            ),
            const SizedBox(height: 30),
            _buildSection(
              '回数設定',
              '一日にアプリを立ち上げられる回数を決めます',
              _openNumberOfTimesSettings,
              [
                for (int i = 0; i < _countLimitSettings.length; i++)
                  _buildCountLimitItem(_countLimitSettings[i], i)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description, VoidCallback onPressed, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // ★★★ 修正点②: 固定色の指定を、テーマに連動するように変更 ★★★
            color: Theme.of(context).cardColor, 
            // border: Border.all(color: Colors.grey.shade300), // ダークモードで見えにくいため、一旦コメントアウト
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // ボタンの色は固定のままでも良い
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('設定', style: TextStyle(fontSize: 18)),
              ),
              if (items.isNotEmpty) ...[
                const Divider(height: 30, thickness: 1),
                ...items,
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLockSettingItem(LockSetting setting) {
    final title = 'アプリ${setting.apps.length}件, URL${setting.urls.length}件';
    final subtitle = 'ロック時間: ${setting.duration.inHours}時間 ${setting.duration.inMinutes % 60}分';
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: ListTile(
        leading: const Icon(Icons.lock_clock),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.green, size: 30),
          onPressed: () => _onStartLockPressed(setting),
        ),
      ),
    );
  }

  Widget _buildScheduleSettingItem(ScheduleSetting setting, int index) {
    final title = 'アプリ${setting.apps.length}件, URL${setting.urls.length}件';
    final timeRangesString = setting.timeRanges.map((range) {
      final startTime = '${range.start.hour.toString().padLeft(2, '0')}:${range.start.minute.toString().padLeft(2, '0')}';
      final endTime = '${range.end.hour.toString().padLeft(2, '0')}:${range.end.minute.toString().padLeft(2, '0')}';
      return '$startTime - $endTime';
    }).join('\n');
    final subtitle = '${setting.daysAsString}\n$timeRangesString';
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: ListTile(
        leading: const Icon(Icons.schedule),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: setting.isActive,
          onChanged: (bool value) {
            _toggleScheduleState(index, value);
          },
        ),
      ),
    );
  }
  
  Widget _buildCountLimitItem(CountLimitSetting setting, int index) {
    final title = 'アプリ${setting.apps.length}件, URL${setting.urls.length}件';
    final subtitle = '1日の上限回数: ${setting.limitCount}回';
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: ListTile(
        leading: const Icon(Icons.tag),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: setting.isActive,
          onChanged: (bool value) {
            _toggleCountLimitState(index, value);
          },
        ),
      ),
    );
  }
}