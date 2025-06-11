import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:organyz/main.dart';
import 'package:organyz/popuphistory.dart';
import 'package:organyz/themes.dart';
import 'itemlist.dart';
import 'database_helper.dart';
import 'popup.dart';
import 'textarealist.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class Repo extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final int id;
  final String? cor;
  final VoidCallback onUpdateRepo;

  Repo({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.id,
    this.cor,
    required this.onUpdateRepo,
  });

  @override
  _repositoryPageState createState() => _repositoryPageState();
}

class _repositoryPageState extends State<Repo> {
  List<Map<String, dynamic>> itens = [];
  int ultimaOrdem = 0;
  late String titulo;
  late String? cor;
  bool showButtons = false;
  int btnLigado = -1;
  final Map<int, ValueNotifier<String>> taskMap = {};

  @override
  void initState() {
    super.initState();
    titulo = widget.titulo;
    cor = widget.cor;
    _loadItems();
  }

  Future<void> _loadItems() async {
    itens = await DatabaseHelper().getAllItemsOrdered(widget.id);
    ultimaOrdem = itens.length;
    setState(() {});

    if (cor != '') {
      corPrimaria.value = hexToColor(cor!);
    }
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
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

  void indiceTaskUpdate(String title) {
    final tasksSemelhantes =
        itens
            .where((item) => item['type'] == 'task' && item['title'] == title)
            .toList();

    tasksSemelhantes.sort((a, b) {
      final dateA = DateFormat('dd/MM/yyyy').parse(a['datafinal']);
      final dateB = DateFormat('dd/MM/yyyy').parse(b['datafinal']);
      return dateA.compareTo(dateB);
    });

    for (int i = 0; i < tasksSemelhantes.length; i++) {
      log(tasksSemelhantes[i]['datafinal']);
    }
    for (int i = 0; i < tasksSemelhantes.length; i++) {
      final item = tasksSemelhantes[i];
      final novoIndice = '${i + 1} | $title';
      taskMap[item['ordem']]?.value = novoIndice;
    }
  }

  Widget linksCreate(Map<String, dynamic> item, int index) {
    final ValueNotifier<String> titleNtf = ValueNotifier<String>(item['title']);
    final ValueNotifier<String> subtitleNtf = ValueNotifier<String>(
      item['url'],
    );
    return ItemList(
      key: ValueKey([item['id'], item['title']]),
      titleNtf: titleNtf,
      id: index,
      type: item['type'],
      subtitleNtf: subtitleNtf,
      onPressedDel: () async {
        bool aceito = await showCustomPopup(context, 'Deletar link?', []);
        if (!aceito) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item deletado: ${titleNtf.value}')),
        );
        await DatabaseHelper().removeLink(item['id']);
        await _loadItems();
      },
      doAnythingUp: Row(
        children: [
          ElevatedButton(
            onPressed: () async {
              final url = Uri.parse(subtitleNtf.value);

              launchUrl(url, mode: LaunchMode.externalApplication);
            },
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(4)),
            child: Icon(Icons.link_rounded),
          ),
        ],
      ),
      onPressedEdit: () async {
        showCustomPopup(
          context,
          'Editar Link',
          [
            {'value': 'Título', 'type': 'necessary'},
            {'value': 'Link', 'type': 'text'},
          ],
          fieldValues: [titleNtf.value, subtitleNtf.value],
          onConfirm: (valores) async {
            String title = valores[0];
            String url = valores[1];

            await DatabaseHelper().updateLink(
              item['id'],
              title,
              url,
              item['ordem'],
            );

            titleNtf.value = title;
            subtitleNtf.value = url;

            await ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Link Atualizado')));
          },
        );
      },
      doAnythingDown: ElevatedButton(
        onPressed: () async {
          Clipboard.setData(ClipboardData(text: subtitleNtf.value));
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Icon(Icons.copy),
      ),
    );
  }

