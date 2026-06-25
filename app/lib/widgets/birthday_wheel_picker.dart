import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// 滚轮式生日选择器（中文：年 / 月 / 日）
class BirthdayWheelPicker {
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initial,
  }) async {
    final now = DateTime.now();
    final maxDate = DateTime(now.year - 18, now.month, now.day);
    var selected = initial ?? DateTime(now.year - 25, 1, 1);
    if (selected.isAfter(maxDate)) selected = maxDate;

    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (ctx) => _BirthdayWheelSheet(initial: selected, maxDate: maxDate),
    );
  }
}

class _BirthdayWheelSheet extends StatefulWidget {
  final DateTime initial;
  final DateTime maxDate;

  const _BirthdayWheelSheet({required this.initial, required this.maxDate});

  @override
  State<_BirthdayWheelSheet> createState() => _BirthdayWheelSheetState();
}

class _BirthdayWheelSheetState extends State<_BirthdayWheelSheet> {
  static const _minYear = 1950;

  late FixedExtentScrollController _yearCtrl;
  late FixedExtentScrollController _monthCtrl;
  late FixedExtentScrollController _dayCtrl;

  late int _year;
  late int _month;
  late int _day;

  @override
  void initState() {
    super.initState();
    _year = widget.initial.year;
    _month = widget.initial.month;
    _day = widget.initial.day;
    _clampDay();
    _yearCtrl = FixedExtentScrollController(initialItem: _year - _minYear);
    _monthCtrl = FixedExtentScrollController(initialItem: _month - 1);
    _dayCtrl = FixedExtentScrollController(initialItem: _day - 1);
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  int get _maxYear => widget.maxDate.year;

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  int get _maxDay {
    final dim = _daysInMonth(_year, _month);
    final maxForAge = _year == widget.maxDate.year && _month == widget.maxDate.month
        ? widget.maxDate.day
        : dim;
    return maxForAge.clamp(1, dim);
  }

  List<int> get _months {
    if (_year == widget.maxDate.year) {
      return List.generate(widget.maxDate.month, (i) => i + 1);
    }
    return List.generate(12, (i) => i + 1);
  }

  List<int> get _years => List.generate(_maxYear - _minYear + 1, (i) => _minYear + i);

  List<int> get _days => List.generate(_maxDay, (i) => i + 1);

  void _clampDay() {
    if (_day > _maxDay) _day = _maxDay;
  }

  void _syncDayWheel() {
    _clampDay();
    if (_dayCtrl.hasClients && _dayCtrl.selectedItem != _day - 1) {
      _dayCtrl.jumpToItem(_day - 1);
    }
  }

  DateTime get _selected => DateTime(_year, _month, _day);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
              const Text('选择生日', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton(onPressed: () => Navigator.pop(context, _selected), child: const Text('确定')),
            ],
          ),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: _yearCtrl,
                    itemExtent: 36,
                    onSelectedItemChanged: (i) {
                      setState(() {
                        _year = _years[i];
                        if (_month > _months.length) _month = _months.last;
                        _clampDay();
                        _syncDayWheel();
                      });
                    },
                    children: _years.map((y) => Center(child: Text('$y年'))).toList(),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: _monthCtrl,
                    key: ValueKey('m$_year'),
                    itemExtent: 36,
                    onSelectedItemChanged: (i) {
                      setState(() {
                        _month = _months[i];
                        _clampDay();
                        _syncDayWheel();
                      });
                    },
                    children: _months.map((m) => Center(child: Text('$m月'))).toList(),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: _dayCtrl,
                    key: ValueKey('d$_year$_month'),
                    itemExtent: 36,
                    onSelectedItemChanged: (i) => setState(() => _day = _days[i]),
                    children: _days.map((d) => Center(child: Text('$d日'))).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
        ],
      ),
    );
  }
}
