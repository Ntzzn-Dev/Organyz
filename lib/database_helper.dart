import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:archive/archive.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'organyz.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE repository (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            subtitle TEXT,
            cor TEXT, 
            ordem INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE links (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            url TEXT,
            idrepository INTEGER,
            ordem INTEGER,
            FOREIGN KEY (idrepository) REFERENCES repository(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            desc TEXT,
            idrepository INTEGER,
            ordem INTEGER,
            FOREIGN KEY (idrepository) REFERENCES repository(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            desc TEXT,
            datafinal TEXT,
            estado INTEGER,
            idrepository INTEGER,
            ordem INTEGER,
            FOREIGN KEY (idrepository) REFERENCES repository(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE tasks_quests (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            desc TEXT,
            completed INTEGER,
            idtask INTEGER,
            ordem INTEGER,
            FOREIGN KEY (idtask) REFERENCES tasks(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE conts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            qntContMin INTEGER,
            qntContMax INTEGER,
            contIncrement INTEGER,
            contAtual INTEGER,
            idrepository INTEGER,
            ordem INTEGER,
            FOREIGN KEY (idrepository) REFERENCES repository(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE conts_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idconts INTEGER,
            contAtual INTEGER,
            direcao TEXT,
            datadacontagem TEXT,
            FOREIGN KEY (idconts) REFERENCES conts(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE map_points (
            idpoint INTEGER PRIMARY KEY AUTOINCREMENT,
            desc TEXT,
            endereco TEXT,
            lat REAL,
            long REAL,
            icon TEXT,
            colorIcon TEXT,
            idrepository INTEGER,
            ordem INTEGER,
            FOREIGN KEY (idrepository) REFERENCES repository(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<int> countItemsFromRepository(int idRep) async {
    final db = await database;

    final tables = ['links', 'notes', 'tasks', 'conts', 'map_points'];

    int total = 0;

    for (final table in tables) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $table WHERE idrepository = ?',
        [idRep],
      );

      total += result.first['count'] as int;
    }

    return total;
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'organyz.db');
    await deleteDatabase(path);
    log('Banco de dados deletado com sucesso.');
  }

  String compactData(List<Map<String, dynamic>> dataList) {
    final jsonStr = jsonEncode(dataList);
    final compressed = GZipEncoder().encode(utf8.encode(jsonStr));
    return base64Encode(compressed!);
  }

  List<Map<String, dynamic>> extractData(String compacted) {
    final compressed = base64Decode(compacted);
    final decompressed = GZipDecoder().decodeBytes(compressed);
    final decoded = jsonDecode(utf8.decode(decompressed));
    return List<Map<String, dynamic>>.from(decoded);
  }

  Future<String> verifyTitle(
    String baseTitle,
    String table, {
    int? currentId,
  }) async {
    final db = await database;
    String title = baseTitle.trim();
    int counter = 1;

    while (true) {
      final result = await db.query(
        table,
        where: 'title = ? AND id != ?',
        whereArgs: [title, currentId ?? -1],
      );

      if (result.isEmpty) {
        break;
      }

      title = '${baseTitle.trim()} ($counter)';
      counter++;
    }

    return title;
  }

  Future<int> verifyDuplicate(
    String baseTitle,
    String table, {
    int? currentId,
  }) async {
    final db = await database;
    String title = baseTitle.trim();

    final result = await db.query(
      table,
      where: 'TRIM(title) = ? AND id != ?',
      whereArgs: [title, currentId ?? -1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }

    return -1;
  }

  //REPOSITORYS ===============================================================
  Future<List<Map<String, dynamic>>> getRepo() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('repository');
    final mutableResult = List<Map<String, dynamic>>.from(result);
    mutableResult.sort(
      (a, b) => (a['ordem'] as int).compareTo(b['ordem'] as int),
    );
    return mutableResult;
  }

  Future<int> insertRepo(
    String title,
    String subtitle,
    String? cor,
    int ordem,
  ) async {
    final db = await database;

    final id = await db.insert('repository', {
      'title': title,
      'subtitle': subtitle,
      'cor': cor,
      'ordem': ordem,
    });
    return id;
  }

  Future<void> removeRepo(int id) async {
    final db = await database;
    await db.delete('repository', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateRepo(
    int id,
    String title,
    String subtitle,
    String? cor,
  ) async {
    final db = await database;

    await db.update(
      'repository',
      {'title': title, 'subtitle': subtitle, 'cor': cor},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> setOrdemRepo(List<int> ids) async {
    final db = await database;
    int count = 0;
    for (int id in ids) {
      await db.update(
        'repository',
        {'ordem': count},
        where: 'id = ?',
        whereArgs: [id],
      );
      count++;
    }
  }

  Future<void> setOrdemItemsRepo(List<Map<String, dynamic>> items) async {
    final db = await database;
    int count = 0;
    for (Map<String, dynamic> item in items) {
      await db.update(
        '${item['type']}s',
        {'ordem': count},
        where: 'id = ?',
        whereArgs: [item['id']],
      );
      count++;
    }
  }

  //LINKS =====================================================================
  Future<List<Map<String, dynamic>>> getLinks(int idRepository) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'links',
      where: 'idrepository = ?',
      whereArgs: [idRepository],
    );
    return result;
  }

  Future<void> insertLink(
    String title,
    String url,
    int idRepository, {
    int? ordemM,
  }) async {
    final db = await database;
    final finalTitle = await verifyTitle(title, 'links');
    int ordem = ordemM ?? await countItemsFromRepository(idRepository);

    await db.insert('links', {
      'title': finalTitle,
      'url': url,
      'idrepository': idRepository,
      'ordem': ordem,
    });
  }

  Future<void> removeLink(int id) async {
    final db = await database;
    await db.delete('links', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateLink(int id, String title, String url, int ordem) async {
    final db = await database;
    final finalTitle = await verifyTitle(title, 'links', currentId: id);

    await db.update(
      'links',
      {'title': finalTitle, 'url': url, 'ordem': ordem},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //NOTES =====================================================================
  Future<List<Map<String, dynamic>>> getNote(int idRepository) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'notes',
      where: 'idrepository = ?',
      whereArgs: [idRepository],
    );
    return result;
  }

  Future<void> insertNote(
    String title,
    int idRepository, {
    String desc = '',
    int? ordemM,
  }) async {
    final db = await database;
    int ordem = ordemM ?? await countItemsFromRepository(idRepository);

    await db.insert('notes', {
      'title': title,
      'desc': desc,
      'idrepository': idRepository,
      'ordem': ordem,
    });
  }

  Future<void> removeNote(int id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveNote(int id, String desc) async {
    final db = await database;

    await db.update('notes', {'desc': desc}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateNote(int id, String title, int ordem) async {
    final db = await database;

    await db.update(
      'notes',
      {'title': title, 'ordem': ordem},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //TASKS =====================================================================
  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('tasks');

    result =
        result.map((item) {
          return {...item, 'type': 'task', 'opened': false};
        }).toList();

    for (Map<String, dynamic> task in result) {
      String datafinalStr = task['datafinal'];
      DateTime datafinal = DateFormat('dd/MM/yyyy').parse(datafinalStr);
      String formattedDate = DateFormat('dd/MM/yyyy').format(datafinal);
      task['datafinal'] = formattedDate;
    }

    criarIndice(result);

    criarPercent(result);

    return result;
  }

  Future<String> ordTasks(String title, DateTime data, int id) async {
    List<Map<String, dynamic>> result = await DatabaseHelper().getTasks();

    List<Map<String, dynamic>> newOrd = [];

    for (var item in result) {
      newOrd.add({
        'title': item['title'],
        'data': DateFormat('dd/MM/yyyy').parse(item['datafinal']),
        'id': item['id'],
      });
    }

    newOrd.add({'title': title, 'data': data, 'id': -1});

    newOrd.sort(
      (a, b) => (a['data'] as DateTime).compareTo(b['data'] as DateTime),
    );

    return newOrd.length == 1
        ? ''
        : '${(newOrd.indexWhere((item) => item['id'] == -1) + 1).toString()} |';
  }

  Future<int> insertTask(
    String title,
    String desc,
    DateTime date,
    int idRepository, {
    int estado = 0,
    int? ordemM,
  }) async {
    final db = await database;

    int ordem = ordemM ?? await countItemsFromRepository(idRepository);

    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    int idTask = await db.insert('tasks', {
      'title': title,
      'desc': desc,
      'datafinal': formattedDate,
      'estado': estado,
      'idrepository': idRepository,
      'ordem': ordem,
    });

    return idTask;
  }

  Future<void> removeTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveTask(int id, int state) async {
    final db = await database;

    await db.update(
      'tasks',
      {'estado': state},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTask(
    int id,
    String title,
    String desc,
    DateTime date,
    int ordem,
  ) async {
    final db = await database;

    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    await db.update(
      'tasks',
      {
        'title': title,
        'desc': desc,
        'datafinal': formattedDate,
        'ordem': ordem,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getTaskQuest(int idtask) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'tasks_quests',
      where: 'idtask = ?',
      whereArgs: [idtask],
    );
    return result;
  }

  Future<int> insertTaskQuest(
    String title,
    String desc,
    int idTask,
    int ordem, {
    int? completed,
  }) async {
    final db = await database;

    return await db.insert('tasks_quests', {
      'title': title,
      'desc': desc,
      'completed': false,
      'idtask': idTask,
      'ordem': ordem,
      'completed': completed,
    });
  }

  Future<void> removeTaskQuest(int id) async {
    final db = await database;
    await db.delete('tasks_quests', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTaskQuest(
    String title,
    String desc,
    bool completed,
    int idTask,
    int ordem,
    int id,
  ) async {
    final db = await database;

    await db.update(
      'tasks_quests',
      {
        'title': title,
        'desc': desc,
        'completed': completed,
        'idtask': idTask,
        'ordem': ordem,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveTaskQuest(int id, bool state) async {
    final db = await database;

    await db.update(
      'tasks_quests',
      {'completed': state},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> setOrdemTaskQuest(List<int> ids) async {
    final db = await database;
    int count = 0;
    for (int id in ids) {
      await db.update(
        'tasks_quests',
        {'ordem': count},
        where: 'id = ?',
        whereArgs: [id],
      );
      count++;
    }
  }

  Future<void> removeOldTasks() async {
    final db = await database;
    await db.delete(
      'tasks',
      where: '''
      substr(datafinal, 7, 4) || '-' || substr(datafinal, 4, 2) || '-' || substr(datafinal, 1, 2) < ?
    ''',
      whereArgs: [DateFormat('yyyy-MM-dd').format(DateTime.now())],
    );
  }

  Future<void> removeCompleteTasks() async {
    final db = await database;
    await db.delete('tasks', where: 'estado = ?', whereArgs: [2]);
  }

  //CONTS =====================================================================
  Future<List<Map<String, dynamic>>> getCont(int idRepository) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'conts',
      where: 'idrepository = ?',
      whereArgs: [idRepository],
    );
    return result;
  }

  Future<int> insertCont(
    String title,
    int qntContMin,
    int qntContMax,
    int contIncrement,
    int idRepository, {
    int? ordemM,
  }) async {
    final db = await database;
    final finalTitle = await verifyTitle(title, 'conts');

    int ordem = ordemM ?? await countItemsFromRepository(idRepository);

    final id = await db.insert('conts', {
      'title': finalTitle,
      'qntContMin': qntContMin,
      'qntContMax': qntContMax,
      'contIncrement': contIncrement,
      'contAtual': qntContMin,
      'idrepository': idRepository,
      'ordem': ordem,
    });

    return id;
  }

  Future<void> removeCont(int id) async {
    final db = await database;
    await db.delete('conts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateCont(
    int id,
    String title,
    int qntContMin,
    int qntContMax,
    int contIncrement,
    int contAtual,
    int ordem,
  ) async {
    final db = await database;
    final finalTitle = await verifyTitle(title, 'conts', currentId: id);

    await db.update(
      'conts',
      {
        'title': finalTitle,
        'qntContMin': qntContMin,
        'qntContMax': qntContMax,
        'contIncrement': contIncrement,
        'contAtual': contAtual,
        'ordem': ordem,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveCont(int id, String direcao, int contAtual) async {
    final db = await database;

    await db.update(
      'conts',
      {'contAtual': contAtual},
      where: 'id = ?',
      whereArgs: [id],
    );

    plusCont(id, direcao, contAtual);
  }

  Future<void> plusCont(int id, String direcao, int contAtual) async {
    final db = await database;

    await db.insert('conts_history', {
      'idconts': id,
      'direcao': direcao,
      'contAtual': contAtual,
      'datadacontagem': DateFormat(
        'dd/MM/yyyy HH:mm:ss',
      ).format(DateTime.now()),
    });
  }

  Future<void> insertContHistory(
    int id,
    String direcao,
    int contAtual,
    DateTime data,
  ) async {
    final db = await database;

    await db.insert('conts_history', {
      'idconts': id,
      'direcao': direcao,
      'contAtual': contAtual,
      'datadacontagem': data,
    });
  }

  Future<void> restartCont(int id, int minCont) async {
    final db = await database;
    await db.delete('conts_history', where: 'idconts = ?', whereArgs: [id]);
    await db.update(
      'conts',
      {'contAtual': minCont},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getHistoryCont(int idconts) async {
    final db = await database;

    List<Map<String, dynamic>> result = await db.query(
      'conts_history',
      where: 'idconts = ?',
      whereArgs: [idconts],
    );

    List<DateTime> datas =
        result.map((e) {
          return DateFormat('dd/MM/yyyy HH:mm:ss').parse(e['datadacontagem']);
        }).toList();

    List<String> diferencas = [];

    for (int i = 0; i < datas.length; i++) {
      if (i == 0) {
        diferencas.add('Início');
      } else {
        final diff = datas[i].difference(datas[i - 1]);
        String formatada = [
          diff.inHours.toString().padLeft(2, '0'),
          (diff.inMinutes % 60).toString().padLeft(2, '0'),
          (diff.inSeconds % 60).toString().padLeft(2, '0'),
        ].join(':');
        diferencas.add(formatada);
      }
    }

    List<Map<String, dynamic>> novaLista = [];

    for (int i = 0; i < result.length; i++) {
      novaLista.add({...result[i], 'datadacontagem': diferencas[i]});
    }

    return novaLista;
  }

  //MAPS =====================================================================
  Future<List<Map<String, dynamic>>> getMaps() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('map_points');
    return result;
  }

  Future<int> insertMaps(
    String desc,
    String end,
    double lat,
    double long,
    String icon,
    String colorIcon,
    int idRepository, {
    int? ordemM,
  }) async {
    final db = await database;
    int ordem = ordemM ?? await countItemsFromRepository(idRepository);

    final id = await db.insert('map_points', {
      'desc': desc,
      'endereco': end,
      'lat': lat,
      'long': long,
      'icon': icon,
      'colorIcon': colorIcon,
      'idrepository': idRepository,
      'ordem': ordem,
    });

    return id;
  }

  Future<void> removeMaps(int id) async {
    final db = await database;
    await db.delete('map_points', where: 'idpoint = ?', whereArgs: [id]);
  }

  Future<void> updateMaps(
    int id,
    String desc,
    String end,
    double lat,
    double long,
    String icon,
    String colorIcon,
    int ordem,
  ) async {
    final db = await database;

    await db.update(
      'map_points',
      {
        'desc': desc,
        'endereco': end,
        'lat': lat,
        'long': long,
        'icon': icon,
        'colorIcon': colorIcon,
        'ordem': ordem,
      },
      where: 'idpoint = ?',
      whereArgs: [id],
    );
  }

  //REPOSITORIO ITENS =========================================================
  Future<List<Map<String, dynamic>>> getAllItemsOrdered(
    int idRepository,
  ) async {
    final db = await database;

    List<Map<String, dynamic>> links = await db.query(
      'links',
      where: 'idrepository = ?',
      whereArgs: [idRepository],
    );

    List<Map<String, dynamic>> notes = await db.query(
      'notes',
      where: 'idrepository = ?',
      whereArgs: [idRepository],
    );

    List<Map<String, dynamic>> tasks = await db.query(
      'tasks',
      where: 'idrepository = ?',
      whereArgs: [idRepository],
    );

    List<Map<String, dynamic>> conts = await db.query(
      'conts',
      where: 'idrepository = ?',
      whereArgs: [idRepository],
    );

    List<Map<String, dynamic>> maps = await db.query(
      'map_points',
      where: 'idrepository = ?',
      whereArgs: [idRepository],
    );

    links =
        links.map((item) {
          return {...item, 'type': 'link', 'opened': false};
        }).toList();

    notes =
        notes.map((item) {
          return {...item, 'type': 'note', 'opened': false};
        }).toList();

    tasks =
        tasks.map((item) {
          return {...item, 'type': 'task', 'opened': false};
        }).toList();

    conts =
        conts.map((item) {
          return {...item, 'type': 'cont', 'opened': false};
        }).toList();

    maps =
        maps.map((item) {
          return {...item, 'type': 'maps', 'opened': false};
        }).toList();

    criarIndice(tasks);

    criarPercent(tasks);

    List<Map<String, dynamic>> all = [
      ...links,
      ...notes,
      ...tasks,
      ...conts,
      ...maps,
    ];

    all.sort((a, b) => (a['ordem'] as int).compareTo(b['ordem'] as int));

    return all;
  }

  void criarPercent(List<Map<String, dynamic>> tasks) async {
    final db = await database;
    List<Map<String, dynamic>> quests = await db.query('tasks_quests');

    quests =
        quests.map((item) {
          return {
            ...item,
            'type': 'tasks_quests',
            'completed': item['completed'] == 1,
          };
        }).toList();

    for (var task in tasks) {
      final idTask = task['id'];
      final questsDaTask = quests.where((q) => q['idtask'] == idTask).toList();

      if (questsDaTask.isNotEmpty) {
        final total = questsDaTask.length;
        final completos =
            questsDaTask.where((q) => q['completed'] == true).length;
        final porcentagem = ((completos / total) * 100).round();

        task['porcent'] = porcentagem;
      }
    }
  }

  void criarIndice(List<Map<String, dynamic>> tasks) {
    Map<String, List<Map<String, dynamic>>> agrupadasPorTitulo = {};

    for (final task in tasks) {
      final title = task['title'];
      if (!agrupadasPorTitulo.containsKey(title)) {
        agrupadasPorTitulo[title] = [];
      }
      agrupadasPorTitulo[title]!.add(task);
    }

    agrupadasPorTitulo.forEach((title, lista) {
      lista.sort((a, b) {
        final dateA = DateFormat('dd/MM/yyyy').parse(a['datafinal']);
        final dateB = DateFormat('dd/MM/yyyy').parse(b['datafinal']);
        return dateA.compareTo(dateB);
      });

      int cont = 1;
      for (final task in lista) {
        if (lista.length > 1) {
          task['ind'] = '$cont | ';
          cont++;
        } else {
          task['ind'] = '';
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> getAllQuestsOrdered() async {
    final db = await database;

    List<Map<String, dynamic>> tasks = await db.query('tasks');
    List<Map<String, dynamic>> quests = await db.query('tasks_quests');

    tasks =
        tasks.map((item) {
          return {...item, 'type': 'task', 'opened': false};
        }).toList();

    quests =
        quests.map((item) {
          return {
            ...item,
            'type': 'tasks_quests',
            'completed': item['completed'] == 1,
          };
        }).toList();

    criarIndice(tasks);

    tasks.sort((a, b) => (a['ordem'] as int).compareTo(b['ordem'] as int));
    quests.sort((a, b) => (a['ordem'] as int).compareTo(b['ordem'] as int));

    List<Map<String, dynamic>> all = [...tasks, ...quests];

    return all;
  }

  Future<List<Map<String, dynamic>>> getRepoFull(int idRepository) async {
    final db = await database;

    List<Map<String, dynamic>> repo = await db.query(
      'repository',
      where: 'id = ?',
      whereArgs: [idRepository],
    );

    List<Map<String, dynamic>> links = await db.query(
      'links',
      where: 'idrepository = ?',
      whereArgs: [idRepository],
    );

    List<Map<String, dynamic>> notes = await db.query(
      'notes',
      where: 'idrepository = ?',
      whereArgs: [idRepository],
    );

    List<Map<String, dynamic>> tasks = List<Map<String, dynamic>>.from(
      await db.query(
        'tasks',
        where: 'idrepository = ?',
        whereArgs: [idRepository],
      ),
    );

    for (int i = 0; i < tasks.length; i++) {
      final quests = await db.query(
        'tasks_quests',
        where: 'idtask = ?',
        whereArgs: [tasks[i]['id']],
      );

      tasks[i] = {...tasks[i], "quests": quests};
    }

    List<Map<String, dynamic>> conts = List<Map<String, dynamic>>.from(
      await db.query(
        'conts',
        where: 'idrepository = ?',
        whereArgs: [idRepository],
      ),
    );

    for (int i = 0; i < conts.length; i++) {
      final historys = await db.query(
        'conts_history',
        where: 'idconts = ?',
        whereArgs: [conts[i]['id']],
      );

      conts[i] = {...conts[i], "historys": historys};
    }
    log(conts.length.toString());

    List<Map<String, dynamic>> maps = List<Map<String, dynamic>>.from(
      await db.query(
        'map_points',
        where: 'idrepository = ?',
        whereArgs: [idRepository],
      ),
    );

    repo = repo.map((item) => {...item, 'type': 'repo'}).toList();

    links = links.map((item) => {...item, 'type': 'link'}).toList();

    notes = notes.map((item) => {...item, 'type': 'note'}).toList();

    tasks = tasks.map((item) => {...item, 'type': 'task'}).toList();

    conts = conts.map((item) => {...item, 'type': 'cont'}).toList();

    maps = maps.map((item) => {...item, 'type': 'maps'}).toList();

    List<Map<String, dynamic>> all = [
      ...links,
      ...notes,
      ...tasks,
      ...conts,
      ...maps,
    ];

    all.sort((a, b) => (a['ordem'] as int).compareTo(b['ordem'] as int));

    return [...repo, ...all];
  }

  Future<String> setRepoFull(List<Map<String, dynamic>> repoFull) async {
    int idRep = 0;
    bool mesclagem = false;
    String msg = '';

    for (int index = 0; index < repoFull.length; index++) {
      Map<String, dynamic> item = repoFull[index];
      try {
        if (item['type'] == 'repo') {
          idRep = await DatabaseHelper().verifyDuplicate(
            item['title'],
            'repository',
          );
          if (idRep == -1) {
            idRep = await insertRepo(
              item['title'],
              item['subtitle'],
              item['cor'],
              item['ordem'],
            );
          } else {
            mesclagem = true;
          }
        }
        if (item['type'] == 'link') {
          if (!mesclagem ||
              (await DatabaseHelper().verifyDuplicate(
                    item['title'],
                    'links',
                  )) ==
                  -1) {
            await insertLink(item['title'], item['url'], idRep, ordemM: index);
          }
        }
        if (item['type'] == 'note') {
          if (!mesclagem ||
              (await DatabaseHelper().verifyDuplicate(
                    item['title'],
                    'notes',
                  )) ==
                  -1) {
            await insertNote(
              item['title'],
              idRep,
              ordemM: index,
              desc: item['desc'],
            );
          }
        }
        if (item['type'] == 'task') {
          if (!mesclagem ||
              (await DatabaseHelper().verifyDuplicate(
                    item['title'],
                    'tasks',
                  )) ==
                  -1) {
            DateTime datafinal = DateFormat(
              'dd/MM/yyyy',
            ).parse(item['datafinal']);
            int idTask = await insertTask(
              item['title'],
              item['desc'],
              datafinal,
              idRep,
              ordemM: index,
              estado: item['estado'],
            );

            if (item['quests'] != null && item['quests'] is List) {
              for (int i = 0; i < item['quests'].length; i++) {
                await insertTaskQuest(
                  item['quests'][i]['title'],
                  item['quests'][i]['desc'],
                  idTask,
                  i,
                  completed: item['quests'][i]['completed'],
                );
              }
            }
          }
        }
        if (item['type'] == 'cont') {
          if (!mesclagem ||
              (await DatabaseHelper().verifyDuplicate(
                    item['title'],
                    'conts',
                  )) ==
                  -1) {
            int idCont = await insertCont(
              item['title'],
              item['qntContMin'],
              item['qntContMax'],
              item['contIncrement'],
              idRep,
              ordemM: index,
            );

            if (item['historys'] != null && item['historys'] is List) {
              for (int i = 0; i < item['historys'].length; i++) {
                await insertContHistory(
                  idCont,
                  item['historys'][i]['direcao'],
                  item['historys'][i]['contAtual'],
                  item['historys'][i]['data'],
                );
              }
            }
          }
        }
        if (item['type'] == 'maps') {
          if (!mesclagem) {
            await insertMaps(
              item['desc'],
              item['endereco'],
              item['lat'],
              item['long'],
              item['icon'],
              item['colorIcon'],
              idRep,
              ordemM: index,
            );
          }
        }
        msg = mesclagem ? 'Repositório mesclado' : 'Repositório importado';
      } catch (e) {
        msg = '$e';
        log('Error: $e');
      }
    }

    return msg;
  }
}
