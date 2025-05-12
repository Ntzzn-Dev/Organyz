import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:organyz/main.dart';
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
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
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.public),
                      SizedBox(width: 8),
                      Text("Link"),
                    ],
                  ),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
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
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sticky_note_2),
                      SizedBox(width: 8),
                      Text("Note"),
                    ],
                  ),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    showCustomPopup(
                      context,
                      'Adicionar Tarefa',
                      [
                        {'value': 'Título', 'type': 'text'},
                        {'value': 'Descrição', 'type': 'text'},
                        {'value': 'Data Final', 'type': 'data'},
                      ],
                      onConfirm: (valores) async {
                        DateTime date = DateFormat(
                          'dd/MM/yyyy',
                        ).parse(valores[2]);
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
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.task_rounded),
                      SizedBox(width: 8),
                      Text("Task"),
                    ],
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: links.length,
              itemBuilder: (context, index) {
                final item = links[index];

                if (item['type'] == 'link') {
                  return ItemExpand(
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
                          content: Text('Item deletado: ${item['title']}'),
                        ),
                      );
                      setState(() {
                        DatabaseHelper().removeLink(item['id']);
                        _loadItems();
                      });
                    },
                    onPressedOpen: () async {
                      final url = Uri.parse(item['url']);

                      launchUrl(url, mode: LaunchMode.externalApplication);
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
                          await ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Link Atualizado')),
                          );
                        },
                      );
                    },
                    doAnything: ElevatedButton(
                      onPressed: () async {
                        Clipboard.setData(ClipboardData(text: item['url']));
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Icon(Icons.link_rounded),
                    ),
                  );
                } else if (item['type'] == 'note') {
                  return TextAreaList(
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
                          content: Text('Item deletado: ${item['title']}'),
                        ),
                      );
                      setState(() {
                        DatabaseHelper().removeNote(item['id']);
                        _loadItems();
                      });
                    },
                    onTextChanged: (text) {
                      setState(() {
                        DatabaseHelper().saveNote(item['id'], text);
                      });
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
                          await ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nota Atualizada')),
                          );
                        },
                      );
                    },
                  );
                } else if (item['type'] == 'task') {
                  return ItemExpand(
                    id: index,
                    title: item['title'],
                    subtitle: DateFormat(
                      "d 'de' MMMM 'de' y",
                      'pt_BR',
                    ).format(DateFormat('dd/MM/yyyy').parse(item['datafinal'])),
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
                          content: Text('Item deletado: ${item['title']}'),
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
                      await DatabaseHelper().saveTask(item['id'], state);
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
                          await ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tarefa Atualizada')),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
