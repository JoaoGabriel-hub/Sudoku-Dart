// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors, depend_on_referenced_packages, avoid_print, unnecessary_import, unused_element

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

  // Método para inicializar o banco de dados
  Future<Database> _recoverDatabase() async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;
    final io.Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final path = p.join(appDocumentsDir.path, "databases", "banco.db");

    print("Database path: $path");
    //await databaseFactory.deleteDatabase(path);
    Database db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute(createTableRodadas); // Utiliza a tabela importada de game.dart
        },
      ),
    );
    return db;
  }

  // Função para salvar o resultado do jogo
  Future<void> saveGameResult(String name, int level, int result) async {
    try {
      Database db = await _recoverDatabase(); // Recupera o banco de dados
      await db.insert(
        'rodadas',
        {
          'name': name,
          'level': level,
          'result': result,
        },
      );
      print("Resultado salvo no banco de dados: {name: $name, level: $level, result: $result}");
    } catch (e) {
      print("Erro ao salvar o resultado no banco de dados: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text('Busca')),
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Exemplo de como usar a função saveGameResult
                await saveGameResult("Jogador1", 2, 1); // Salva um resultado fictício
                print("Dados de exemplo salvos.");
              },
              child: Text("Salvar Resultado"),
            ),
            Text('Conteúdo da página de busca'),
          ],
        ),
      ),
    );
  }
}
