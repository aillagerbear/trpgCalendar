import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: TableCalendar(
          focusedDay: now,
          firstDay: DateTime(now.year - 1, now.month, now.day),
          lastDay: DateTime(now.year + 1, now.month, now.day),
          onDaySelected: (DateTime selectedDay, DateTime focusDay) {
            setState(() {
              this.selectedDay = selectedDay;
            });
          },
          selectedDayPredicate: (DateTime date){
            if(selectedDay == null) {
              return false;
            }
            return date.isAtSameMomentAs(selectedDay);
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
