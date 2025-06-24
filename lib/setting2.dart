import 'package:flutter/material.dart';
import 'drum.dart'; // ドラムロールピッカーの画面をインポート

class TimeSettingOverlay extends StatefulWidget {
  final Duration initialDuration;
  const TimeSettingOverlay({super.key, required this.initialDuration});

  @override
  State<TimeSettingOverlay> createState() => _TimeSettingOverlayState();
}

class _TimeSettingOverlayState extends State<TimeSettingOverlay> {
  late Duration _displayDuration;

  @override
  void initState() {
    super.initState();
    _displayDuration = widget.initialDuration;
  }

  void _openDrumRollPicker() async {
    final result = await showModalBottomSheet<Duration>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DrumRollPickerOverlay(initialDuration: _displayDuration),
    );

    if (result != null) {
      setState(() {
        _displayDuration = result;
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
                onPressed: () => Navigator.of(context).pop(), // キャンセルの意味で、何も返さずに閉じる
                child: Text('戻る', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
              ),
              const Text('時間設定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.of(context).pop(_displayDuration), // 決定した時間を返す
                child: const Text('完了', style: TextStyle(fontSize: 18, color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('時間', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const Text('ロックする時間を設定してください', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          InkWell(
            onTap: _openDrumRollPicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)]),
              child: Center(
                child: Text(
                  '${_displayDuration.inHours.toString().padLeft(2, '0')} 時   ${(_displayDuration.inMinutes % 60).toString().padLeft(2, '0')} 分',
                  style: const TextStyle(fontSize: 28, letterSpacing: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}