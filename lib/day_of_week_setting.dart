import 'package:flutter/material.dart';
import 'time_range_picker.dart';
import 'schedule_setting.dart';

class DayOfWeekSettingOverlay extends StatefulWidget {
  final List<dynamic> apps;
  final List<String> urls;

  const DayOfWeekSettingOverlay({
    super.key,
    required this.apps,
    required this.urls,
  });

  @override
  State<DayOfWeekSettingOverlay> createState() => _DayOfWeekSettingOverlayState();
}

class _DayOfWeekSettingOverlayState extends State<DayOfWeekSettingOverlay> {
  final List<bool> _selectedDays = List.generate(7, (_) => false);
  final List<TimeRange> _timeRanges = [
    TimeRange(const TimeOfDay(hour: 11, minute: 0), const TimeOfDay(hour: 12, minute: 0)),
  ];

  void _openTimeRangePicker(int index) async {
    final result = await showModalBottomSheet<TimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimeRangePickerOverlay(
        initialStartTime: _timeRanges[index].start,
        initialEndTime: _timeRanges[index].end,
      ),
    );

    if (result != null) {
      setState(() {
        _timeRanges[index] = result;
      });
    }
  }

  void _addTimeRange() {
    if (_timeRanges.length < 3) {
      setState(() {
        _timeRanges.add(
          TimeRange(const TimeOfDay(hour: 13, minute: 0), const TimeOfDay(hour: 14, minute: 0)),
        );
      });
    }
  }

  void _removeTimeRange(int index) {
    setState(() {
      _timeRanges.removeAt(index);
    });
  }

  int _timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  // 「完了」ボタンが押されたときの処理
  void _onCompletePressed() {
    // 1. 各時間範囲の開始・終了時刻が正しいかチェック
    for (var range in _timeRanges) {
      if (_timeOfDayToMinutes(range.start) >= _timeOfDayToMinutes(range.end)) {
        _showErrorDialog('不正な時間設定です。\n終了時間は開始時間より後に設定してください。');
        return;
      }
    }

    // ★★★ ここからが改善された重複チェックロジック ★★★
    // リストが2つ以上ある場合のみ、重複チェックを行う
    if (_timeRanges.length > 1) {
      // チェックのために、開始時間でソートしたリストを新しく作る
      final sortedRanges = List<TimeRange>.from(_timeRanges);
      sortedRanges.sort((a, b) => _timeOfDayToMinutes(a.start).compareTo(_timeOfDayToMinutes(b.start)));
      
      // 隣り合う要素だけを比較していく
      for (int i = 0; i < sortedRanges.length - 1; i++) {
        final currentEnd = _timeOfDayToMinutes(sortedRanges[i].end);
        final nextStart = _timeOfDayToMinutes(sortedRanges[i + 1].start);
        
        // 【重要】前の範囲の終了時刻が、次の範囲の開始時刻より後になっていれば、
        //  それは必ず「重複」している（部分的な重なり、または内包）
        if (currentEnd > nextStart) {
          _showErrorDialog('時間範囲が重複しています。\n設定を見直してください。');
          return; // 問題があれば処理を中断
        }
      }
    }
    // ★★★ チェックロジックここまで ★★★

    // すべてのチェックをパスした場合、設定を保存して画面を閉じる
    final newSchedule = ScheduleSetting(
      apps: widget.apps,
      urls: widget.urls,
      timeRanges: _timeRanges,
      selectedDays: _selectedDays,
    );
    Navigator.of(context).pop(newSchedule);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool canAddTimeRange = _timeRanges.length < 3;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4F8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('戻る', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
              ),
              const Text('曜日・時間設定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: _onCompletePressed,
                child: const Text('完了', style: TextStyle(fontSize: 18, color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('時間', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _timeRanges.length,
                            itemBuilder: (context, index) {
                              return _buildTimeRangeRow(index);
                            },
                            separatorBuilder: (context, index) => const Divider(height: 20),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: canAddTimeRange ? _addTimeRange : null,
                              icon: const Icon(Icons.add),
                              label: const Text('追加'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canAddTimeRange ? Colors.grey[300] : Colors.grey[400],
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('曜日', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              alignment: WrapAlignment.center,
                              children: List.generate(7, (index) {
                                final days = ['月', '火', '水', '木', '金', '土', '日'];
                                return FilterChip(
                                  label: Text(days[index]),
                                  selected: _selectedDays[index],
                                  onSelected: (bool value) {
                                    setState(() {
                                      _selectedDays[index] = value;
                                    });
                                  },
                                  selectedColor: Colors.blue,
                                  checkmarkColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: _selectedDays[index] ? Colors.white : Colors.black,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: Colors.grey[400]!),
                                  ),
                                );
                              }),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeRow(int index) {
    final timeRange = _timeRanges[index];
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _openTimeRangePicker(index),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_formatTime(timeRange.start), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('—', style: TextStyle(fontSize: 18)),
                  ),
                  Text(_formatTime(timeRange.end), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
        if (index > 0)
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            color: Colors.red,
            onPressed: () => _removeTimeRange(index),
          ),
      ],
    );
  }
}