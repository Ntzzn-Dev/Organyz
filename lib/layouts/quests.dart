import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organyz/database_helper.dart';
import 'package:organyz/itens/itemcard.dart';
import 'package:organyz/itens/itemlist.dart';
import 'package:organyz/itens/popup.dart';
import 'package:organyz/themes.dart';

class QuestsPage extends StatefulWidget {
  @override
  _QuestsPageState createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {
  final Map<int, ValueNotifier<String>> taskMap = {};
  List<Map<String, dynamic>> itens = [];
  int ultimaOrdem = 0;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    itens = await DatabaseHelper().getAllQuestsOrdered();
    ultimaOrdem = itens.length;
    setState(() {});
  }

  Widget itemDesc(
    Map<String, dynamic> quest,
    ValueNotifier<bool> remove,
    void Function(bool) onComplete,
  ) {
    final ValueNotifier<String> titleNtf = ValueNotifier<String>(
      quest['title'],
    );
    final ValueNotifier<String> subtitleNtf = ValueNotifier<String>(
      quest['desc'],
    );
    final ValueNotifier<Color> colorNtf = ValueNotifier<Color>(
      Color.fromARGB(quest['completed'] ? 30 : 15, 0, 0, 0),
    );
    final ValueNotifier<bool> completedNtf = ValueNotifier<bool>(
      quest['completed'],
    );

    if (quest['completed']) {
      onComplete(true);
    }

    return ValueListenableBuilder<bool>(
      key: ValueKey('${quest['id']}_${quest['title']}'),
      valueListenable: remove,
      builder: (context, removeValue, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: completedNtf,
          builder: (context, completedValue, _) {
            return ItemList(
              id: quest['id'],
              type: quest['type'],
              titleNtf: titleNtf,
              subtitleNtf: subtitleNtf,
              paddingN: {'width': 0, 'height': 3},
              doAnythingUp: Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final newValue = !completedNtf.value;
                      onComplete(newValue);
                      if (!removeValue) {
                        quest['completed'] = newValue;
                        completedNtf.value = newValue;

                        colorNtf.value = Color.fromARGB(
                          newValue ? 30 : 15,
                          0,
                          0,
                          0,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                      backgroundColor:
                          removeValue
                              ? Colors.red
                              : completedValue
                              ? Theme.of(
                                context,
                              ).extension<CustomColors>()!.concluido
                              : null,
                    ),
                    child: Icon(
                      completedValue || removeValue ? Icons.close : Icons.check,
                      color:
                          completedValue || removeValue ? Colors.white : null,
                    ),
                  ),
                ],
              ),
              colorNtf: colorNtf,
              onPressedCard: () {
                showCustomPopup(
                  context,
                  'Editar Etapa',
                  [
                    {'value': 'Título', 'type': 'necessary'},
                    {'value': 'Descrição', 'type': 'text'},
                  ],
                  fieldValues: [titleNtf.value, subtitleNtf.value],
                  onConfirm: (valores) async {
                    String title = valores[0];
                    String desc = valores[1];

                    await DatabaseHelper().updateTaskQuest(
                      title,
                      desc,
                      quest['completed'],
                      quest['idtask'],
                      quest['ordem'],
                      quest['id'],
                    );

                    titleNtf.value = title;
                    subtitleNtf.value = desc;

                    quest['title'] = title;
                    quest['desc'] = desc;

                    await ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Etapa Alterada')),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget questCreate(Map<String, dynamic> item, int index) {
    final indNtf = taskMap.putIfAbsent(
      item['ordem'],
      () => ValueNotifier("${item['ind']}${item['title']}"),
    );
    final ValueNotifier<String> subtitleNtf = ValueNotifier<String>(
      DateFormat(
        "d 'de' MMMM 'de' y",
        'pt_BR',
      ).format(DateFormat('dd/MM/yyyy').parse(item['datafinal'])),
    );
    final ValueNotifier<String> descNtf = ValueNotifier<String>(item['desc']);
    final ValueNotifier<String> percentNtf = ValueNotifier<String>('no quests');
    final ValueNotifier<List<Widget>> widgetDescNtf = ValueNotifier([]);

    ValueNotifier<bool> removeQuestActive = ValueNotifier<bool>(false);

    widgetDescNtf.value = createQuests(
      widgetDescNtf,
      percentNtf,
      removeQuestActive,
      item['id'],
    );

    return ItemCard(
      key: ValueKey('${item['id']}_${item['title']}'),
      id: item['id'],
      type: item['type'],
      titleNtf: indNtf,
      subtitleNtf: subtitleNtf,
      descNtf: descNtf,
      widgetDesc: widgetDescNtf,
      doAnythingUp: ValueListenableBuilder<String>(
        valueListenable: percentNtf,
        builder: (context, value, _) {
          return Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color:
                  value == '100%'
                      ? Theme.of(context).extension<CustomColors>()!.concluido
                      : Colors.grey,
            ),
          );
        },
      ),
      onPressedCard: () {
        item['opened'] = !item['opened'];
      },
      ordemWidgets: (ids) async {
        log('reordenado');
        for (int i = 0; i < ids.length; i++) {
          final id = ids[i];
          log(id.toString());
        }
        await DatabaseHelper().setOrdemTaskQuest(ids);
      },
      isExpanded: item['opened'],
      doAnythingDown: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                showCustomPopup(
                  context,
                  'Adicionar Etapa',
                  [
                    {'value': 'Título', 'type': 'necessary'},
                    {'value': 'Descrição', 'type': 'text'},
                  ],
                  onConfirm: (valores) async {
                    int id = await DatabaseHelper().insertTaskQuest(
                      valores[0],
                      valores[1],
                      item['id'],
                      ultimaOrdem,
                    );

                    itens = [
                      ...itens,
                      {
                        'id': id,
                        'title': valores[0],
                        'desc': valores[1],
                        'idtask': item['id'],
                        'type': 'tasks_quests',
                        'ordem': ultimaOrdem,
                        'completed': false,
                      },
                    ];

                    widgetDescNtf.value = createQuests(
                      widgetDescNtf,
                      percentNtf,
                      removeQuestActive,
                      item['id'],
                    );

                    ultimaOrdem++;

                    await ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Etapa Adicionada')),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Icon(Icons.add),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: removeQuestActive,
              builder: (context, value, _) {
                return ElevatedButton(
                  onPressed: () {
                    removeQuestActive.value = !value;
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    backgroundColor:
                        value
                            ? Theme.of(
                              context,
                            ).extension<CustomColors>()!.concluido
                            : null,
                  ),
                  child: Icon(Icons.remove, color: value ? Colors.white : null),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> createQuests(
    ValueNotifier<List<Widget>> widgetDescNtf,
    ValueNotifier<String> percentNtf,
    ValueNotifier<bool> removeNtf,
    int id,
  ) {
    List<Map<String, dynamic>> filteredQuests =
        itens
            .where(
              (quest) =>
                  quest['type'] == 'tasks_quests' && quest['idtask'] == id,
            )
            .toList();

    Future<void> atualizarPorcentagem() async {
      final total = filteredQuests.length;
      final completos =
          filteredQuests.where((q) => q['completed'] == true).length;
      final porcentagem = total == 0 ? 0 : ((completos / total) * 100).round();

      percentNtf.value = '$porcentagem%';

      await DatabaseHelper().saveTask(
        id,
        porcentagem <= 0
            ? 0
            : porcentagem >= 100
            ? 2
            : 1,
      );
    }

    return filteredQuests.map((quest) {
      return itemDesc(quest, removeNtf, (toggle) async {
        if (!removeNtf.value) {
          quest['completed'] = toggle;
          await DatabaseHelper().saveTaskQuest(quest['id'], toggle);

          await atualizarPorcentagem();
        } else {
          itens.removeWhere((item) => item['id'] == quest['id']);
          filteredQuests.removeWhere((item) => item['id'] == quest['id']);

          await atualizarPorcentagem();

          widgetDescNtf.value.removeWhere(
            (widget) =>
                widget.key == ValueKey('${quest['id']}_${quest['title']}'),
          );
          widgetDescNtf.notifyListeners();

          await DatabaseHelper().removeTaskQuest(quest['id']);
        }
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quests'),
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
              Expanded(
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) async {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;

                      final item = itens.removeAt(oldIndex);
                      itens.insert(newIndex, item);
                    });
                  },
                  children: [
                    for (int index = 0; index < itens.length; index++)
                      if (itens[index]['type'] == 'task')
                        questCreate(itens[index], index),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
