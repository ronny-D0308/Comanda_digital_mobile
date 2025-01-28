import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'theme.dart';
import 'database_helper.dart';

// Armazena os dados das comandas na memória
final Map<int, Map<String, dynamic>> _comandas = {};

class ComandaDetailPage extends StatefulWidget {
  final int comandaId;

  const ComandaDetailPage({super.key, required this.comandaId});

  @override
  _ComandaDetailPageState createState() => _ComandaDetailPageState();
}

class _ComandaDetailPageState extends State<ComandaDetailPage> {
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _garcomController = TextEditingController();
  late Map<String, int> _itens;
  double _total = 0.0;
/*
  @override
  void initState() {
    super.initState();
    // Carrega os dados da comanda se já existirem
    if (_comandas.containsKey(widget.comandaId)) {
      _clienteController.text = _comandas[widget.comandaId]!['cliente'];
      _garcomController.text = _comandas[widget.comandaId]!['garcom'];
      _itens = Map<String, int>.from(_comandas[widget.comandaId]!['itens']);
      _total = _comandas[widget.comandaId]!['total'];
    } else {
      _itens = {};
    }
  }
 */
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _carregarDadosComanda();
    });
  }

  Future<void> _carregarDadosComanda() async {
    if (_comandas.containsKey(widget.comandaId)) {
      setState(() {
        _clienteController.text = _comandas[widget.comandaId]!['cliente'];
        _garcomController.text = _comandas[widget.comandaId]!['garcom'];
        _itens = Map<String, int>.from(_comandas[widget.comandaId]!['itens']);
        _total = _comandas[widget.comandaId]!['total'];
      });
    } else {
      _itens = {};
    }
  }

  // Produtos e preços definidos
  final espetos = {
    'Gado': 5.0,
    'Porco': 5.0,
    'Frango': 5.0,
    'Linguiça': 5.0,
    'Calabresa': 5.0,
    'Maminha': 8.0,
  };

  final bebidas = {
    'Coca lata': 5.0,
    'Coca 600': 7.0,
    'Coca 1L': 10.0,
    'Guaraná lata': 5.0,
    'Guaraná 1L': 7.0,
    'Fanta Uva': 5.0,
    'Fanta Laranja': 5.0,
    'Cajuina': 8.0,
  };

  final entradas = {
    'Batata frita': 15.0,
    'Lolita de queijo': 15.0,
    'Bolinha de carne do sol': 15.0,
  };

  final porcoes = {
    'Baião': 5.0,
    'Arroz agrega': 8.0,
  };

  void _salvarEstado() {
    _comandas[widget.comandaId] = {
      'cliente': _clienteController.text,
      'garcom': _garcomController.text,
      'itens': _itens,
      'total': _total,
    };
  }

  void _adicionarItem(String produto, double preco) {
    setState(() {
      _itens[produto] = (_itens[produto] ?? 0) + 1;
      _total += preco;
      _salvarEstado();
    });
  }

  void _removerItem(String produto, double preco) {
    if (_itens[produto] != null && _itens[produto]! > 0) {
      setState(() {
        _itens[produto] = _itens[produto]! - 1;
        _total -= preco;
        _salvarEstado();
      });
    }
  }

  Future<void> _fecharComanda() async {
    String cliente = _clienteController.text;
    String garcom = _garcomController.text;
    String dataHora = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Verifica se o nome do cliente e garçom foram preenchidos
    if (cliente.isEmpty || garcom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha o nome do cliente e do garçom')),
      );
      return;
    }

    // Prepara os dados da nova comanda
    Map<String, dynamic> novaComanda = {
      'cliente': cliente,
      'garcom': garcom,
      'total': _total.toStringAsFixed(2), // Convertendo para string formatada
      'data_hora': dataHora,
    };

    try {
      // Inserir a comanda no banco de dados
      int result = await DatabaseHelper.instance.insertComanda(novaComanda);
      print('Comanda inserida com sucesso: $result');

      // Verificar se os dados estão corretos
      print('Dados para inserção: $novaComanda');

      print("Resultado da inserção da comanda: $result");

      // Verificar o resultado da inserção
      print('Resultado da inserção: $result');

      // Limpa os dados da comanda da memória
      setState(() {
        _comandas.remove(widget.comandaId); // Remove a comanda da memória
        _clienteController.clear();
        _garcomController.clear();
        _itens.clear();
        _total = 0.0;
      });

      // Exibe uma mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comanda fechada com sucesso!')),
      );

      // Volta para a tela inicial (onde a lista de comandas é exibida)
      Navigator.pop(context);  // Essa linha faz a navegação de volta

    } catch (e) {
      print('Erro ao salvar no banco: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fechar comanda: $e')),
      );
    }
  }



  Widget _buildItemControl(String produto, double preco) {
    int quantidade = _itens[produto] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$produto: $quantidade', style: TextStyle(color: AppTheme.produtoColor, fontSize: 18)),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove, color: AppTheme.produtoColor),
              onPressed: quantidade > 0 ? () => _removerItem(produto, preco) : null,
            ),
            IconButton(
              icon: Icon(Icons.add, color: AppTheme.produtoColor),
              onPressed: () => _adicionarItem(produto, preco),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comanda ${widget.comandaId + 1}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _clienteController,
                decoration: InputDecoration(
                  labelText: 'Nome do Cliente',
                  hintText: 'Digite o nome do cliente',
                ),
                onChanged: (_) => _salvarEstado(),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _garcomController,
                decoration: InputDecoration(
                  labelText: 'Nome do Garçom',
                  hintText: 'Digite o nome do Garçom',
                ),
                onChanged: (_) => _salvarEstado(),
              ),
              SizedBox(height: 20),
              ...espetos.entries.map((entry) => _buildItemControl(entry.key, entry.value)).toList(),
              SizedBox(height: 60),
              ...bebidas.entries.map((entry) => _buildItemControl(entry.key, entry.value)).toList(),
              SizedBox(height: 60),
              ...entradas.entries.map((entry) => _buildItemControl(entry.key, entry.value)).toList(),
              SizedBox(height: 60),
              ...porcoes.entries.map((entry) => _buildItemControl(entry.key, entry.value)).toList(),
              SizedBox(height: 20),
              Text(
                'Total: R\$ ${_total.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _fecharComanda,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                child: Text('Fechar Comanda', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
