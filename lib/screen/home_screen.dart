import 'package:calendar_trpg/component/calendarBanner.dart';
import 'package:flutter/material.dart';
import 'package:calendar_trpg/component/calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  DateTime focusedDay = DateTime.now();
  bool isLoading = false;  // 비동기 작업 상태

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = focusedDay;
      isLoading = true;  // 비동기 작업 시작
    });

    print('Selected day: $selectedDay');

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw 'User is not authenticated';
      }

      final response = await Supabase.instance.client
          .from('selected_dates')
          .insert({
        'user_id': user.id,  // 유저 ID 추가
        'date': selectedDay.toIso8601String()
      });

      if (response.error != null) {
        // 에러 처리
        print('Error inserting date: ${response.error!.message}');
      } else {
        print('Date inserted successfully');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        isLoading = false;  // 비동기 작업 종료
      });
    }
  }

  bool selectedDayPredicate(DateTime date) {
    return date.isAtSameMomentAs(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // 배경색을 흰색으로 설정
      body: SafeArea(
        child: Column(
          children: [
            Calendar(
              selectedDay: selectedDay,
              focusedDay: focusedDay,
              onDaySelected: onDaySelected,
              selectedDayPredicate: selectedDayPredicate,
            ),
            calendarBanner(
              selectedDay: selectedDay,
              taskCount: 0,
            ),
            if (isLoading)
              CircularProgressIndicator()  // 로딩 표시
            else
              Expanded(
                child: Container(),  // 더미 데이터 카드 제거
              ),
          ],
        ),
      ),
    );
  }
}
