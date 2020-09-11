import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../flutter_calendarx.dart';
import 'calendarx_theme.dart';

class WeekdayRow extends StatelessWidget {
  WeekdayRow(
    this.firstDayOfWeek,
    this.weekdayBuilder, {
    @required this.localeDate,
    @required this.calendarTheme,
  });

  final WeekdayBuilder weekdayBuilder;
  final DateFormat localeDate;
  final int firstDayOfWeek;
  final CalendarXTheme calendarTheme;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _renderWeekDays(),
      );

  List<Widget> _renderWeekDays() {
    var list = <Widget>[];

    for (var i = firstDayOfWeek, dayOfWeek = 0;
        dayOfWeek < 7;
        i = (i + 1) % 7, dayOfWeek++) {
      String weekDayName = localeDate.dateSymbols.SHORTWEEKDAYS[i];
      list.add(_weekdayContainer(dayOfWeek, weekDayName));
    }

    return list;
  }

  Widget _weekdayContainer(int weekday, String weekDayName) {
    return weekdayBuilder != null
        ? weekdayBuilder(weekday, weekDayName)
        : Expanded(
            child: Container(
              child: Center(
                child: DefaultTextStyle(
                  style: localeDate.dateSymbols.WEEKENDRANGE.contains(weekday)
                      ? calendarTheme.weekendWeekdayTextStyle
                      : calendarTheme.weekdayTextStyle,
                  child: Text(
                    weekDayName,
                    semanticsLabel: weekDayName,
                  ),
                ),
              ),
            ),
          );
  }
}
