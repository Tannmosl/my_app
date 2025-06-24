import 'package:flutter/material.dart';

// TimeRangeクラスは変更なし
class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;
  TimeRange(this.start, this.end);
}

class TimeRangePickerOverlay extends StatefulWidget {
  final TimeOfDay initialStartTime;
  final TimeOfDay initialEndTime;

  const TimeRangePickerOverlay({
    super.key,
    required this.initialStartTime,
    required this.initialEndTime,
  });

  @override
  State<TimeRangePickerOverlay> createState() => _TimeRangePickerOverlayState();
}

class _TimeRangePickerOverlayState extends State<TimeRangePickerOverlay> {
  late FixedExtentScrollController _startHourController;
  late FixedExtentScrollController _startMinuteController;
  late FixedExtentScrollController _endHourController;
  late FixedExtentScrollController _endMinuteController;

  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;

  @override
  void initState() {
    super.initState();
    _selectedStartTime = widget.initialStartTime;
    _selectedEndTime = widget.initialEndTime;

    _startHourController = FixedExtentScrollController(initialItem: _selectedStartTime.hour);
    _startMinuteController = FixedExtentScrollController(initialItem: _selectedStartTime.minute);
    _endHourController = FixedExtentScrollController(initialItem: _selectedEndTime.hour);
    _endMinuteController = FixedExtentScrollController(initialItem: _selectedEndTime.minute);
  }

  @override
  void dispose() {
    _startHourController.dispose();
    _startMinuteController.dispose();
    _endHourController.dispose();
    _endMinuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4, // 高さを少し調整
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル', style: TextStyle(fontSize: 18, color: Colors.blue)),
                ),
                const Text('時間を選択', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    final range = TimeRange(_selectedStartTime, _selectedEndTime);
                    Navigator.of(context).pop(range);
                  },
                  child: const Text('完了', style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimePickerColumn(
                  hourController: _startHourController,
                  minuteController: _startMinuteController,
                  onHourChanged: (hour) => _selectedStartTime = _selectedStartTime.replacing(hour: hour),
                  onMinuteChanged: (minute) => _selectedStartTime = _selectedStartTime.replacing(minute: minute),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('—', style: TextStyle(fontSize: 24, color: Colors.black)),
                ),
                _buildTimePickerColumn(
                  hourController: _endHourController,
                  minuteController: _endMinuteController,
                  onHourChanged: (hour) => _selectedEndTime = _selectedEndTime.replacing(hour: hour),
                  onMinuteChanged: (minute) => _selectedEndTime = _selectedEndTime.replacing(minute: minute),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerColumn({
    required FixedExtentScrollController hourController,
    required FixedExtentScrollController minuteController,
    required ValueChanged<int> onHourChanged,
    required ValueChanged<int> onMinuteChanged,
  }) {
    return SizedBox(
      width: 140, // 横幅を調整
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildWheel(
            controller: hourController,
            itemCount: 24,
            onSelectedItemChanged: onHourChanged,
          ),
          _buildWheel(
            controller: minuteController,
            itemCount: 60,
            onSelectedItemChanged: onMinuteChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 45, // 項目の高さを調整
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelectedItemChanged,
        // ★★★ ここでデザインを調整 ★★★
        perspective: 0.005,    // 3D効果
        magnification: 1.3,    // 中央の項目を1.3倍に拡大
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            return Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: const TextStyle(fontSize: 20, color: Colors.black87),
              ),
            );
          },
        ),
      ),
    );
  }
}