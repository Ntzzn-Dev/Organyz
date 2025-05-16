import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:organyz/main.dart';
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
  List<Map<String, dynamic>> links = [];
  int ultimaOrdem = 0;
  late String titulo;
  late String? cor;
  bool showButtons = false;
  int btnLigado = -1;

  @override
  void initState() {
    super.initState();
    titulo = widget.titulo;
    cor = widget.cor;
    _loadItems();
  }

  Future<void> _loadItems() async {
    links = await DatabaseHelper().getAllItemsOrdered(widget.id);
    ultimaOrdem = links.length;
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
                  log(widget.id.toString());
                  log(valores[0].toString());
                  log(valores[1].toString());
                  log(valores[2].toString());
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
                  3,
                  [
                    {'label': 'Link', 'icon': Icons.public},
                    {'label': 'Note', 'icon': Icons.sticky_note_2},
                    {'label': 'Task', 'icon': Icons.task_rounded},
                  ],
                  [
                    () async {
                      await _loadItems();
                      links =
                          links
                              .where((item) => item['type'] == 'link')
                              .toList();
                      setState(() {});
                    },
                    () async {
                      await _loadItems();
                      links =
                          links
                              .where((item) => item['type'] == 'note')
                              .toList();
                      setState(() {});
                    },
                    () async {
                      await _loadItems();
                      links =
                          links
                              .where((item) => item['type'] == 'task')
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
                        links
                            .map((item) => Map<String, dynamic>.from(item))
                            .toList();

                    if (newIndex > oldIndex) newIndex -= 1;

                    final item = modifiableItems.removeAt(oldIndex);
                    modifiableItems.insert(newIndex, item);

                    setState(() {
                      links = modifiableItems;
                    });

                    //Salva a ordem apenas se os filtros estiverem desativados
                    btnLigado == -1
                        ? await DatabaseHelper().setOrdemItemsRepo(
                          modifiableItems,
                        )
                        : null;
                  },
                  children: [
                    for (int index = 0; index < links.length; index++) ...[
                      (() {
                        final item = links[index];

                        if (item['type'] == 'link') {
                          return ItemExpand(
                            key: ValueKey([item['id'], item['title']]),
                            title: item['title'],
                            id: index,
                            subtitle: item['url'],
                            expandItem: 1,
                            onPressedDel: () async {
                              bool aceito = await showCustomPopup(
                                context,
                                'Deletar link?',
                                [],
                              );
                              if (!aceito) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Item deletado: ${item['title']}',
                                  ),
                                ),
                              );
                              await DatabaseHelper().removeLink(item['id']);
                              await _loadItems();
                            },
                            onPressedOpen: () async {
                              final url = Uri.parse(item['url']);

                              launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            onPressedEdit: () async {
                              showCustomPopup(
                                context,
                                'Editar Link',
                                [
                                  {'value': 'Título', 'type': 'text'},
                                  {'value': 'Link', 'type': 'text'},
                                ],
                                fieldValues: [item['title'], item['url']],
                                onConfirm: (valores) async {
                                  await DatabaseHelper().updateLink(
                                    item['id'],
                                    valores[0],
                                    valores[1],
                                    item['ordem'],
                                  );
                                  await _loadItems();
                                  await ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text('Link Atualizado'),
                                    ),
                                  );
                                },
                              );
                            },
                            doAnything: ElevatedButton(
                              onPressed: () async {
                                Clipboard.setData(
                                  ClipboardData(text: item['url']),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: Icon(Icons.copy),
                            ),
                          );
                        } else if (item['type'] == 'note') {
                          return TextAreaList(
                            key: ValueKey([item['id'], item['title']]),
                            label: item['title'],
                            controller: item['controller'],
                            onPressedDel: () async {
                              bool aceito = await showCustomPopup(
                                context,
                                'Deletar nota?',
                                [],
                              );
                              if (!aceito) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Item deletado: ${item['title']}',
                                  ),
                                ),
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
                                  {'value': 'Título', 'type': 'text'},
                                ],
                                fieldValues: [item['title']],
                                onConfirm: (valores) async {
                                  await DatabaseHelper().updateNote(
                                    item['id'],
                                    valores[0],
                                    item['ordem'],
                                  );
                                  await _loadItems();
                                  await ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text('Nota Atualizada'),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        } else if (item['type'] == 'task') {
                          return ItemExpand(
                            key: ValueKey([item['id'], item['title']]),
                            id: index,
                            title: item['title'],
                            subtitle: DateFormat(
                              "d 'de' MMMM 'de' y",
                              'pt_BR',
                            ).format(
                              DateFormat('dd/MM/yyyy').parse(item['datafinal']),
                            ),
                            desc: item['desc'],
                            estadoAtual: item['estado'],
                            expandItem: 1,
                            onPressedDel: () async {
                              bool aceito = await showCustomPopup(
                                context,
                                'Deletar tarefa?',
                                [],
                              );
                              if (!aceito) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Item deletado: ${item['title']}',
                                  ),
                                ),
                              );
                              setState(() {
                                DatabaseHelper().removeTask(item['id']);
                                _loadItems();
                              });
                            },
                            onPressedOpen: () async {
                              int state = item['estado'];
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
                                item['id'],
                                state,
                              );
                              _loadItems();
                            },
                            onPressedEdit: () async {
                              showCustomPopup(
                                context,
                                'Editar Tarefa',
                                [
                                  {'value': 'Título', 'type': 'text'},
                                  {'value': 'Descrição', 'type': 'text'},
                                  {'value': 'Data Final', 'type': 'data'},
                                ],
                                fieldValues: [
                                  item['title'],
                                  item['desc'],
                                  item['datafinal'],
                                ],
                                onConfirm: (valores) async {
                                  DateTime date = DateFormat(
                                    'dd/MM/yyyy',
                                  ).parse(valores[2]);
                                  await DatabaseHelper().updateTask(
                                    item['id'],
                                    valores[0],
                                    valores[1],
                                    date,
                                    item['ordem'],
                                  );
                                  await _loadItems();
                                  await ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text('Tarefa Atualizada'),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      })(),
                    ],
                  ],
                ),
              ),
            ],
          ),
          buildAnimatedButton(210, Icons.public, () async {
            showCustomPopup(
              context,
              'Adicionar Link',
              [
                {'value': 'Título', 'type': 'text'},
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
              },
            );
          }),
          buildAnimatedButton(150, Icons.sticky_note_2, () async {
            showCustomPopup(
              context,
              'Adicionar Nota',
              [
                {'value': 'Título', 'type': 'text'},
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
              },
            );
          }),
          buildAnimatedButton(90, Icons.task_rounded, () async {
            showCustomPopup(
              context,
              'Adicionar Tarefa',
              [
                {'value': 'Título', 'type': 'text'},
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
                color: Theme.of(context).extension<CustomColors>()!.concluido,
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
    int qntd,
    List<Map<String, dynamic>> identificacao,
    List<VoidCallback> acoes,
  ) {
    final segundacor = Theme.of(context).extension<CustomColors>()!.corBase;
    final primeiracor = Theme.of(context).extension<CustomColors>()!.concluido;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(),

        for (int i = 0; i < qntd; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
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
                  SizedBox(width: 8),
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
          if (i < qntd - 1) Spacer(),
        ],

        Spacer(),
      ],
    );
  }
}
