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
      final response = await Supabase.instance.client
          .from('selected_dates')
          .insert({'date': selectedDay.toIso8601String()});

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
                child: ListView(
                  padding: EdgeInsets.all(8.0),
                  children: [
                    ScheduleCard(
                      startTime: '오전 10:00',
                      endTime: '오전 12:00',
                      estimatedPlayTime: '2시간',
                      rule: 'D&D 5판',
                      scenario: '파인들버의 잃어버린 광산',
                      participants: '앨리스, 밥, 찰리',
                      keeper: '데이브',
                      players: '이브, 프랭크, 그레이스',
                    ),
                    ScheduleCard(
                      startTime: '오후 2:00',
                      endTime: '오후 4:00',
                      estimatedPlayTime: '2시간',
                      rule: '패스파인더',
                      scenario: '룬 군주의 부활',
                      participants: '헨리, 이안, 잭',
                      keeper: '케이트',
                      players: '레오, 미아, 니나',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String estimatedPlayTime;
  final String rule;
  final String scenario;
  final String participants;
  final String keeper;
  final String players;

  const ScheduleCard({
    required this.startTime,
    required this.endTime,
    required this.estimatedPlayTime,
    required this.rule,
    required this.scenario,
    required this.participants,
    required this.keeper,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('시작 시간', startTime),
            _buildRow('종료 예정 시간', endTime),
            _buildRow('플레이 예상 시간', estimatedPlayTime),
            _buildRow('룰', rule),
            _buildRow('시나리오', scenario),
            _buildRow('참가자', participants),
            _buildRow('키퍼', keeper),
            _buildRow('플레이어', players),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
