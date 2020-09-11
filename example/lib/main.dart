import 'package:calendarx/flutter_calendarx.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalendarX Demo',
      locale: Locale('en'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _targetDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CalendarX Demo'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(DateFormat('MMMM y').format(_targetDateTime)),
          CalendarX(
            onCalendarChanged: (DateTime date) => setState(() {
              _targetDateTime = date;
            }),
          ),
          Text(DateFormat('MMMM y').format(_targetDateTime)),
        ],
      ),
    );
  }
}
