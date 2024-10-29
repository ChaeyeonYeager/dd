import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'mood_selector.dart';
import 'drawer_menu.dart';
import 'diary_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF6200EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6200EE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      drawer: DrawerMenu(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TableCalendar(
              locale: 'en_US',
              firstDay: DateTime.utc(2014, 1, 1),
              lastDay: DateTime.utc(2033, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) async {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                final hasDiaryEntry = await _checkDiaryEntry(selectedDay);

                if (hasDiaryEntry) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryPage(
                        selectedDate: selectedDay,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MoodSelector(selectedDate: selectedDay),
                    ),
                  );
                }
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayTextStyle: const TextStyle(color: Colors.white),
                todayDecoration: const BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(color: Colors.white),
                defaultTextStyle: const TextStyle(color: Colors.black),
                weekendTextStyle: const TextStyle(color: Colors.black),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 24,
                  color: Colors.purple,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Colors.purple,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Colors.purple,
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekendStyle: TextStyle(color: Colors.black),
                weekdayStyle: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkDiaryEntry(DateTime date) async {
    final querySnapshot = await _firestore
        .collection('diary_entries')
        .where('date', isEqualTo: date.toIso8601String())
        .get();
    return querySnapshot.docs.isNotEmpty;
  }
}
