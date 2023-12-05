import 'dart:async';

import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

import 'DatabaseClientModel.dart';

class DatabaseHandler{

  initDB() async {
    String path = join(await getDatabasesPath(), "text.db");

    return await openDatabase(path, version: 1, onOpen: (db) {
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE texts (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, date TEXT, text TEXT)');
      };
    });
  }

  Future<int> insertText(List<TextDB> texts) async {
    int result = 0;
    final db = await initDB();
    for (var text in texts)
    {
      result = await db.insert('texts', text.toMap());
    }
    return result;
  }

  Future<List<TextDB>> selectText() async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query('texts');

    return List.generate(maps.length, (i) {
      return TextDB(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        date: maps[i]['date'] as String,
        text: maps[i]['text'] as String
      );
    });
  }

  Future<void> updateText(TextDB text) async {
    final db = await initDB();

    await db.update(
      'texts',
      text.toMap(),
      where: 'id = ?',
      whereArgs: [text.id],
    );
  }

  Future<void> deleteText(int id) async {
    final db = await initDB();

    await db.delete(
      'texts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}