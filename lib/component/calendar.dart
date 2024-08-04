import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  final DateTime selectedDay;
  final Function(DateTime, DateTime) onDaySelected;

  const Calendar({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: now,
      firstDay: DateTime(now.year - 1, now.month, now.day),
      lastDay: DateTime(now.year + 1, now.month, now.day),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      onDaySelected: onDaySelected,
      selectedDayPredicate: (DateTime date) {
        if (selectedDay == null) {
          return false;
        }
        return date.isAtSameMomentAs(selectedDay);
      },
    );
  }
}
