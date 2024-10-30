import 'dart:collection';

import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';

class Item {
  final String name;
  final double preco;

  Item(this.name, this.preco);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Comanda Digital',
      theme: ThemeData(),
      home: ComandaManager(),
    );
  }
}

class ComandaManager extends StatefulWidget {
  @override
  _ComandaManagerState createState() => _ComandaManagerState();
}

class _ComandaManagerState extends State<ComandaManager> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final List<Item> itens = [
    Item('Heineken', 12.0),
    Item('Budweiser', 10.0),
    Item('Stella Artois', 10.0),
    Item('Skol', 5.5),
    Item('Gado', 5.0),
    Item('Porco', 4.0),
    Item('Água', 3.0),
  ];

  final List<List<Item>> comandas = [[]];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void loadItems() async {
    setState(() {});
  }

  void salvarComanda(List<Item> comanda) async {
    await _databaseHelper.insertComanda(comanda);
  }

  void adicionarComanda() {
    setState(() {
      comandas.add([]);
    });
  }

  void adicionarItem(Item item, int index) {
    setState(() {
      comandas[index].add(item);
    });
  }

  void removerItem(Item item, int comandaIndex) {
    setState(() {
      comandas[comandaIndex].remove(item);
    });
  }

  double calcularTotal(int index) {
    return comandas[index].fold(0.0, (total, item) => total + item.preco);
  }

  void zerarComanda(int index) async {
    return comandas[index].clear();
  }

  void navegarParaComanda(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComandaScreen(
          itens: itens,
          comanda: comandas[index],
          onAdicionarItem: (item) => adicionarItem(item, index),
          onRemoverItem: (item) => removerItem(item, index),
          calcularTotal: () => calcularTotal(index),
          onSalvarComanda: salvarComanda,
          onZerarComanda: zerarComanda,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 224, 110, 4),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 184, 90, 3),
        title: Text(
          'Comanda Digital',
          style: TextStyle(color: Colors.white, fontSize: 35.0),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: adicionarComanda,
            color: Colors.white, // Adiciona uma nova comanda
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: comandas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Comanda ${index + 1}'),
            subtitle: Text(
              'Total: R\$ ${calcularTotal(index).toStringAsFixed(2)}',
            ),
            trailing: IconButton(
              icon: Icon(Icons.navigate_next),
              onPressed: () =>
                  navegarParaComanda(index), // Navega para a tela da comanda
            ),
          );
        },
      ),
    );
  }
}

class ComandaScreen extends StatelessWidget {
  final List<Item> itens;
  final List<Item> comanda;
  final Function(Item) onAdicionarItem;
  final Function(Item) onRemoverItem;
  final double Function() calcularTotal;

  var onSalvarComanda;

  var onZerarComanda;

  ComandaScreen({
    required this.itens,
    required this.comanda,
    required this.onAdicionarItem,
    required this.onRemoverItem,
    required this.calcularTotal,
    required this.onSalvarComanda,
    required this.onZerarComanda,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 224, 110, 4),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 184, 90, 3),
        title: Text(
          'Comanda',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: itens.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(itens[index].name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('R\$ ${itens[index].preco.toStringAsFixed(2)}'),
                      IconButton(
                        icon: Icon(Icons.add_circle),
                        onPressed: () {
                          onAdicionarItem(itens[index]);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${itens[index].name} adicionado!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: comanda.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(comanda[index].name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('R\$ ${comanda[index].preco.toStringAsFixed(2)}'),
                      IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () {
                          onRemoverItem(itens[index]);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${comanda[index].name} removido!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total: R\$ ${calcularTotal().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onSalvarComanda(comanda);
              onZerarComanda;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Comanda salva com sucesso!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Text('Fechar conta',
                style: TextStyle(
                  fontSize: 20.0,
                )),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color.fromARGB(255, 27, 246, 38),
              padding: EdgeInsets.symmetric(
                  vertical: 16.0, horizontal: 32.0), // Padding
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20.0), // Bordas arredondadas
              ),
              elevation: 5, // Sombra
            ),
          )
        ],
      ),
    );
  }
}
