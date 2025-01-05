import 'package:flutter/material.dart';

class BuscaPage extends StatefulWidget {
  @override
  _BuscaPageState createState() => _BuscaPageState();
}

class _BuscaPageState extends State<BuscaPage> {
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