import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color workColor = Color(0xFF4A6572); 
const Color breakColor = Color(0xFF558B2F); 
const Color accentColor = Color(0xFFF9AA33);

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> with TickerProviderStateMixin {
  static const int _workDuration = 25 * 60;
  static const int _breakDuration = 5 * 60;

  Timer? _timer;
  int _remainingSeconds = _workDuration;
  bool _isTimerRunning = false;
  bool _isWorkSession = true;

  late AnimationController _colorAnimationController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _colorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _colorAnimationController.value = 1.0;
  }

  void _playAlarmSound() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final soundFile = prefs.getString('selected_sound') ?? 'alarm1.mp3';
      await _audioPlayer.play(AssetSource('sounds/$soundFile'));
    } catch (e) {
      print("サウンドの再生に失敗しました: $e");
    }
  }

  void _startTimer() {
    if (_isTimerRunning) return;
    setState(() => _isTimerRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        _isTimerRunning = false;
        _playAlarmSound(); 
        _switchSession();
      }
    });
  }

  void _pauseTimer() {
    if (!_isTimerRunning) return;
    _timer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    _audioPlayer.stop();
    setState(() {
      _isTimerRunning = false;
      _isWorkSession = true;
      _remainingSeconds = _workDuration;
      _colorAnimationController.animateTo(1.0);
    });
  }

  void _switchSession() async {
    final String title = _isWorkSession ? 'お疲れ様でした！' : '集中を始めましょう';
    final String content = _isWorkSession ? '5分間の休憩を開始します。' : '25分間の集中タイマーを開始します。';
    
    _isWorkSession
        ? _colorAnimationController.animateTo(0.0)
        : _colorAnimationController.animateTo(1.0);

    setState(() {
      _isWorkSession = !_isWorkSession;
      _remainingSeconds = _isWorkSession ? _workDuration : _breakDuration;
    });

    if (mounted) {
       await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
    _startTimer();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _colorAnimationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color currentThemeColor = Color.lerp(breakColor, workColor, _colorAnimationController.value)!;
    final int totalDuration = _isWorkSession ? _workDuration : _breakDuration;
    final double progress = _remainingSeconds / totalDuration;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ポモドーロ'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              _isWorkSession ? 'FOCUS' : 'BREAK',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: currentThemeColor,
                letterSpacing: 4,
              ),
            ),
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 12,
                    backgroundColor: currentThemeColor.withOpacity(0.2),
                  ),
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(currentThemeColor),
                  ),
                  Center(
                    child: Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: currentThemeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _resetTimer,
                  iconSize: 32,
                  color: Colors.grey,
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isTimerRunning ? _pauseTimer : _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  child: Icon(
                    _isTimerRunning ? Icons.pause : Icons.play_arrow,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    _timer?.cancel();
                    _isTimerRunning = false;
                    _playAlarmSound();
                    _switchSession();
                  },
                  iconSize: 32,
                  color: Colors.grey,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}