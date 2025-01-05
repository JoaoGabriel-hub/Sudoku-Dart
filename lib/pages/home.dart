// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:sudoku/pages/arguments.dart';
import 'package:sudoku/pages/game.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? _levelRadio;

  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text("Sudoku")),

      body: Center (
        
        child: Container(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          
          children: [


            ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Como Jogar"),
                      content: Text(
                        "Regras do Sudoku:\n"
                        "- Não pode ter números repetidos em uma linha\n"
                        "- Não pode ter números repetidos em uma coluna\n"
                        "- Não pode ter números repetidos em um subgrupo 3x3",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text("Ok"),
                        ),
                      ],

                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white),
                child: Text("Como Jogar"),
              ),



            TextField(keyboardType: TextInputType.text,
              controller: textController,
              decoration: InputDecoration(
                labelText: "Nome do Jogador",
                border: OutlineInputBorder()
              ),
            ),


            Text("Escolha a dificuldade:", style: TextStyle(fontSize: 20),
            ),


            RadioListTile(
              value: "Easy",
              groupValue: _levelRadio,
              onChanged: (String? val){
                setState(() {
                  _levelRadio = val;
                });
              },
              title: Text("Easy")),
            RadioListTile(
              value: "Medium",
              groupValue: _levelRadio,
              onChanged: (String? val){
                setState(() {
                  _levelRadio = val;
                });
              },
              title: Text("Medium")),
              RadioListTile(
              value: "Hard",
              groupValue: _levelRadio,
              onChanged: (String? val){
                setState(() {
                  _levelRadio = val;
                });
              },
              title: Text("Hard")),
              RadioListTile(
              value: "Expert",
              groupValue: _levelRadio,
              onChanged: (String? val){
                setState(() {
                  _levelRadio = val;
                });
              },
              title: Text("Expert")),


            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, Game.routeName, arguments: Arguments(textController.text, _levelRadio!));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white),
              child: Text("Novo Jogo")),

            ElevatedButton(
            onPressed: () {
            Navigator.pushNamed(context, '/busca');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white),
            child: Text("Busca"))
          ],

          )
        )
      ) 
    );
  }
}