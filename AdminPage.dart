import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Future<List<Map<String, dynamic>>> funcionariosFuture;
  late Future<List<Map<String, dynamic>>> vendasFuture;

  @override
  void initState() {
    super.initState();
    funcionariosFuture = _getFuncionarios();
    vendasFuture = _getVendas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Administração')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _showAddFuncionarioDialog(context),
              child: Text('Adicionar Funcionário'),
            ),
            SizedBox(height: 20),
            // Exibir gráficos de vendas
            Expanded(
              flex: 1,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: vendasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar vendas'));
                  }

                  var vendas = snapshot.data ?? [];
                  return BarChart(
                    BarChartData(
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      barGroups: _getBarChartData(vendas),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Exibir a lista de funcionários
            Expanded(
              flex: 2,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: funcionariosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar funcionários'));
                  }

                  var funcionarios = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: funcionarios.length,
                    itemBuilder: (context, index) {
                      var funcionario = funcionarios[index];
                      return ListTile(
                        title: Text(funcionario['nome']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await _removeFuncionario(funcionario['id']);
                            setState(() {
                              funcionariosFuture = _getFuncionarios(); // Atualiza a lista de funcionários
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Recuperar todos os funcionários
  Future<List<Map<String, dynamic>>> _getFuncionarios() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('funcionarios');
  }

  // Recuperar todos os dados de vendas
  Future<List<Map<String, dynamic>>> _getVendas() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('vendas');
  }

  // Função para preparar os dados para o gráfico de barras
  List<BarChartGroupData> _getBarChartData(List<Map<String, dynamic>> vendas) {
    Map<String, double> vendasPorFuncionario = {};

    for (var venda in vendas) {
      String funcionarioId = venda['funcionario_id'].toString();
      double totalVenda = venda['total'] ?? 0.0;

      // Agrupar vendas por funcionário
      if (vendasPorFuncionario.containsKey(funcionarioId)) {
        vendasPorFuncionario[funcionarioId] = vendasPorFuncionario[funcionarioId]! + totalVenda;
      } else {
        vendasPorFuncionario[funcionarioId] = totalVenda;
      }
    }

    List<BarChartGroupData> barGroups = [];
    int i = 0;
    vendasPorFuncionario.forEach((key, value) {
      barGroups.add(BarChartGroupData(
        x: i++,
        barRods: [
          BarChartRodData(y: value),
        ],
        showingTooltipIndicators: [0],
      ));
    });
    return barGroups;
  }

  // Remover um funcionário
  Future<void> _removeFuncionario(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'funcionarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Exibir o diálogo para adicionar funcionário
  void _showAddFuncionarioDialog(BuildContext context) {
    TextEditingController nomeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Funcionário'),
          content: TextField(
            controller: nomeController,
            decoration: InputDecoration(hintText: 'Nome do Funcionário'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String nomeFuncionario = nomeController.text;
                if (nomeFuncionario.isNotEmpty) {
                  await _addFuncionario(nomeFuncionario); // Adiciona o funcionário
                  Navigator.pop(context);
                  setState(() {
                    funcionariosFuture = _getFuncionarios(); // Atualiza a lista de funcionários
                  });
                }
              },
              child: Text('Adicionar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Adicionar um funcionário ao banco
  Future<void> _addFuncionario(String nome) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'funcionarios',
      {'nome': nome},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

}
