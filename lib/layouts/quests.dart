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

  Widget itemDesc(Map<String, dynamic> quest, void Function(bool) onComplete) {
    final ValueNotifier<String> titlesNtf = ValueNotifier<String>(
      quest['title'],
    );
    final ValueNotifier<String> subtitleNtf = ValueNotifier<String>(
      quest['desc'],
    );
    final ValueNotifier<Color> colorNtf = ValueNotifier<Color>(
      Color.fromARGB(quest['completed'] ? 30 : 15, 0, 0, 0),
    );

    if (quest['completed']) {
      onComplete(true);
    }

    return ItemList(
      key: ValueKey([1, quest['title']]),
      id: 1,
      type: 'quest',
      titleNtf: titlesNtf,
      subtitleNtf: subtitleNtf,
      paddingN: {'width': 0, 'height': 3},
      doAnythingUp: Row(
        children: [
          ElevatedButton(
            onPressed: () async {
              quest['completed'] = !quest['completed'];
              onComplete(quest['completed']);
              colorNtf.value = Color.fromARGB(
                quest['completed'] ? 30 : 15,
                0,
                0,
                0,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(4),
              backgroundColor:
                  Theme.of(context).extension<CustomColors>()!.concluido,
            ),
            child: Icon(Icons.check, color: Colors.white),
          ),
        ],
      ),
      colorNtf: colorNtf,
    );
  }

  Widget questCreate(Map<String, dynamic> item, int index) {
    int porcent = 0;
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
    final ValueNotifier<String> percentNtf = ValueNotifier<String>('$porcent%');
    final ValueNotifier<List<Widget>> widgetDescNtf = ValueNotifier([]);

    widgetDescNtf.value = createQuests(percentNtf, item['id']);

    return ItemCard(
      key: ValueKey([item['id'], item['title']]),
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
      isExpanded: item['opened'],
      doAnythingDown: Row(
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

                  widgetDescNtf.value = createQuests(percentNtf, item['id']);

                  ultimaOrdem++;

                  await ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Etapa Adicionada')),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  List<Widget> createQuests(ValueNotifier<String> percentNtf, int id) {
    List<Map<String, dynamic>> filteredQuests =
        itens
            .where(
              (quest) =>
                  quest['type'] == 'tasks_quests' && quest['idtask'] == id,
            )
            .toList();

    return filteredQuests.map((quest) {
      return itemDesc(quest, (toggle) async {
        quest['completed'] = toggle;

        await DatabaseHelper().saveTaskQuest(quest['id'], toggle);

        int total = filteredQuests.length;
        int completos =
            filteredQuests.where((q) => q['completed'] == true).length;
        int porcentagem = ((completos / total) * 100).round();

        percentNtf.value = '$porcentagem%';

        await DatabaseHelper().saveTask(
          id,
          porcentagem <= 0
              ? 0
              : porcentagem >= 100
              ? 2
              : 1,
        );
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
                  onReorder: (oldIndex, newIndex) {
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
