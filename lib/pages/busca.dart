// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors, depend_on_referenced_packages, avoid_print, unnecessary_import, unused_element, unused_import

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:sudoku/pages/game.dart'; // Importa o arquivo com createTableRodadas

class Busca extends StatefulWidget {
  @override
  _Busca createState() => _Busca();
}

class _Busca extends State<Busca> {
  late Database database;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
  try {
    // Inicializa o banco de dados
    sqfliteFfiInit();
    var dbFactory = databaseFactoryFfi;
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'sudoku.db');
    database = await dbFactory.openDatabase(path);

    // Cria a tabela "rodadas" se ela não existir
    await database.execute("""
    CREATE TABLE IF NOT EXISTS rodadas(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR NOT NULL,
      result INTEGER,
      level INTEGER
    );
    """);
    print('Banco de dados inicializado em $path');
  } catch (e) {
    print('Erro ao inicializar o banco de dados: $e');
  }
}

  Future<void> _printRodadas() async {
    try {
      // Busca todas as rodadas da tabela
      final rodadas = await database.query('rodadas');
      if (rodadas.isEmpty) {
        print('Nenhuma rodada encontrada.');
      } else {
        print('Rodadas salvas:');
        for (var rodada in rodadas) {
          print(
              'Jogador: ${rodada['name']}, Resultado: ${rodada['result']}, Nível: ${rodada['level']}');
        }
      }
    } catch (e) {
      print('Erro ao buscar rodadas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Busca')),
      body: Center(
        child: ElevatedButton(
          onPressed: _printRodadas,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text('Mostrar rodadas no terminal'),
        ),
      ),
    );
  }
}