  Widget notesCreate(Map<String, dynamic> item, int index) {
    final ValueNotifier<String> titleNtf = ValueNotifier<String>(item['title']);
    return TextAreaList(
      key: ValueKey([item['id'], item['title']]),
      labelNtf: titleNtf,
      controller: TextEditingController(text: item['desc'] ?? ''),
      onPressedDel: () async {
        bool aceito = await showCustomPopup(context, 'Deletar nota?', []);
        if (!aceito) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item deletado: ${titleNtf.value}')),
        );
        setState(() {
          DatabaseHelper().removeNote(item['id']);
          _loadItems();
        });
      },
      onTextChanged: (text) {
        DatabaseHelper().saveNote(item['id'], text);
      },
      onPressedEdit: () async {
        showCustomPopup(
          context,
          'Editar Nota',
          [
            {'value': 'Título', 'type': 'necessary'},
          ],
          fieldValues: [titleNtf.value],
          onConfirm: (valores) async {
            String title = valores[0];

            await DatabaseHelper().updateNote(item['id'], title, item['ordem']);

            titleNtf.value = title;
            await ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Nota Atualizada')));
          },
        );
      },
    );
  }

  Widget tasksCreate(Map<String, dynamic> item, int index) {
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
    final ValueNotifier<int> stateNtf = ValueNotifier<int>(item['estado']);

    return ItemList(
      key: ValueKey([item['id'], indNtf.value]),
      id: index,
      titleNtf: indNtf,
      type: item['type'],
      subtitleNtf: subtitleNtf,
      descNtf: descNtf,
      onPressedDel: () async {
        bool aceito = await showCustomPopup(context, 'Deletar tarefa?', []);
        if (!aceito) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item deletado: ${indNtf.value}')),
        );
        setState(() {
          DatabaseHelper().removeTask(item['id']);
          _loadItems();
        });
      },
      doAnythingUp: ValueListenableBuilder(
        valueListenable: stateNtf,
        builder: (context, state, _) {
          return ElevatedButton(
            onPressed: () async {
              int newState = state + 1;

              if (newState >= 3) {
                newState = 0;

                bool aceito = await showCustomPopup(
                  context,
                  'Reiniciar estado?',
                  [],
                );
                if (!aceito) {
                  return;
                }
              }

              stateNtf.value = newState;

              await DatabaseHelper().saveTask(item['id'], newState);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(4),
              fixedSize: const Size(120, 48),
              backgroundColor: corState(state),
            ),
            child: Text(
              nomeState(state),
              style: TextStyle(color: Color.fromARGB(255, 242, 242, 242)),
            ),
          );
        },
      ),
      onPressedEdit: () async {
        showCustomPopup(
          context,
          'Editar Tarefa',
          [
            {'value': 'Título', 'type': 'necessary'},
            {'value': 'Descrição', 'type': 'text'},
            {'value': 'Data Final', 'type': 'data'},
          ],
          fieldValues: [
            indNtf.value.replaceFirst(RegExp(r'^\d+\s\|\s'), '').trim(),
            descNtf.value,
            DateFormat('dd/MM/yyyy').format(
              DateFormat(
                "d 'de' MMMM 'de' y",
                'pt_BR',
              ).parse(subtitleNtf.value),
            ),
          ],
          onConfirm: (valores) async {
            String title = valores[0];
            String desc = valores[1];
            DateTime date = DateFormat('dd/MM/yyyy').parse(valores[2]);

            await DatabaseHelper().updateTask(
              item['id'],
              title,
              desc,
              date,
              item['ordem'],
            );

            item['datafinal'] = valores[2];

            indiceTaskUpdate(title);
            descNtf.value = desc;
            subtitleNtf.value = DateFormat(
              "d 'de' MMMM 'de' y",
              'pt_BR',
            ).format(DateFormat('dd/MM/yyyy').parse(valores[2]));

            await ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Tarefa Atualizada')));
          },
        );
      },
    );
  }

  Widget contsCreate(Map<String, dynamic> item, int index) {
    final ValueNotifier<String> titleNtf = ValueNotifier<String>(item['title']);
    ValueNotifier<String> subtitleNtf = ValueNotifier<String>(
      item['contAtual'].toString(),
    );

    int cont = item['contAtual'];
    int contMin = item['qntContMin'];
    int contMax = item['qntContMax'];

    return ItemList(
      key: ValueKey([item['id'], item['title']]),
      id: index,
      titleNtf: titleNtf,
      type: item['type'],
      subtitleNtf: subtitleNtf,
      onPressedDel: () async {
        bool aceito = await showCustomPopup(context, 'Deletar contagem?', []);
        if (!aceito) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item deletado: ${titleNtf.value}')),
        );
        setState(() {
          DatabaseHelper().removeCont(item['id']);
          _loadItems();
        });
      },
      doAnythingUp: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              if (cont > contMin) {
                cont--;
              }

              await DatabaseHelper().saveCont(item['id'], 'Subtração', cont);

              subtitleNtf.value = cont.toString();
            },
            child: Icon(Icons.remove),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: () async {
              cont++;

              if (cont > contMax) {
                cont = contMin;

                bool aceito = await showCustomPopup(
                  context,
                  'Reiniciar contagem?',
                  [],
                );
                if (!aceito) {
                  return;
                } else {
                  await DatabaseHelper().restartCont(item['id'], contMin);
                }
              }
              await DatabaseHelper().saveCont(item['id'], 'Adição', cont);

              subtitleNtf.value = cont.toString();
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
      doAnythingDown: Row(
        children: [
          ElevatedButton(
            onPressed: () async {
              cont = contMin;

              await DatabaseHelper().restartCont(item['id'], contMin);

              await DatabaseHelper().saveCont(item['id'], 'Adição', cont);

              subtitleNtf.value = cont.toString();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: () async {
              List<Map<String, dynamic>> history = await DatabaseHelper()
                  .getHistoryCont(item['id']);

              showPopupHistory(context, 'Histórico', history);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Icon(Icons.history),
          ),
        ],
      ),
      onPressedEdit: () async {
        showCustomPopup(
          context,
          'Editar Contagem',
          [
            {'value': 'Título', 'type': 'necessary'},
            {'value': 'Quantidade Mínima', 'type': 'num'},
            {'value': 'Quantidade Máxima', 'type': 'num'},
          ],
          fieldValues: [titleNtf.value, contMin.toString(), contMax.toString()],
          onConfirm: (valores) async {
            String title = valores[0];
            contMin = int.parse(valores[1]);
            contMax = int.parse(valores[2]);

            cont =
                cont < contMin
                    ? contMin
                    : cont > contMax
                    ? contMax
                    : cont;

            await DatabaseHelper().updateCont(
              item['id'],
              title,
              contMin,
              contMax,
              cont,
              item['ordem'],
            );

            titleNtf.value = title;
            subtitleNtf.value = cont.toString();

            await ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contagem Atualizada')),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          titulo,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              showCustomPopup(
                context,
                'Editar Repositorio',
                [
                  {'value': 'Título', 'type': 'title', 'id': widget.id},
                  {'value': 'Subtitulo', 'type': 'text'},
                  {'value': 'Cor', 'type': 'hex'},
                ],
                fieldValues: [widget.titulo, widget.subtitulo, cor!],
                onConfirm: (valores) async {
                  await DatabaseHelper().updateRepo(
                    widget.id,
                    valores[0],
                    valores[1],
                    valores[2],
                  );
                  setState(() {
                    titulo = valores[0];
                    cor = valores[2];
                  });
                  widget.onUpdateRepo();
                  await _loadItems();
                  await ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Repositorio Atualizado')),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Icon(Icons.edit),
          ),
          SizedBox(width: 5),
          ElevatedButton(
            onPressed: () async {
              Clipboard.setData(
                ClipboardData(
                  text: DatabaseHelper().compactData(
                    await DatabaseHelper().getRepoFull(widget.id),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Icon(Icons.copy),
          ),
          SizedBox(width: 5),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildButtonState(
                  [
                    {'label': 'Link', 'icon': Icons.public},
                    {'label': 'Note', 'icon': Icons.sticky_note_2},
                    {'label': 'Task', 'icon': Icons.task_rounded},
                    {'label': 'Cont', 'icon': Icons.plus_one},
                  ],
                  [
                    () async {
                      await _loadItems();
                      itens =
                          itens
                              .where((item) => item['type'] == 'link')
                              .toList();
                      setState(() {});
                    },
                    () async {
                      await _loadItems();
                      itens =
                          itens
                              .where((item) => item['type'] == 'note')
                              .toList();
                      setState(() {});
                    },
                    () async {
                      await _loadItems();
                      itens =
                          itens
                              .where((item) => item['type'] == 'task')
                              .toList();
                      setState(() {});
                    },
                    () async {
                      await _loadItems();
                      itens =
                          itens
                              .where((item) => item['type'] == 'cont')
                              .toList();
                      setState(() {});
                    },
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) async {
                    List<Map<String, dynamic>> modifiableItems =
                        itens
                            .map((item) => Map<String, dynamic>.from(item))
                            .toList();

                    if (newIndex > oldIndex) newIndex -= 1;

                    final item = modifiableItems.removeAt(oldIndex);
                    modifiableItems.insert(newIndex, item);

                    setState(() {
                      itens = modifiableItems;
                    });

                    //Salva a ordem apenas se os filtros estiverem desativados
                    btnLigado == -1
                        ? await DatabaseHelper().setOrdemItemsRepo(
                          modifiableItems,
                        )
                        : null;
                  },
                  children: [
                    for (int index = 0; index < itens.length; index++) ...[
                      (() {
                        final item = itens[index];

                        switch (item['type']) {
                          case 'link':
                            return linksCreate(item, index);
                          case 'note':
                            return notesCreate(item, index);
                          case 'task':
                            return tasksCreate(item, index);
                          case 'cont':
                            return contsCreate(item, index);
                          default:
                            return const SizedBox.shrink();
                        }
                      })(),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Stack(
            children: [
              if (showButtons)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showButtons = false;
                      });
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),

              buildAnimatedButton(270, Icons.public, () async {
                showCustomPopup(
                  context,
                  'Adicionar Link',
                  [
                    {'value': 'Título', 'type': 'necessary'},
                    {'value': 'Link', 'type': 'text'},
                  ],
                  onConfirm: (valores) async {
                    await DatabaseHelper().insertLink(
                      valores[0],
                      valores[1],
                      widget.id,
                      ultimaOrdem,
                    );
                    await _loadItems();
                    await ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link Adicionado')),
                    );
                    setState(() {
                      showButtons = false;
                    });
                  },
                );
              }),
              buildAnimatedButton(210, Icons.sticky_note_2, () async {
                showCustomPopup(
                  context,
                  'Adicionar Nota',
                  [
                    {'value': 'Título', 'type': 'necessary'},
                  ],
                  onConfirm: (valores) async {
                    await DatabaseHelper().insertNote(
                      valores[0],
                      widget.id,
                      ultimaOrdem,
                    );
                    await _loadItems();
                    await ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nota Adicionada')),
                    );
                    setState(() {
                      showButtons = false;
                    });
                  },
                );
              }),
              buildAnimatedButton(150, Icons.task_rounded, () async {
                showCustomPopup(
                  context,
                  'Adicionar Tarefa',
                  [
                    {'value': 'Título', 'type': 'necessary'},
                    {'value': 'Descrição', 'type': 'text'},
                    {'value': 'Data Final', 'type': 'data'},
                  ],
                  onConfirm: (valores) async {
                    DateTime date = DateFormat('dd/MM/yyyy').parse(valores[2]);
                    await DatabaseHelper().insertTask(
                      valores[0],
                      valores[1],
                      date,
                      widget.id,
                      ultimaOrdem,
                    );
                    await _loadItems();
                    await ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tarefa Adicionada')),
                    );
                    setState(() {
                      showButtons = false;
                    });
                  },
                );
              }),
              buildAnimatedButton(90, Icons.plus_one_rounded, () async {
                showCustomPopup(
                  context,
                  'Adicionar Contagem',
                  [
                    {'value': 'Título', 'type': 'necessary'},
                    {'value': 'Quantidade Mínima', 'type': 'num'},
                    {'value': 'Quantidade Máxima', 'type': 'num'},
                  ],
                  fieldValues: ['', '0', '100'],
                  onConfirm: (valores) async {
                    await DatabaseHelper().saveCont(
                      await DatabaseHelper().insertCont(
                        valores[0],
                        int.parse(valores[1]),
                        int.parse(valores[2]),
                        widget.id,
                        ultimaOrdem,
                      ),
                      'Adição',
                      int.parse(valores[1]),
                    );
                    await _loadItems();
                    await ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contagem Adicionada')),
                    );
                    setState(() {
                      showButtons = false;
                    });
                  },
                );
              }),
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  width: 60,
                  height: 60,
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
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        showButtons = !showButtons;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildAnimatedButton(
    double bottomPosition,
    IconData icon,
    VoidCallback acao,
  ) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      bottom: showButtons ? bottomPosition : 20,
      right: 25,
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: showButtons ? 1.0 : 0.0,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).extension<CustomColors>()!.iniciado,
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
            icon: Icon(icon, color: Colors.white, size: 24),
            onPressed: acao,
          ),
        ),
      ),
    );
  }

  Widget buildButtonState(
    List<Map<String, dynamic>> identificacao,
    List<VoidCallback> acoes,
  ) {
    final segundacor = Theme.of(context).extension<CustomColors>()!.corBase;
    final primeiracor = Theme.of(context).extension<CustomColors>()!.concluido;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < identificacao.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: () async {
                  btnLigado = btnLigado == i ? -1 : i;

                  if (btnLigado == -1) {
                    await _loadItems();
                    return;
                  }

                  acoes[i]();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  backgroundColor: btnLigado == i ? primeiracor : segundacor,
                ),
                child: Row(
                  children: [
                    Icon(
                      identificacao[i]['icon'],
                      color: btnLigado == i ? segundacor : primeiracor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      identificacao[i]['label'],
                      style: TextStyle(
                        color: btnLigado == i ? segundacor : primeiracor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
