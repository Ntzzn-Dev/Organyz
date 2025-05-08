import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

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
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE repository (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            subtitle TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE links (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            url TEXT,
            idrepository INTEGER,
            ordem INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE note (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            desc TEXT,
            idrepository INTEGER,
            ordem INTEGER
          )
        ''');
      },
    );
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'organyz.db');
    await deleteDatabase(path);
    print('Banco de dados deletado com sucesso.');
  }

  //ITEMS
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('repository');
    return result;
  }

  Future<void> insertItem(String title, String subtitle) async {
    final db = await database;
    await db.insert('repository', {'title': title, 'subtitle': subtitle});
  }

  Future<void> removeItem(int id) async {
    final db = await database;
    await db.delete('repository', where: 'id = ?', whereArgs: [id]);
  }

  //LINKS
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
    await db.insert('links', {
      'title': title,
      'url': url,
      'idrepository': idRepository,
      'ordem': ordem,
    });
  }

  Future<void> removeLink(int id) async {
    final db = await database;
    await db.delete('links', where: 'id = ?', whereArgs: [id]);
  }

  //TEXTAREA
  Future<List<Map<String, dynamic>>> getNote(int idRepository) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'note',
      where: 'idrepository = ?',
      whereArgs: [idRepository],
    );
    return result;
  }

  Future<void> insertNote(String title, int idRepository, int ordem) async {
    final db = await database;
    await db.insert('note', {
      'title': title,
      'idrepository': idRepository,
      'ordem': ordem,
    });
  }

  Future<void> removeNote(int id) async {
    final db = await database;
    await db.delete('note', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateNote(int id, String desc) async {
    final db = await database;

    await db.update('note', {'desc': desc}, where: 'id = ?', whereArgs: [id]);
  }

  //REPOSITORIO ITENS
  Future<List<Map<String, dynamic>>> getAllItemsOrdered(
    int idRepository,
  ) async {
    final db = await database;

    List<Map<String, dynamic>> links = await db.query(
      'links',
      where: 'idrepository = ?',
      whereArgs: [idRepository],
    );

    links =
        links.map((item) {
          return {...item, 'type': 'link'};
        }).toList();

    List<Map<String, dynamic>> notes = await db.query(
      'note',
      where: 'idrepository = ?',
      whereArgs: [idRepository],
    );

    notes =
        notes
            .map(
              (item) => {
                ...item,
                'type': 'text',
                'controller': TextEditingController(text: item['desc'] ?? ''),
              },
            )
            .toList();

    List<Map<String, dynamic>> all = [...links, ...notes];

    all.sort((a, b) => (a['ordem'] as int).compareTo(b['ordem'] as int));

    return all;
  }
}
