import 'package:flutter/material.dart';
import 'itemlist.dart';
import 'database_helper.dart';
import 'popup.dart';
import 'textarealist.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class NovaPagina extends StatefulWidget {
  final String titulo;
  final int id;

  const NovaPagina({super.key, required this.titulo, required this.id});

  @override
  _repositoryPageState createState() => _repositoryPageState();
}

class _repositoryPageState extends State<NovaPagina> {
  List<Map<String, dynamic>> links = [];
  int ultimaOrdem = 0;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    links = await DatabaseHelper().getAllItemsOrdered(widget.id);
    ultimaOrdem = links.length;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.titulo,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                      ['Título', 'Link'],
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
                  child: const Text('+ Link'),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    showCustomPopup(
                      context,
                      'Adicionar Nota',
                      ['Título'],
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
                  child: const Text('+ Nota'),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    showCustomPopup(
                      context,
                      'Adicionar Tarefa',
                      ['Título', 'Descrição', 'Data Final'],
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
                  child: const Text('+ Tarefa'),
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
                    onPressedX: () {
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
                  );
                } else if (item['type'] == 'text') {
                  return TextAreaList(
                    label: item['title'],
                    controller: item['controller'],
                    onPressedX: () {
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
                        DatabaseHelper().updateNote(item['id'], text);
                      });
                    },
                  );
                } else if (item['type'] == 'task') {
                  return ItemExpand(
                    title: item['title'],
                    id: index,
                    subtitle: item['datafinal'],
                    estadoAtual: item['estado'],
                    onPressedX: () {
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
                      await DatabaseHelper().updateTask(item['id'], state);
                      _loadItems();
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
