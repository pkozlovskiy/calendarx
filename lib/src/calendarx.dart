library calendarx;

import 'package:date_utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'calendarx_theme.dart';

typedef Widget WeekdayBuilder(int weekday, String weekdayName);

enum CalendarMode { month, week }

typedef Widget DayBuilder(
    bool isSelectable,
    int index,
    bool isSelectedDay,
    bool isToday,
    bool isPrevMonthDay,
    TextStyle textStyle,
    bool isNextMonthDay,
    bool isThisMonthDay,
    DateTime day);

class CalendarX extends StatefulWidget {
  /// See: [ScrollView.scrollDirection]
  final Axis scrollDirection;

  /// See: [ScrollView.reverse]
  final bool reverse;

  /// See: [ScrollView.controller]
  final InfiniteScrollController controller;

  /// See: [ScrollView.physics]
  final ScrollPhysics physics;

  /// See: [ListView.itemExtent]
  final double itemExtent;

  /// See: [ScrollView.cacheExtent]
  final double cacheExtent;

  /// See: [ScrollView.anchor]
  final double anchor;

  /// See: [BoxScrollView.padding]
  final EdgeInsets padding;

  final DateTime selectedDateTime;
  final DateTime targetDateTime;
  final CalendarXTheme theme;
  final String locale;
  final WeekdayBuilder customWeekDayBuilder;
  final DayBuilder customDayBuilder;
  final bool showWeekDays;
  final int firstDayOfWeek;
  final Function(DateTime) onCalendarChanged;
  final Function(DateTime) onDayPressed;
  final CalendarMode calendarMode;

  CalendarX({
    Key key,
    InfiniteScrollController controller,
    int itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    this.showWeekDays = true,
    this.customWeekDayBuilder,
    this.customDayBuilder,
    this.selectedDateTime,
    this.targetDateTime,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.physics,
    this.padding,
    this.itemExtent,
    this.cacheExtent,
    this.anchor = 0.0,
    this.locale = "en",
    this.firstDayOfWeek,
    this.calendarMode = CalendarMode.month,
    theme,
    this.onDayPressed,
    this.onCalendarChanged,
  })  : controller = controller ?? InfiniteScrollController(),
        theme = theme ?? CalendarXTheme.fallback(),
        super(key: key);

  @override
  _CalendarXState createState() => _CalendarXState();
}

class _CalendarXState extends State<CalendarX> {
  /// See: [ListView.childrenDelegate]
  SliverChildDelegate negativeChildrenDelegate;

  /// See: [ListView.childrenDelegate]
  SliverChildDelegate positiveChildrenDelegate;

  DateTime now = DateTime.now();

  DateTime _selectedDate;
  DateTime _targetDate;
  DateFormat _localeDate;
  int firstDayOfWeek;

  double _cellHeight = 30;

  @override
  void initState() {
    initializeDateFormatting();

    _selectedDate = widget.selectedDateTime ?? DateTime.now();
    _targetDate = widget.targetDateTime ?? _selectedDate;
    _localeDate = DateFormat.yMMM(widget.locale);
    if (widget.firstDayOfWeek == null)
      firstDayOfWeek = (_localeDate.dateSymbols.FIRSTDAYOFWEEK + 1) % 7;
    else
      firstDayOfWeek = widget.firstDayOfWeek;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    positiveChildrenDelegate = SliverChildBuilderDelegate(
      (BuildContext context, int index) => _buildPage(context, index),
    );
    negativeChildrenDelegate = SliverChildBuilderDelegate(
      (BuildContext context, int index) => _buildPage(context, -1 - index),
    );
    final List<Widget> slivers = _buildSlivers(context, negative: false);
    final List<Widget> negativeSlivers = _buildSlivers(context, negative: true);
    final AxisDirection axisDirection = _getDirection(context);
    final scrollPhysics = AlwaysScrollableScrollPhysics(parent: widget.physics);
    return LimitedBox(
      maxHeight: _getRowCnt(_targetDate) * _cellHeight,
      child: Scrollable(
        axisDirection: axisDirection,
        controller: widget.controller,
        physics: scrollPhysics,
        viewportBuilder: (BuildContext context, ViewportOffset offset) {
          return Builder(builder: (BuildContext context) {
            final state = Scrollable.of(context);
            final negativeOffset = _InfiniteScrollPosition(
              physics: scrollPhysics,
              context: state,
              initialPixels: -offset.pixels,
              keepScrollOffset: widget.controller.keepScrollOffset,
              negativeScroll: true,
            );

            offset.addListener(() {
              negativeOffset._forceNegativePixels(offset.pixels);
            });

            return Stack(
              children: <Widget>[
                Viewport(
                  axisDirection: flipAxisDirection(axisDirection),
                  anchor: 1.0 - widget.anchor,
                  offset: negativeOffset,
                  slivers: negativeSlivers,
                  cacheExtent: widget.cacheExtent,
                ),
                Viewport(
                  axisDirection: axisDirection,
                  anchor: widget.anchor,
                  offset: offset,
                  slivers: slivers,
                  cacheExtent: widget.cacheExtent,
                ),
              ],
            );
          });
        },
      ),
    );
  }

