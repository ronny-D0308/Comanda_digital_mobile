// lib/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Definindo cores amadeiradas
  static const Color primaryColor = Color(0xFF8B5E3C); // Marrom amadeirado
  static const Color secondaryColor = Color(0xFFffffff); // Texto comanda
  static const Color terceryColor = Color(0xFFffffff);
  static const Color produtoColor = Color(0xff101010);
  static const Color backgroundColor = Color(0xFF8B5E3C);// Fundo body
  static const Color cardColor = Color.fromARGB(255, 193, 113, 44); // Cor amadeirada para cards

  // Estilos para o AppBar
  static const AppBarTheme appBarTheme = AppBarTheme(
    color: primaryColor, // Marrom escuro para a AppBar
  );

  // Estilo de botões
  static const ButtonThemeData buttonTheme = ButtonThemeData(
    buttonColor: primaryColor, // Botões com cor amadeirada
    textTheme: ButtonTextTheme.primary,
  );

  // Estilos para textos
  static const TextTheme textTheme = TextTheme(
    bodyLarge: TextStyle(color: secondaryColor), // Texto principal com marrom escuro
    bodyMedium: TextStyle(color: primaryColor), // Texto secundário com marrom amadeirado
    titleLarge: TextStyle(color: secondaryColor, fontSize: 20, fontWeight: FontWeight.bold),
  );

  // Tema geral do app
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.brown,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: appBarTheme,
    buttonTheme: buttonTheme,
    textTheme: textTheme,
  );
}
