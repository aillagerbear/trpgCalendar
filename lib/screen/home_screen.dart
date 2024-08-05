import 'package:flutter/material.dart';
import 'package:calendar_trpg/component/calendarBanner.dart';
import 'package:calendar_trpg/component/calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:calendar_trpg/const/color.dart'; // primaryColor import

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class Item {
  final String text;

  Item({required this.text});
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
  bool isLoading = false; // 비동기 작업 상태
  List<Item> items = []; // 빈 리스트로 초기화

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = focusedDay;
      isLoading = true; // 비동기 작업 시작
    });

    print('Selected day: $selectedDay');

    try {
      final response = await Supabase.instance.client
          .from('selected_dates')
          .insert({
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
        isLoading = false; // 비동기 작업 종료
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
    final GlobalKey<FormState> formKey = GlobalKey();
    final TextEditingController textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: textController,
                          decoration: InputDecoration(labelText: '텍스트 입력'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final String text = textController.text;
                            if (text.isEmpty) return;

                            setState(() {
                              isLoading = true;
                            });

                            try {
                              final response = await Supabase.instance.client
                                  .from('items')
                                  .insert({
                                'date': selectedDay.toIso8601String(),
                                'text': text
                              });

                              if (response.error != null) {
                                print('Error inserting item: ${response.error!.message}');
                              } else {
                                setState(() {
                                  items.add(Item(text: text));
                                });
                                print('Item inserted successfully');
                              }
                            } catch (error) {
                              print('Error: $error');
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: Text('저장'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildCard(Item item) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('입력된 텍스트: ${item.text}'),
          ],
        ),
      ),
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
    print('Focused day changed to: $focusedDay');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
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
                    CircularProgressIndicator() // 로딩 표시
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return buildCard(items[index]);
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
        backgroundColor: primaryColor, // 플로팅 버튼 색상 설정
        child: Icon(Icons.add),
      ),
    );
  }
}
