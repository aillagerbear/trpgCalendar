import 'package:flutter/material.dart';
import 'calendar.dart'; // Calendar 위젯을 import

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  bool _selectedDayPredicate(DateTime day) {
    return isSameDay(_selectedDay, day);
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar Page')),
      body: Column(
        children: [
          Calendar(
            selectedDay: _selectedDay,
            focusedDay: _focusedDay,
            onDaySelected: _onDaySelected,
            selectedDayPredicate: _selectedDayPredicate,
            onPageChanged: _onPageChanged,  // onPageChanged 추가
          ),
        ],
      ),
    );
  }
}
