import 'package:flutter/material.dart';
import 'database_helper.dart'; // Importando o helper para acessar o banco

class AdminProvider with ChangeNotifier {
  // Função para adicionar um funcionário
  Future<void> addFuncionario(String nome) async {
    // Chamar a função para inserir um novo funcionário no banco
    var db = await DatabaseHelper.instance.database;
    await db.insert('funcionarios', {'nome': nome});
    notifyListeners();
  }

  // Função para remover um funcionário
  Future<void> removeFuncionario(int id) async {
    var db = await DatabaseHelper.instance.database;
    await db.delete('funcionarios', where: 'id = ?', whereArgs: [id]);
    notifyListeners();
  }

  // Função para pegar as vendas de um período específico
  Future<List<Map<String, dynamic>>> getVendas(String dataInicio, String dataFim) async {
    var db = await DatabaseHelper.instance.database;
    return await db.query('vendas', where: 'data_hora BETWEEN ? AND ?', whereArgs: [dataInicio, dataFim]);
  }

  // Função para pegar o quantitativo de vendas por garçom
  Future<Map<String, double>> getQuantVendasPorGarcom() async {
    var db = await DatabaseHelper.instance.database;
    var result = await db.query('vendas_por_garcom');

    Map<String, double> vendasPorGarcom = {};
    result.forEach((row) {
      // Certifique-se de que 'valor' é tratado como double
      vendasPorGarcom[row['garcom'] as String] =
      (row['valor'] != null ? (row['valor'] as num).toDouble() : 0.0);
    });
    return vendasPorGarcom;
  }
}

  // Função para pegar o número de comandas atendidas por garçom
// Função para pegar o número de comandas atendidas por garçom
Future<Map<String, int>> getMesasAtendidas() async {
  var db = await DatabaseHelper.instance.database;
  var result = await db.rawQuery('''
    SELECT funcionarios.nome, COUNT(DISTINCT vendas.comanda_id) as mesas_atendidas
    FROM vendas
    JOIN funcionarios ON vendas.funcionario_id = funcionarios.id
    GROUP BY funcionarios.id
  ''');

  Map<String, int> mesasAtendidas = {};
  for (var row in result) {
    // Certifique-se de que o nome é tratado como String e mesas_atendidas como int
    mesasAtendidas[row['nome'] as String] = (row['mesas_atendidas'] as int);
  }
  return mesasAtendidas;
}