  AxisDirection _getDirection(BuildContext context) {
    return getAxisDirectionFromAxisReverseAndDirectionality(
        context, widget.scrollDirection, widget.reverse);
  }

  List<Widget> _buildSlivers(BuildContext context, {bool negative = false}) {
    Widget sliver;
    if (widget.itemExtent != null) {
      sliver = SliverFixedExtentList(
        delegate:
            negative ? negativeChildrenDelegate : positiveChildrenDelegate,
        itemExtent: widget.itemExtent,
      );
    } else {
      sliver = SliverList(
          delegate:
              negative ? negativeChildrenDelegate : positiveChildrenDelegate);
    }
    if (widget.padding != null) {
      sliver = new SliverPadding(
        padding: negative
            ? widget.padding - EdgeInsets.only(bottom: widget.padding.bottom)
            : widget.padding - EdgeInsets.only(top: widget.padding.top),
        sliver: sliver,
      );
    }
    return <Widget>[sliver];
  }

  Widget _buildPage(BuildContext context, int index) {
    _targetDate = DateTime(now.year, now.month + index);

    var firstDayOfWeek = Utils.firstDayOfWeek(_targetDate);
    var lastDayOfWeek = Utils.lastDayOfWeek(Utils.lastDayOfMonth(_targetDate));

    if (widget.onCalendarChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCalendarChanged(_targetDate);
      });
    }
    return LimitedBox(
      maxWidth: MediaQuery.of(context).size.width,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 7,
        childAspectRatio: MediaQuery.of(context).size.width / 7 / _cellHeight,
        children: List.generate(lastDayOfWeek.difference(firstDayOfWeek).inDays,
            (index) {
          return _renderDay(firstDayOfWeek.add(Duration(days: index)));
        }),
      ),
    );
  }

  int _getRowCnt(DateTime targetDateTime) {
    var firstDayOfWeek = Utils.firstDayOfWeek(targetDateTime);
    var lastDayOfWeek =
        Utils.lastDayOfWeek(Utils.lastDayOfMonth(targetDateTime));
    return lastDayOfWeek.difference(firstDayOfWeek).inDays ~/ 7;
  }

  int daysInMonth(DateTime date) {
    var firstDayThisMonth = new DateTime(date.year, date.month, date.day);
    var firstDayNextMonth = new DateTime(firstDayThisMonth.year,
        firstDayThisMonth.month + 1, firstDayThisMonth.day);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  Widget _renderDay(DateTime dateTime) {
    return Center(
      child: Text(dateTime.day.toString()),
    );
  }
}

class InfiniteScrollController extends ScrollController {
  InfiniteScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String debugLabel,
  }) : super(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
        );

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition oldPosition) {
    return _InfiniteScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class _InfiniteScrollPosition extends ScrollPositionWithSingleContext {
  _InfiniteScrollPosition({
    @required ScrollPhysics physics,
    @required ScrollContext context,
    double initialPixels = 0.0,
    bool keepScrollOffset = true,
    ScrollPosition oldPosition,
    String debugLabel,
    this.negativeScroll = false,
  })  : assert(negativeScroll != null),
        super(
          physics: physics,
          context: context,
          initialPixels: initialPixels,
          keepScrollOffset: keepScrollOffset,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        );

  final bool negativeScroll;

  void _forceNegativePixels(double value) {
    super.forcePixels(-value);
  }

  @override
  void saveScrollOffset() {
    if (!negativeScroll) {
      super.saveScrollOffset();
    }
  }

  @override
  void restoreScrollOffset() {
    if (!negativeScroll) {
      super.restoreScrollOffset();
    }
  }

  @override
  double get minScrollExtent => double.negativeInfinity;

  @override
  double get maxScrollExtent => double.infinity;
}
