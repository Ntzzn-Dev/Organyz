import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:organyz/database_helper.dart';
import 'package:organyz/itens/itemcard.dart';
import 'package:organyz/itens/popup.dart';
import 'package:organyz/itens/popuplist.dart';
import 'package:organyz/layouts/quests.dart';
import 'package:organyz/themes.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class PendantPage extends StatefulWidget {
  @override
  _PendantPageState createState() => _PendantPageState();
}

class _PendantPageState extends State<PendantPage> {
  late final ValueNotifier<DateTime> _focusedDay;
  late final ValueNotifier<DateTime> _selectedDay;
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> eventsActual = [];
  final Map<int, ValueNotifier<String>> taskMap = {};

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
    _atualizarEventos();
    setState(() {});
  }

  void _openQuests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestsPage(),
        settings: RouteSettings(name: 'questspg'),
      ),
    ).then((_) {
      _loadItems();
    });
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

  Color corState(int state) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    switch (state) {
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

  String nomeState(int state) {
    switch (state) {
      case 0:
        return 'iniciado';
      case 1:
        return 'em andamento';
      case 2:
        return 'concluida';
      default:
        return 'error';
    }
  }

  void _atualizarEventos() {
    setState(() {
      final selected = _selectedDay.value;

      final eventoDoDia =
          events.where((evento) {
            final datafinal = DateFormat(
              'dd/MM/yyyy',
            ).parse(evento['datafinal']);
            return DateTime(datafinal.year, datafinal.month, datafinal.day) ==
                DateTime(selected.year, selected.month, selected.day);
          }).toList();

      eventsActual = eventoDoDia;
    });
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
      body: Stack(
        children: [
          Column(
            children: [
              TableCalendar(
                locale: 'pt_BR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay.value,
                rowHeight: 40,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay.value, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay.value = selectedDay;
                    _focusedDay.value = focusedDay;
                  });

                  _atualizarEventos();
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
                    color:
                        Theme.of(context).extension<CustomColors>()!.weekends,
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
                child: Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.only(top: 25, bottom: 70),
                      itemCount: eventsActual.length,
                      itemBuilder: (context, index) {
                        final indNtf = taskMap.putIfAbsent(
                          eventsActual[index]['ordem'],
                          () => ValueNotifier(
                            "${eventsActual[index]['ind']}${eventsActual[index]['title']}",
                          ),
                        );
                        ValueNotifier<String> subtitleNtf =
                            ValueNotifier<String>(
                              eventsActual[index]['datafinal'],
                            );
                        ValueNotifier<String> descNtf = ValueNotifier<String>(
                          eventsActual[index]['desc'],
                        );
                        final ValueNotifier<int> stateNtf = ValueNotifier<int>(
                          eventsActual[index]['estado'],
                        );
                        bool haveQuest = eventsActual[index]['porcent'] != null;
                        return ItemCard(
                          id: index,
                          titleNtf: indNtf,
                          type: eventsActual[index]['type'],
                          subtitleNtf: subtitleNtf,
                          descNtf: descNtf,
                          doAnythingUp: ValueListenableBuilder(
                            valueListenable: stateNtf,
                            builder: (context, state, _) {
                              return ElevatedButton(
                                onPressed: () async {
                                  if (!haveQuest) {
                                    int newState = state + 1;

                                    if (newState >= 3) {
                                      newState = 0;

                                      bool aceito = await showPopup(
                                        context,
                                        'Reiniciar estado?',
                                        [],
                                      );
                                      if (!aceito) {
                                        return;
                                      }
                                    }

                                    stateNtf.value = newState;

                                    await DatabaseHelper().saveTask(
                                      eventsActual[index]['id'],
                                      newState,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(4),
                                  fixedSize: const Size(120, 48),
                                  backgroundColor: corState(state),
                                ),
                                child: Text(
                                  haveQuest
                                      ? "${eventsActual[index]['porcent']}%"
                                      : nomeState(state),
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 242, 242, 242),
                                  ),
                                ),
                              );
                            },
                          ),
                          doAnythingDown:
                              haveQuest
                                  ? ElevatedButton(
                                    onPressed: () async {
                                      List<Map<String, dynamic>> quests =
                                          await DatabaseHelper().getTaskQuest(
                                            eventsActual[index]['id'],
                                          );

                                      quests =
                                          quests.map((item) {
                                            return {
                                              'valor1': item['title'],
                                              'valor2':
                                                  item['completed'] == 0
                                                      ? '...'
                                                      : '✓',
                                            };
                                          }).toList();

                                      showPopupList(context, "Quests", quests, [
                                        {
                                          'name': 'Titulo',
                                          'flex': 3,
                                          'centralize': false,
                                        },
                                        {
                                          'name': 'Estado',
                                          'flex': 1,
                                          'centralize': true,
                                        },
                                      ]);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(4),
                                    ),
                                    child: Icon(Icons.assignment),
                                  )
                                  : SizedBox.shrink(),
                          onPressedCard: () {
                            eventsActual[index]['opened'] =
                                !eventsActual[index]['opened'];
                          },
                          isExpanded: eventsActual[index]['opened'],
                        );
                      },
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Tasks do dia:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 0,
            left: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 4),
                      Text('Atrasados'),
                    ],
                  ),
                  onPressed: () async {
                    if (!await showPopup(
                      context,
                      'Deletar tarefas que ja passaram da data final?',
                      [],
                    )) {
                      return;
                    }

                    await DatabaseHelper().removeOldTasks();

                    _loadItems();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tasks antigas deletadas')),
                    );
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 4),
                      Text('Concluídos'),
                    ],
                  ),
                  onPressed: () async {
                    /*
                    if (!await showPopup(
                      context,
                      'Deletar tarefas concluídas?',
                      [],
                    )) {
                      return;
                    }

                    await DatabaseHelper().removeCompleteTasks();

                    _loadItems();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tasks concluídas deletadas')),
                    );*/
                    _loadItems();
                  },
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).extension<CustomColors>()!.concluido,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.assignment, color: Colors.white, size: 20),
                    onPressed: () {
                      _openQuests();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
