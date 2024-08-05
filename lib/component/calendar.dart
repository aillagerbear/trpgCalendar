import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final bool Function(DateTime) selectedDayPredicate;
  final Function(DateTime) onPageChanged;
  final Color selectedDayColor;

  const Calendar({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    required this.selectedDayPredicate,
    required this.onPageChanged,
    this.selectedDayColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: focusedDay,
      firstDay: DateTime(focusedDay.year - 1, focusedDay.month, focusedDay.day),
      lastDay: DateTime(focusedDay.year + 1, focusedDay.month, focusedDay.day),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      onDaySelected: onDaySelected,
      selectedDayPredicate: selectedDayPredicate,
      onPageChanged: onPageChanged,
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: selectedDayColor,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: selectedDayColor.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}