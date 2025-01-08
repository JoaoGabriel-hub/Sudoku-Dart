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
  List<Map<String, dynamic>> rodadas = []; // Lista para armazenar as rodadas do banco
  int? selectedLevel; // Nível de dificuldade selecionado

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
        level INTEGER,
        date TEXT NOT NULL
      );
      """);
      print('Banco de dados inicializado em $path');
      await _fetchRodadas(); // Busca as rodadas ao iniciar o app
    } catch (e) {
      print('Erro ao inicializar o banco de dados: $e');
    }
  }

  Future<void> _fetchRodadas({int? level}) async {
    try {
      // Consulta as rodadas filtrando pelo nível se necessário
      final data = level != null
          ? await database.query('rodadas', where: 'level = ?', whereArgs: [level])
          : await database.query('rodadas');
      setState(() {
        rodadas = data; // Atualiza a lista de rodadas com os dados do banco
      });
    } catch (e) {
      print('Erro ao buscar rodadas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Busca'),
        actions: [
          PopupMenuButton<int>(
            onSelected: (int level) async {
              setState(() {
                selectedLevel = level; // Atualiza o nível selecionado
              });
              await _fetchRodadas(level: level); // Filtra as rodadas pelo nível selecionado
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: null, child: Text("Todos os níveis")),
              PopupMenuItem(value: 0, child: Text("Fácil")),
              PopupMenuItem(value: 1, child: Text("Médio")),
              PopupMenuItem(value: 2, child: Text("Difícil")),
              PopupMenuItem(value: 3, child: Text("Expert")),
            ],
          ),
        ],
      ),
      body: rodadas.isEmpty
          ? Center(
              child: Text(selectedLevel == null
                  ? 'Nenhuma rodada encontrada.'
                  : 'Nenhuma rodada encontrada para o nível selecionado.'),
            )
          : ListView.builder(
              itemCount: rodadas.length,
              itemBuilder: (context, index) {
                final rodada = rodadas[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Jogador: ${rodada['name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resultado: ${rodada['result'] == 1 ? "Vitória" : "Derrota"}'),
                        Text('Nível: ${rodada['level']}'),
                        Text('Data: ${rodada['date']}'),
                      ],
                    ),
                    trailing: Text('ID: ${rodada['id']}'),
                  ),
                );
              },
            ),
    );
  }
}
