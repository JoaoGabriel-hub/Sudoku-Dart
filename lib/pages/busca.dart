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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Busca')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20), // Espaçamento entre elementos
            ElevatedButton(
              onPressed: () {
                // Printando as variáveis result, name e level
                print('Result: $result');
                print('Name: $name');
                print('Level: $level');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Mostrar última partida'),
            ),
          ],
        ),
      ),
    );
  }
}
