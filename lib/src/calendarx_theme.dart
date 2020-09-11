library calendarx;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CalendarXTheme with Diagnosticable {
  final TextStyle daysTextStyle;
  final TextStyle weekdayTextStyle;
  final TextStyle weekendWeekdayTextStyle;
  final TextStyle weekendTextStyle;

  factory CalendarXTheme({
    TextStyle daysTextStyle,
    TextStyle weekdayTextStyle,
    TextStyle weekendWeekdayTextStyle,
    TextStyle weekendTextStyle,
  }) {
    daysTextStyle ??= const TextStyle(
      fontSize: 20.0,
      color: Colors.blue,
    );
    weekdayTextStyle ??= const TextStyle(
      color: Color(0xff989898),
      fontSize: 14.0,
    );
    weekendWeekdayTextStyle ??= const TextStyle(
      color: Colors.pinkAccent,
      fontSize: 14.0,
    );
    weekendTextStyle ??= const TextStyle(
      color: Colors.black,
      fontSize: 18.0,
    );
    return CalendarXTheme.raw(
      daysTextStyle: daysTextStyle,
      weekdayTextStyle: weekdayTextStyle,
      weekendWeekdayTextStyle: weekendWeekdayTextStyle,
      weekendTextStyle: weekendTextStyle,
    );
  }

  const CalendarXTheme.raw({
    @required this.daysTextStyle,
    @required this.weekdayTextStyle,
    @required this.weekendWeekdayTextStyle,
    @required this.weekendTextStyle,
  });

  factory CalendarXTheme.fallback() => CalendarXTheme();
}
