import 'package:comanda_digital/AdminPage.dart';
import 'package:comanda_digital/home.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('LoginPage foi construída!');
    return Scaffold(
      appBar: AppBar(
        title: Text('Sistema de Comanda Digital'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela desejada (por exemplo, ComandaDetail)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPage()),
                );
              },
              child: Text('Entrar como Administrador'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar para a página Home
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text('Entrar como Garçom'),
            ),
          ],
        ),
      ),
    );
  }
}
