import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;  // Para Flutter Web
  } else {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;     // Para Mobile e Desktop
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Comanda Digital',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
