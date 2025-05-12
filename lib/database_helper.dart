import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
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
      },
    );
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
      where: 'title = ? AND id != ?',
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
    int? ordem,
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
    int idRepository,
    int ordem,
  ) async {
    final db = await database;
    final finalTitle = await verifyTitle(title, 'links');

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
    int idRepository,
    int ordem, {
    String desc = '',
  }) async {
    final db = await database;

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
          return {...item};
        }).toList();

    for (Map<String, dynamic> task in result) {
      String datafinalStr = task['datafinal'];
      DateTime datafinal = DateFormat('dd/MM/yyyy').parse(datafinalStr);
      String formattedDate = DateFormat('dd/MM/yyyy').format(datafinal);
      task['datafinal'] = formattedDate;
    }

    return result;
  }

  Future<void> insertTask(
    String title,
    String desc,
    DateTime date,
    int idRepository,
    int ordem, {
    int estado = 0,
  }) async {
    final db = await database;
    final finalTitle = await verifyTitle(title, 'tasks');

    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    await db.insert('tasks', {
      'title': finalTitle,
      'desc': desc,
      'datafinal': formattedDate,
      'estado': estado,
      'idrepository': idRepository,
      'ordem': ordem,
    });
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
    final finalTitle = await verifyTitle(title, 'tasks', currentId: id);

    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    await db.update(
      'tasks',
      {
        'title': finalTitle,
        'desc': desc,
        'datafinal': formattedDate,
        'ordem': ordem,
      },
      where: 'id = ?',
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

    links =
        links.map((item) {
          return {...item, 'type': 'link'};
        }).toList();

    notes =
        notes
            .map(
              (item) => {
                ...item,
                'type': 'note',
                'controller': TextEditingController(text: item['desc'] ?? ''),
              },
            )
            .toList();

    tasks =
        tasks.map((item) {
          return {...item, 'type': 'task'};
        }).toList();

    List<Map<String, dynamic>> all = [...links, ...notes, ...tasks];

    all.sort((a, b) => (a['ordem'] as int).compareTo(b['ordem'] as int));

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

    List<Map<String, dynamic>> tasks = await db.query(
      'tasks',
      where: 'idrepository = ?',
      whereArgs: [idRepository],
    );

    repo = repo.map((item) => {...item, 'type': 'repo'}).toList();

    links = links.map((item) => {...item, 'type': 'link'}).toList();

    notes = notes.map((item) => {...item, 'type': 'note'}).toList();

    tasks = tasks.map((item) => {...item, 'type': 'task'}).toList();

    List<Map<String, dynamic>> all = [...links, ...notes, ...tasks];

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
            await insertLink(item['title'], item['url'], idRep, index);
          }
        }
        if (item['type'] == 'note') {
          if (!mesclagem ||
              (await DatabaseHelper().verifyDuplicate(
                    item['title'],
                    'notes',
                  )) ==
                  -1) {
            await insertNote(item['title'], idRep, index, desc: item['desc']);
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
            await insertTask(
              item['title'],
              item['desc'],
              datafinal,
              idRep,
              index,
              estado: item['estado'],
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
