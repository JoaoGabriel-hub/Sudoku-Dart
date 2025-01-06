// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors, depend_on_referenced_packages, avoid_print, unnecessary_import, unused_element

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:sudoku/pages/game.dart';

class Busca extends StatefulWidget {
  
  @override
  _BuscaState createState() => _BuscaState();
}

class _BuscaState extends State<Busca> {

  _recoverDatabase() async {
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
          await db.execute(createTableRodadas);    
          }
        )
      );
    return db;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text('Busca')),

      body: Center(

        child: Text('Conteúdo da página de busca'),



      ),
    );
  }
}