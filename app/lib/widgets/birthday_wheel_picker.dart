import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// 滚轮式生日选择器（年 / 月 / 日）
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
      builder: (ctx) {
        var value = selected;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                  const Text('选择生日', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  TextButton(onPressed: () => Navigator.pop(ctx, value), child: const Text('确定')),
                ],
              ),
              SizedBox(
                height: 220,
                child: CupertinoTheme(
                  data: CupertinoThemeData(primaryColor: AppTheme.primary),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: value,
                    minimumDate: DateTime(1950, 1, 1),
                    maximumDate: maxDate,
                    onDateTimeChanged: (d) => value = d,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
            ],
          ),
        );
      },
    );
  }
}
