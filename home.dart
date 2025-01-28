// lib/home.dart
import 'package:flutter/material.dart';
import 'comanda_detail.dart';
import 'theme.dart';  // Importando o arquivo de tema

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Comandas',
          style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 1.0), // Opacidade corrigida para 1
          ),
        ),
        centerTitle: true, // Centraliza o título no AppBar
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Exemplo de grid com 4 colunas
        ),
        itemCount: 13, // 10 comandas como exemplo
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Ao clicar em uma comanda, vai para a tela de detalhes
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComandaDetailPage(comandaId: index),
                ),
              );
            },
            child: Card(
              color: AppTheme.cardColor, // Usando a cor amadeirada para os cards
              margin: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Comanda ${index + 1}',
                  style: TextStyle(color: AppTheme.secondaryColor), // Texto com cor marrom escuro
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
