// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:sudoku/pages/busca.dart';
import 'package:sudoku/pages/game.dart';
import 'package:sudoku/pages/home.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: "/",
    routes: {
      "/home": (context) => HomePage(),
      Game.routeName: (context) => Game(),
      "/busca": (context) => Busca(),
    },
    title: "Sudoku",
    debugShowCheckedModeBanner: false,
    home: HomePage()
  ));
}