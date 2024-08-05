import 'package:flutter/material.dart';
import 'package:calendar_trpg/const/color.dart';

class calendarBanner extends StatelessWidget {
  final DateTime selectedDay;
  final int taskCount;

  const calendarBanner({
    required this.selectedDay,
    required this.taskCount,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      color: primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${selectedDay.year}년 ${selectedDay.month}월 ${selectedDay.day}일',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$taskCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}