import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<DateTime> _focusedDay;
  late final ValueNotifier<DateTime> _selectedDay;
  String titulo = '';

  @override
  void initState() {
    super.initState();
    _focusedDay = ValueNotifier(DateTime.now());
    _selectedDay = ValueNotifier(DateTime.now());
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedDay.dispose();
    super.dispose();
  }

  int _indentState(DateTime dia) {
    final eventoDoDia =
        events.where((evento) {
          DateTime datafinal = DateFormat(
            'dd/MM/yyyy',
          ).parse(evento['datafinal']);

          DateTime dataAtual = DateTime(dia.year, dia.month, dia.day);
          return dataAtual == datafinal;
        }).toList();

    if (eventoDoDia.isNotEmpty) {
      return eventoDoDia[0]['estado'];
    } else {
      return -1;
    }
  }

  Color _colorState(DateTime dia) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (_indentState(dia)) {
      case 0:
        return isDark
            ? const Color.fromARGB(255, 165, 139, 101)
            : const Color.fromARGB(255, 75, 76, 83);
      case 1:
        return isDark
            ? const Color.fromARGB(255, 150, 106, 40)
            : const Color.fromARGB(255, 99, 99, 136);
      case 2:
        return isDark
            ? const Color.fromARGB(255, 255, 153, 0)
            : const Color.fromARGB(255, 4, 0, 219);
      default:
        return const Color.fromARGB(255, 128, 128, 128);
    }
  }

  Color _colorSelected(int atualOrSelected, bool isEvent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (atualOrSelected) {
      case 0:
        return isEvent
            ? isDark
                ? const Color.fromARGB(255, 165, 139, 101)
                : const Color.fromARGB(255, 61, 60, 71)
            : isDark
            ? const Color.fromARGB(255, 165, 139, 101)
            : const Color.fromARGB(255, 119, 118, 141);
      case 1:
        return isEvent
            ? isDark
                ? const Color.fromARGB(255, 165, 139, 101)
                : const Color.fromARGB(255, 27, 27, 44)
            : isDark
            ? const Color.fromARGB(255, 165, 139, 101)
            : const Color.fromARGB(255, 41, 41, 56);
      default:
        return const Color.fromARGB(255, 128, 128, 128);
    }
  }

  String _nameState(DateTime dia) {
    switch (_indentState(dia)) {
      case 0:
        return 'iniciado';
      case 1:
        return 'em andamento';
      case 2:
        return 'concluida';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendências'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay.value,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay.value, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay.value = selectedDay;
                _focusedDay.value = focusedDay;

                final eventoDoDia =
                    events.where((evento) {
                      DateTime datafinal = DateFormat(
                        'dd/MM/yyyy',
                      ).parse(evento['datafinal']);

                      DateTime dataSelected = DateTime(
                        selectedDay.year,
                        selectedDay.month,
                        selectedDay.day,
                      );
                      return datafinal == dataSelected;
                    }).toList();

                if (eventoDoDia.isNotEmpty) {
                  titulo = eventoDoDia[0]['title'];
                } else {
                  titulo = '';
                }
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay.value = focusedDay;
            },
            headerStyle: HeaderStyle(formatButtonVisible: false),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.black),
              weekendStyle: TextStyle(color: Colors.red),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                bool isEventDay = _isEventDay(day);
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isEventDay ? _colorState(day) : null,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isEventDay ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isEventDay(day) ? _colorState(day) : null,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _colorSelected(1, _isEventDay(day)),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _colorSelected(0, _isEventDay(day)),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Data selecionada: ${DateFormat('dd/MM/yyyy').format(_selectedDay.value.toLocal())}',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 50),
                Text(titulo, style: TextStyle(fontSize: 18)),
                const SizedBox(height: 50),
                Text(
                  _nameState(_selectedDay.value.toLocal()),
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> events = [
    {
      'datafinal': '10/5/2025',
      'title': 'aniversario',
      'estado': 2,
      'desc': 'NSEI',
    },
    {'datafinal': '15/5/2025', 'title': 'prova', 'estado': 1, 'desc': 'NSEI'},
    {
      'datafinal': '20/6/2025',
      'title': 'tarefinha',
      'estado': 0,
      'desc': 'NSEI',
    },
  ];

  bool _isEventDay(DateTime day) {
    return events.any((event) {
      DateTime datafinal = DateFormat('dd/MM/yyyy').parse(event['datafinal']);
      return datafinal.year == day.year &&
          datafinal.month == day.month &&
          datafinal.day == day.day;
    });
  }
}
