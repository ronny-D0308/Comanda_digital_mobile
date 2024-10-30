import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'teste2.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'my_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        preco REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE comandas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL
      )
    ''');
  }

  Future<void> insertComanda(List<Item> comanda) async {
    final db = await database;
    double total = comanda.fold(0.0, (sum, item) => sum + item.preco);

    try {
      await db.insert('comandas', {'total': total});
      for (var item in comanda) {
        await db.insert('items', {'name': item.name, 'preco': item.preco});
      }
    } catch (e) {
      print("Error inserting comanda: $e");
    }

    await db.insert('comandas', {'total': total});

    for (var item in comanda) {
      await db.insert('items', {'nome': item.name, 'preco': item.preco});
    }
  }

  /*Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query('items');
  }*/

  Future<List<Item>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) {
      return Item(maps[i]['nome'], maps[i]['preco']);
    });
  }
}
