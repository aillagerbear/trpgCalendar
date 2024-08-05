import 'package:flutter/material.dart';
import 'package:calendar_trpg/component/calendarBanner.dart';
import 'package:calendar_trpg/component/calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:calendar_trpg/const/color.dart'; // primaryColor import
import 'package:flutter/gestures.dart';

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

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
  List<String> items = []; // Sample list to represent added items

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
    return isSameDay(selectedDay, date);
  }

  void onPageChanged(DateTime focusedDay) {
    setState(() {
      this.focusedDay = focusedDay;
    });
  }

  void _showInputModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Enter information'),
                    onSubmitted: (value) {
                      setState(() {
                        items.add(value);
                      });
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Add the logic to save the information
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! < 0) {
      // Swiped Left, move to next month
      setState(() {
        focusedDay = DateTime(focusedDay.year, focusedDay.month + 1, 1);
      });
    } else if (details.primaryVelocity! > 0) {
      // Swiped Right, move to previous month
      setState(() {
        focusedDay = DateTime(focusedDay.year, focusedDay.month - 1, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // 배경색을 흰색으로 설정
      body: SafeArea(
        child: Column(
          children: [
            calendarBanner(
              selectedDay: selectedDay,
              taskCount: items.length,
            ),
            Expanded(
              child: Column(
                children: [
                  GestureDetector(
                    onHorizontalDragEnd: _onHorizontalDragEnd,
                    child: Calendar(
                      selectedDay: selectedDay,
                      focusedDay: focusedDay,
                      onDaySelected: onDaySelected,
                      selectedDayPredicate: selectedDayPredicate,
                      onPageChanged: onPageChanged, // onPageChanged 추가
                    ),
                  ),
                  if (isLoading)
                    CircularProgressIndicator()  // 로딩 표시
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(items[index]),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInputModal,
        backgroundColor: primaryColor,  // 플로팅 버튼 색상 설정
        child: Icon(Icons.add),
      ),
    );
  }
}
