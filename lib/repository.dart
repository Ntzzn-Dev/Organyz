import 'package:flutter/material.dart';
import 'itemlist.dart';
import 'database_helper.dart';
import 'popup.dart';
import 'textarealist.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      'Título',
                      'Link',
                      (title, subtitle) async {
                        await DatabaseHelper().insertLink(
                          title,
                          subtitle,
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
                  child: const Text('Adicionar Link'),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    showCustomPopup(context, 'Adicionar Nota', 'Título', '', (
                      title,
                      subtitle,
                    ) async {
                      await DatabaseHelper().insertNote(
                        title,
                        widget.id,
                        ultimaOrdem,
                      );
                      await _loadItems();
                      await ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nota Adicionada')),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Text('Adicionar Nota'),
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
