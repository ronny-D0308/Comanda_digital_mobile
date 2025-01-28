import 'package:flutter/material.dart';

class ComandaProvider with ChangeNotifier {
  // Mapa para armazenar os itens e totais de cada comanda
  Map<int, Map<String, int>> _comandasItens = {}; // {comandaId: {produto: quantidade}}
  Map<int, double> _comandasTotal = {}; // {comandaId: total}

  // Mapa para armazenar o nome do cliente de cada comanda
  Map<int, String> _clientes = {}; // {comandaId: nomeCliente}
  Map<int, String> _garcom = {};

  // Método para acessar os itens de uma comanda
  Map<String, int> getItens(int comandaId) {
    // Se a comanda não existe, inicializamos ela
    if (!_comandasItens.containsKey(comandaId)) {
      _comandasItens[comandaId] = {}; // Inicializa a comanda se não existir
      _comandasTotal[comandaId] = 0.0; // Inicializa o total da comanda
      _clientes[comandaId] = ''; // Inicializa o nome do cliente como vazio
      _garcom[comandaId] = '';
    }
    return _comandasItens[comandaId]!;
  }

  // Método para armazenar o nome do cliente na comanda
  void setClienteNome(int comandaId, String nomeCliente) {
    _clientes[comandaId] = nomeCliente;  // Armazena o nome do cliente para a comanda
    notifyListeners();  // Notifica os ouvintes que houve uma alteração no nome
  }

  // Método para recuperar o nome do cliente
  String getClienteNome(int comandaId) {
    // Retorna o nome do cliente ou 'Nome não informado' caso não tenha sido informado
    return _clientes[comandaId] ?? 'Nome não informado';
  }


  // Método para armazenar o nome do garçom na comanda
  void setGarcomNome(int comandaId, String nomeGarcom) {
    _garcom[comandaId] = nomeGarcom;  // Armazena o nome do cliente para a comanda
    notifyListeners();  // Notifica os ouvintes que houve uma alteração no nome
  }

  // Método para recuperar o nome do garçom
  String getGarcomNome(int comandaId) {
    // Retorna o nome do cliente ou 'Nome não informado' caso não tenha sido informado
    return _garcom[comandaId] ?? 'Nome não informado';
  }

  // Método para adicionar um item genérico (produto) na comanda
  void adicionarItem(int comandaId, String produto, double preco) {
    // Inicializa os dados da comanda (itens)
    Map<String, int> itensComanda = getItens(comandaId);
    // Se o item já existe, aumenta a quantidade
    if (itensComanda.containsKey(produto)) {
      itensComanda[produto] = itensComanda[produto]! + 1;
    } else {
      itensComanda[produto] = 1;
    }

    // Atualiza o total da comanda
    _comandasTotal[comandaId] = (_comandasTotal[comandaId] ?? 0.0) + preco;
    // Notifica os ouvintes que houve uma alteração
    notifyListeners();
  }

  void removerItem(int comandaId, String produto, double preco) {
    Map<String, int> itensComanda = getItens(comandaId);
    if (itensComanda.containsKey(produto) && itensComanda[produto]! > 0) {
      itensComanda[produto] = itensComanda[produto]! - 1;
      // Garantir que o total não seja negativo
      _comandasTotal[comandaId] = (_comandasTotal[comandaId]! - preco).clamp(0.0, double.infinity);
      if (itensComanda[produto] == 0) {
        itensComanda.remove(produto);
      }
      notifyListeners();
    }
  }


  // Método para obter o total da comanda
  double getTotal(int comandaId) {
    return _comandasTotal[comandaId] ?? 0.0;
  }

  // Método para limpar a comanda
  void limparComanda(int comandaId) {
    _comandasItens[comandaId]?.clear();  // Limpa os itens da comanda
    _comandasTotal[comandaId] = 0.0;  // Zera o total da comanda
    _clientes[comandaId] = '';  // Limpa o nome do cliente
    _garcom[comandaId] = '';
    // Notifica os ouvintes que houve uma alteração
    notifyListeners();
  }
}
