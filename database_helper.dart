import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_web/sqflite_web.dart'; // para a web

Future<void> initDatabase() async {
  if (kIsWeb) {
    // Para Web
    databaseFactory = databaseFactoryWeb;
  } else {
    // Para Desktop e Mobile
    databaseFactory = databaseFactoryFfi;
  }
  var db = await openDatabase('comanda.db');
  // Aqui você pode continuar com as operações de banco
}




class DatabaseHelper {
  static const _databaseName = 'comandas.db';
  static const _databaseVersion = 2; // Atualize para versão 2
  static const table = 'comandas';

  // Colunas da tabela 'comandas'
  static const columnId = 'id';
  static const columnCliente = 'cliente';
  static const columnGarcom = 'garcom';
  static const columnTotal = 'total';
  static const columnDataHora = 'data_hora';

  // Colunas da tabela 'funcionarios'
  static const tableFuncionarios = 'funcionarios';
  static const columnIdFuncionario = 'id';
  static const columnNomeFuncionario = 'nome';

  // Colunas da tabela 'vendas'
  static const tableVendas = 'vendas';
  static const columnIdVenda = 'id';
  static const columnIdComanda = 'comanda_id';
  static const columnIdFuncio = 'funcionario_id';
  static const columnTotalVenda = 'total';
  static const columnDataHoraVenda = 'data_hora';

  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    Database db = await openDatabase(path, version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);

    // Ativar o suporte a chaves estrangeiras no SQLite
    await db.execute('PRAGMA foreign_keys = ON;');

    return db;
  }

  // Criar as tabelas
  Future _onCreate(Database db, int version) async {
    // Criar tabela de comandas
    await db.execute(''' 
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnCliente TEXT NOT NULL,
        $columnGarcom TEXT NOT NULL,
        $columnTotal REAL NOT NULL,
        $columnDataHora TEXT NOT NULL
      )
    ''');

    // Criar tabela de funcionários
    await db.execute(''' 
      CREATE TABLE $tableFuncionarios (
        $columnIdFuncionario INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNomeFuncionario TEXT NOT NULL
      )
    ''');

    // Criar tabela de vendas com exclusão em cascata
    await db.execute(''' 
      CREATE TABLE $tableVendas (
        $columnIdVenda INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnIdComanda INTEGER,
        $columnIdFuncio INTEGER,
        $columnTotalVenda REAL,
        $columnDataHoraVenda TEXT,
        FOREIGN KEY($columnIdComanda) REFERENCES $table($columnId) ON DELETE CASCADE,
        FOREIGN KEY($columnIdFuncionario) REFERENCES $tableFuncionarios($columnIdFuncionario) ON DELETE CASCADE
      )
    ''');
  }

  // Lidar com a atualização da versão do banco de dados
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Lógica de migração, se necessário
      await db.execute('PRAGMA foreign_keys = ON;');
    }
  }

  // Inserir uma nova comanda
  Future<int> insertComanda(Map<String, dynamic> row) async {
    try {
      Database db = await instance.database;
      int result = await db.insert(table, row);
      print('Comanda inserida com sucesso! ID: $result');
      return result;
    } catch (e) {
      print('Erro ao inserir comanda: $e');
      rethrow;
    }
  }

  // Recuperar todas as comandas
  Future<List<Map<String, dynamic>>> getComandas() async {
    Database db = await instance.database;
    return await db.query(table, orderBy: "$columnDataHora DESC");
  }

  // Atualizar uma comanda
  Future<int> updateComanda(int id, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletar uma comanda
  Future<int> deleteComanda(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  // Inserir um novo funcionário
  Future<int> insertFuncionario(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableFuncionarios, row);
  }

  // Recuperar todos os funcionários
  Future<List<Map<String, dynamic>>> getFuncionarios() async {
    Database db = await instance.database;
    return await db.query(tableFuncionarios);
  }

  // Inserir uma nova venda
  Future<int> insertVenda(Map<String, dynamic> row) async {
    Database db = await instance.database;

    // Verificar se os dados de comanda e funcionário existem antes de inserir a venda
    var comanda = await db.query(table, where: '$columnId = ?', whereArgs: [row[columnIdComanda]]);
    var funcionario = await db.query(tableFuncionarios, where: '$columnIdFuncionario = ?', whereArgs: [row[columnIdFuncio]]);

    if (comanda.isNotEmpty && funcionario.isNotEmpty) {
      return await db.insert(tableVendas, row);
    } else {
      throw Exception("Comanda ou Funcionário não encontrados");
    }
  }

  // Recuperar todas as vendas
  Future<List<Map<String, dynamic>>> getVendas() async {
    Database db = await instance.database;
    return await db.query(tableVendas, orderBy: "$columnDataHoraVenda DESC");
  }

  // Função de inserção de funcionário
  Future<void> _addFuncionario(String nome) async {
    final db = await DatabaseHelper.instance.database;

    // Cria o mapa para a inserção
    Map<String, dynamic> row = {
      DatabaseHelper.columnNomeFuncionario: nome,
    };

    // Insere o funcionário no banco
    await db.insert(
      DatabaseHelper.tableFuncionarios,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace, // No caso de conflito, substitui o registro
    );

  }

  }