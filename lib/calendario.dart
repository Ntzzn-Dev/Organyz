import 'package:flutter/material.dart';
import 'package:organyz/database_helper.dart';
import 'package:organyz/itemlist.dart';
import 'package:organyz/popup.dart';
import 'package:organyz/themes.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<DateTime> _focusedDay;
  late final ValueNotifier<DateTime> _selectedDay;
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
    _focusedDay = ValueNotifier(DateTime.now());
    _selectedDay = ValueNotifier(DateTime.now());
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedDay.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    events = await DatabaseHelper().getTasks();
    setState(() {});
  }

  bool _isEventDay(DateTime day) {
    return events.any((event) {
      DateTime datafinal = DateFormat('dd/MM/yyyy').parse(event['datafinal']);
      return datafinal.year == day.year &&
          datafinal.month == day.month &&
          datafinal.day == day.day;
    });
  }

  List<int> _indentState(DateTime dia) {
    final eventoDoDia =
        events.where((evento) {
          DateTime datafinal = DateFormat(
            'dd/MM/yyyy',
          ).parse(evento['datafinal']);

          DateTime dataAtual = DateTime(dia.year, dia.month, dia.day);
          return dataAtual == datafinal;
        }).toList();

    if (eventoDoDia.isNotEmpty) {
      return eventoDoDia.map<int>((e) => e['estado'] as int).toList();
    } else {
      return [-1];
    }
  }

  Color _colorState(DateTime dia) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    int diaMenosAvancado = _indentState(dia).reduce((a, b) => a < b ? a : b);

    switch (diaMenosAvancado) {
      case 0:
        return customColors.iniciado;
      case 1:
        return customColors.emAndamento;
      case 2:
        return customColors.concluido;
      default:
        return const Color.fromARGB(255, 128, 128, 128);
    }
  }

  Color _colorSelected(int atualOrSelected, bool isEvent) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    switch (atualOrSelected) {
      case 0:
        return isEvent ? customColors.eventoAtual : customColors.justAtual;
      case 1:
        return isEvent
            ? customColors.eventoSelecionado
            : customColors.justSelecionado;
      default:
        return const Color.fromARGB(255, 128, 128, 128);
    }
  }

  List<Map<String, dynamic>> eventsActual = [];

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
            locale: 'pt_BR',
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
                  eventsActual = eventoDoDia;
                } else {
                  eventsActual = [];
                }
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay.value = focusedDay;
            },
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).extension<CustomColors>()!.months,
                fontStyle: FontStyle.italic,
              ),
              titleTextFormatter:
                  (date, locale) =>
                      DateFormat('MMMM yyyy', locale).format(date),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              dowTextFormatter:
                  (date, locale) =>
                      DateFormat.E(
                        locale,
                      ).format(date).substring(0, 1).toUpperCase(),
              weekdayStyle: TextStyle(
                color: Theme.of(context).extension<CustomColors>()!.days,
              ),
              weekendStyle: TextStyle(
                color: Theme.of(context).extension<CustomColors>()!.weekends,
              ),
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
                      color:
                          isEventDay
                              ? Colors.white
                              : Theme.of(
                                context,
                              ).extension<CustomColors>()!.days,
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
                  decoration: BoxDecoration(
                    color: _isEventDay(day) ? _colorState(day) : null,
                    shape: BoxShape.circle,
                  ),
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

          Expanded(
            child: ListView.builder(
              itemCount: eventsActual.length,
              itemBuilder: (context, index) {
                return ItemExpand(
                  id: index,
                  title: eventsActual[index]['title'],
                  subtitle: eventsActual[index]['datafinal'],
                  desc: eventsActual[index]['desc'],
                  estadoAtual: eventsActual[index]['estado'],
                  onPressedOpen: () async {
                    int state = eventsActual[index]['estado'];
                    state++;

                    if (state >= 3) {
                      state = 0;

                      bool aceito = await showCustomPopup(
                        context,
                        'Reiniciar estado?',
                        [],
                      );
                      if (!aceito) {
                        return;
                      }
                    }
                    await DatabaseHelper().saveTask(
                      eventsActual[index]['id'],
                      state,
                    );
                    eventsActual[index]['estado'] = state;
                    _loadItems();
                  },
                  expandItem: 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
