import 'package:flutter/material.dart';
import 'package:calendar_trpg/component/calendarBanner.dart';
import 'package:calendar_trpg/component/calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:calendar_trpg/const/color.dart';
import 'package:intl/intl.dart';
import 'package:calendar_trpg/screen/login_screen.dart';

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
  bool isLoading = false;
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      print('로그인 상태: 로그인됨');
      print('사용자 ID: ${session.user.id}');
      print('사용자 이메일: ${session.user.email}');
    } else {
      print('로그인 상태: 로그인되지 않음');
    }
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      print('로그아웃 성공');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } catch (error) {
      print('로그아웃 중 오류 발생: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 중 오류가 발생했습니다.')),
      );
    }
  }

  String toDateOnlyString(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = focusedDay;
      isLoading = true;
    });

    try {
      print('데이터베이스에서 모든 데이터 가져오는 중...');

      final response = await Supabase.instance.client.from('items').select().order('date');

      print('데이터베이스 응답: $response');

      if (response != null && response is List) {
        final List<Item> fetchedItems = response
            .map((item) => Item(text: '${item['date']}: ${item['text']}'))
            .toList();

        setState(() {
          items = fetchedItems;
          isLoading = false;
        });

        print('전체 항목 수: ${items.length}');
        print('항목들: ${items.map((item) => item.text).join(', ')}');
      } else {
        print('예상치 못한 응답 형식: $response');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('항목을 가져오는 중 오류 발생: $error');
      setState(() {
        isLoading = false;
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
                              String insertDate = toDateOnlyString(selectedDay);
                              print('데이터베이스에 항목 삽입 중...');
                              print('삽입할 날짜: $insertDate');
                              print('삽입할 텍스트: $text');

                              final response = await Supabase.instance.client
                                  .from('items')
                                  .insert({
                                'date': insertDate,
                                'text': text
                              });

                              print('삽입 쿼리: INSERT INTO items (date, text) VALUES (\'$insertDate\', \'$text\')');
                              print('삽입된 항목 응답: $response');

                              setState(() {
                                items.add(Item(text: '$insertDate: $text'));
                                isLoading = false;
                              });
                              print('항목이 성공적으로 삽입되었습니다.');

                              // 삽입 후 즉시 데이터를 다시 조회
                              await onDaySelected(selectedDay, focusedDay);
                            } catch (error) {
                              print('항목 삽입 중 오류 발생: $error');
                              setState(() {
                                isLoading = false;
                              });
                            }

                            Navigator.pop(context);
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
    final parts = item.text.split(': ');
    final date = parts[0];
    final text = parts.length > 1 ? parts[1] : '';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '날짜: $date',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '입력된 텍스트: $text',
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! < 0) {
      setState(() {
        focusedDay = DateTime(focusedDay.year, focusedDay.month + 1, 1);
      });
    } else if (details.primaryVelocity! > 0) {
      setState(() {
        focusedDay = DateTime(focusedDay.year, focusedDay.month - 1, 1);
      });
    }
    print('집중된 날 변경: $focusedDay');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar TRPG'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: '로그아웃',
          ),
        ],
      ),
      backgroundColor: Colors.white,
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
                      onPageChanged: onPageChanged,
                      selectedDayColor: primaryColor,
                    ),
                  ),
                  if (isLoading)
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final itemDate = item.text.split(':')[0].trim();
                          if (itemDate == toDateOnlyString(selectedDay)) {
                            return buildCard(item);
                          } else {
                            return SizedBox.shrink();
                          }
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
        backgroundColor: primaryColor,
        child: Icon(Icons.add),
      ),
    );
  }
}