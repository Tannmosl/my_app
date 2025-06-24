import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ドラムロール式ピッカー専用のオーバーレイ
class DrumRollPickerOverlay extends StatefulWidget {
  final Duration initialDuration;

  const DrumRollPickerOverlay({super.key, required this.initialDuration});

  @override
  State<DrumRollPickerOverlay> createState() => _DrumRollPickerOverlayState();
}

class _DrumRollPickerOverlayState extends State<DrumRollPickerOverlay> {
  late Duration _selectedDuration;

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration;
  }

  @override
  Widget build(BuildContext context) {
    // 画面下半分くらいのサイズに自動調整
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFF0F4F8), // 背景色
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ヘッダー
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // 値を返さずに閉じる
                  child: Text('戻る', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ),
                TextButton(
                  onPressed: () {
                    // 選択した時間を結果として返し、この画面を閉じる
                    Navigator.of(context).pop(_selectedDuration);
                  },
                  child: const Text('完了', style: TextStyle(fontSize: 18, color: Colors.blue)),
                ),
              ],
            ),
            // Cupertinoタイマーピッカー
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: _selectedDuration,
                onTimerDurationChanged: (newDuration) {
                  setState(() => _selectedDuration = newDuration);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}