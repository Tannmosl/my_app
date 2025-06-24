import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// サウンドの選択肢を管理するためのシンプルなクラス
class SoundOption {
  final String displayName; // 画面に表示する名前
  final String fileName;    // assets/sounds/以下のファイル名

  const SoundOption(this.displayName, this.fileName);
}

// サウンド選択画面
class SoundSettingScreen extends StatefulWidget {
  const SoundSettingScreen({super.key});

  @override
  State<SoundSettingScreen> createState() => _SoundSettingScreenState();
}

class _SoundSettingScreenState extends State<SoundSettingScreen> {
  // アプリ内で選択できるサウンドのリスト
  final List<SoundOption> _soundOptions = [
    const SoundOption('アラーム1', 'alarm1.mp3'),
    const SoundOption('チャイム', 'chime.mp3'),
    const SoundOption('小鳥のさえずり', 'bird.mp3'),
    // ★ここに用意したファイルの数だけ追加してください
  ];

  String? _selectedSoundFile;
  final AudioPlayer _previewPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSelectedSound();
  }
  
  // 保存されている設定を読み込む
  void _loadSelectedSound() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 'selected_sound'というキーで保存されたファイル名を読み込む。
      // なければ、リストの最初の音をデフォルトにする。
      _selectedSoundFile = prefs.getString('selected_sound') ?? _soundOptions.first.fileName;
    });
  }

  // サウンドを選択して保存する
  void _selectSound(SoundOption sound) async {
    // プレビュー再生
    await _previewPlayer.play(AssetSource('sounds/${sound.fileName}'));

    final prefs = await SharedPreferences.getInstance();
    // 'selected_sound'というキーでファイル名を保存
    await prefs.setString('selected_sound', sound.fileName);
    
    setState(() {
      _selectedSoundFile = sound.fileName;
    });
  }
  
  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知サウンド設定'),
      ),
      body: ListView.builder(
        itemCount: _soundOptions.length,
        itemBuilder: (context, index) {
          final sound = _soundOptions[index];
          final isSelected = sound.fileName == _selectedSoundFile;

          return ListTile(
            title: Text(sound.displayName),
            trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
            onTap: () => _selectSound(sound),
          );
        },
      ),
    );
  }
}