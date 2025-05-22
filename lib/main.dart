import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'itemlist.dart';
import 'database_helper.dart';
import 'popup.dart';
import 'repository.dart';
import 'themes.dart';
import 'calendario.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final ValueNotifier<Color> corPrimaria = ValueNotifier<Color>(
  Color.fromARGB(255, 243, 160, 34),
);

bool isDark = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await DatabaseHelper().deleteDatabaseFile();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: corPrimaria,
      builder: (context, primary, _) {
        return MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('pt', 'BR')],
          locale: const Locale('pt', 'BR'),
          debugShowCheckedModeBanner: false,
          title: 'Lista de Itens',
          theme: lighttheme(primary),
          darkTheme: darkTheme(primary),
          themeMode: ThemeMode.system,
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    items = await DatabaseHelper().getRepo();
    setState(() {});
  }

  void _openRepository(String titulo, String subtitulo, int id, String cor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Repo(
              titulo: titulo,
              subtitulo: subtitulo,
              id: id,
              cor: cor,
              onUpdateRepo: () => _loadItems(),
            ),
        settings: RouteSettings(name: 'repository'),
      ),
    ).then((_) {
      corPrimaria.value = Color.fromARGB(255, 243, 160, 34);
    });
  }

  void _openCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarPage(),
        settings: RouteSettings(name: 'calendar'),
      ),
    ).then((_) {
      corPrimaria.value = Color.fromARGB(255, 243, 160, 34);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organyz'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              List<Map<String, dynamic>> repoBases = [];
              for (Map<String, dynamic> repo
                  in await DatabaseHelper().getRepo()) {
                repoBases.add({
                  'base64': DatabaseHelper().compactData(
                    await DatabaseHelper().getRepoFull(repo['id']),
                  ),
                  'nome': repo['title'],
                });
              }

              String database = '';
              for (Map<String, dynamic> repo in repoBases) {
                database += '!<${repo['nome']}>!\n${repo['base64']}\n\n';
              }

              Clipboard.setData(ClipboardData(text: database));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Icon(Icons.upload),
          ),
          SizedBox(width: 5),
          ElevatedButton(
            onPressed: () async {
              showCustomPopup(
                context,
                'Importar repositório',
                [
                  {'value': 'Colar codigo', 'type': 'text'},
                ],
                onConfirm: (valores) async {
                  final RegExp regex = RegExp(
                    r'(?:!<.*?>!\s*)?(H4sIA[\s\S]*?)(?=!<|$)',
                    multiLine: true,
                  );
                  final List<String> base64List =
                      regex
                          .allMatches(valores[0])
                          .map((match) => match.group(1)!)
                          .toList();

                  String msg = '';
                  for (String base64 in base64List) {
                    msg = await DatabaseHelper().setRepoFull(
                      DatabaseHelper().extractData(base64.trim()),
                    );
                  }
                  msg = base64List.length > 1 ? 'Repositórios Importados' : msg;

                  await _loadItems();
                  await ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(msg)));
                },
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Icon(Icons.download),
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
                      'Adicionar Repositório',
                      [
                        {'value': 'Título', 'type': 'title'},
                        {'value': 'Subtitulo', 'type': 'text'},
                        {'value': 'Cor', 'type': 'hex'},
                      ],
                      onConfirm: (valores) async {
                        await DatabaseHelper().insertRepo(
                          valores[0],
                          valores[1],
                          valores[2],
                          items.length,
                        );
                        await _loadItems();
                        await ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Repositório criado')),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Text('Add Repositório'),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    _openCalendar();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Text('Pendências'),
                ),
                Spacer(),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) async {
                List<Map<String, dynamic>> modifiableItems =
                    items
                        .map((item) => Map<String, dynamic>.from(item))
                        .toList();

                if (newIndex > oldIndex) newIndex -= 1;

                final item = modifiableItems.removeAt(oldIndex);
                modifiableItems.insert(newIndex, item);

                setState(() {
                  items = modifiableItems;
                });

                List<int> orderedIds =
                    modifiableItems
                        .map<int>((item) => item['id'] as int)
                        .toList();

                await DatabaseHelper().setOrdemRepo(orderedIds);
              },
              children: [
                for (int index = 0; index < items.length; index++)
                  ItemExpand(
                    key: ValueKey(items[index]['id']),
                    title: items[index]['title'],
                    id: index,
                    subtitle: items[index]['subtitle'],
                    addItems: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            bool aceito = await showCustomPopup(
                              context,
                              'Deletar repositório?',
                              [],
                            );
                            if (!aceito) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Item deletado: ${items[index]['title']}',
                                ),
                              ),
                            );
                            setState(() {
                              DatabaseHelper().removeRepo(items[index]['id']);
                              _loadItems();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(4),
                          ),
                          child: Icon(Icons.delete),
                        ),
                      ],
                    ),
                    onPressedCard: () {
                      _openRepository(
                        items[index]['title'],
                        items[index]['subtitle'],
                        items[index]['id'],
                        items[index]['cor'] ?? '',
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
