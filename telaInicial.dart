import 'package:flutter/material.dart';

class Item {
  final String nome;
  final double preco;

  Item(this.nome, this.preco);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comanda Digital',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ComandaManager(),
    );
  }
}

class ComandaManager extends StatefulWidget {
  @override
  _ComandaManagerState createState() => _ComandaManagerState();
}

class _ComandaManagerState extends State<ComandaManager> {
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

  void adicionarComanda() {
    setState(() {
      comandas.add([]); // Adiciona uma nova comanda
    });
  }

  void adicionarItem(Item item, int index) {
    setState(() {
      comandas[index].add(item); // Adiciona item à comanda
    });
  }

  void removerItem(Item item, int comandaIndex) {
    setState(() {
      comandas[comandaIndex].remove(item); // Remove item da comanda
    });
  }

  double calcularTotal(int index) {
    return comandas[index].fold(0.0, (total, item) => total + item.preco);
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
        ),
      ),
    ).then((_) {
      setState(() {}); // Atualiza o estado após retornar da tela
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comanda Digital'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: adicionarComanda, // Adiciona uma nova comanda
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: comandas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Comanda ${index + 1}'),
            subtitle:
                Text('Total: R\$ ${calcularTotal(index).toStringAsFixed(2)}'),
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

  ComandaScreen({
    required this.itens,
    required this.comanda,
    required this.onAdicionarItem,
    required this.onRemoverItem,
    required this.calcularTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comanda'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: itens.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(itens[index].nome),
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
                                content:
                                    Text('${itens[index].nome} adicionado!')),
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
                  title: Text(comanda[index].nome),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('R\$ ${comanda[index].preco.toStringAsFixed(2)}'),
                      IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () {
                          onRemoverItem(comanda[index]);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('${comanda[index].nome} removido!')),
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
        ],
      ),
    );
  }
}
