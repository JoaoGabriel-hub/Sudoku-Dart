import 'package:flutter/material.dart';

class Busca extends StatefulWidget {
  @override
  _BuscaState createState() => _BuscaState();
}

class _BuscaState extends State<Busca> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Busca'),
      ),
      body: Center(
        child: Text('Conteúdo da página de busca'),
      ),
    );
  }
}