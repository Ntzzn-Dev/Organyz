import 'package:flutter/material.dart';
import 'itemlist.dart';
import 'database_helper.dart';
import 'popup.dart';
import 'repository.dart';
import 'themes.dart';
import 'calendario.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await DatabaseHelper().deleteDatabaseFile();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      theme: lighttheme,
      darkTheme: darktheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
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
    items = await DatabaseHelper().getItems();
    setState(() {});
  }

  void _openRepository(String titulo, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovaPagina(titulo: titulo, id: id),
      ),
    );
  }

  void _openCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CalendarPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organyz')),
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
                      ['Título', 'Subtitulo'],
                      onConfirm: (valores) async {
                        await DatabaseHelper().insertItem(
                          valores[0],
                          valores[1],
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
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ItemExpand(
                  title: items[index]['title'],
                  id: index,
                  subtitle: items[index]['subtitle'],
                  onPressedDel: () async {
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
                      DatabaseHelper().removeItem(items[index]['id']);
                      _loadItems();
                    });
                  },
                  onPressedCard: () {
                    _openRepository(items[index]['title'], items[index]['id']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
