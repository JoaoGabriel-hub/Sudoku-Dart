// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, avoid_print, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:sudoku/pages/arguments.dart';
import 'package:sudoku_dart/sudoku_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;


// Definição da tabela "rodadas" como constante global
const String createTableRodadas = """
CREATE TABLE rodadas(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR NOT NULL,
  result INTEGER,
  level INTEGER
);
""";

int? result;
String? name;
int? level;


class Game extends StatefulWidget {
  const Game({super.key});
  static String routeName = "/game";

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late Sudoku sudoku;
  List<int> playerInput = List.filled(81, -1); // Inicializa a lista do input do jogador
  List<TextEditingController> controllers = List.generate(81, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var args = ModalRoute.of(context)!.settings.arguments as Arguments;

      // Inicializa o Sudoku apenas uma vez conforme a dificuldade
      if (args.level == 0) {
        sudoku = Sudoku.generate(Level.easy);
      } else if (args.level == 1) {
        sudoku = Sudoku.generate(Level.medium);
      } else if (args.level == 2) {
        sudoku = Sudoku.generate(Level.hard);
      } else if (args.level == 3) {
        sudoku = Sudoku.generate(Level.expert);
      } else {
        sudoku = Sudoku.generate(Level.easy); // Padrão se não definido
      }

      // Inicializa `playerInput` com os valores do puzzle gerado
      for (int i = 0; i < 81; i++) {
        playerInput[i] = sudoku.puzzle[i];
        // Se a posição já tem um valor, atualiza o controlador para mostrar o número fixo no campo
        if (sudoku.puzzle[i] != -1) {
          controllers[i].text = sudoku.puzzle[i].toString();
        }
      }

      setState(() {}); // Atualiza o estado para renderizar o tabuleiro gerado
    });
  }

  // Função para salvar a rodada no banco de dados
  Future<void> _saveRodada(String name, int result, int level) async {
    try {
      sqfliteFfiInit();
      var dbFactory = databaseFactoryFfi;
      final directory = await getApplicationDocumentsDirectory();
      final path = p.join(directory.path, 'sudoku.db');
      final database = await dbFactory.openDatabase(path);

      await database.insert(
        'rodadas',
        {
          'name': name,
          'result': result,
          'level': level,
        },
      );
      print('Rodada salva com sucesso: Jogador=$name, Resultado=$result, Nível=$level');
    } catch (e) {
      print('Erro ao salvar rodada: $e');
    }
  }

  int checkWinCondition() {
    bool hasWon = true;

    // Compara cada posição do `playerInput` com a solução correta
    for (int i = 0; i < 81; i++) {
      if (playerInput[i] == -1) {
        hasWon = false;
        break;
      } else if (playerInput[i] != sudoku.solution[i]) {
        hasWon = false;
        break;
      }
    }

    // Nome e nível do jogador vindo dos argumentos da rota
    String playerName = (ModalRoute.of(context)!.settings.arguments as Arguments).name;
    int gameLevel = (ModalRoute.of(context)!.settings.arguments as Arguments).level;

    // Salva a rodada no banco de dados com o resultado
    _saveRodada(playerName, hasWon ? 1 : 0, gameLevel);

    // Exibe o alerta com base no resultado
    if (hasWon) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Parabéns!"),
          content: Text("Você completou o Sudoku com sucesso!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Ops!"),
          content: Text("O tabuleiro está incompleto ou possui erros. Tente novamente!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }

    return hasWon ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    print(sudoku.solution);

    return Scaffold(
      appBar: AppBar(title: Text("Sudoku")),
      body: sudoku == null
          ? Center(child: CircularProgressIndicator()) // Exibe um loading enquanto o tabuleiro é gerado
          : Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Jogador: ${(ModalRoute.of(context)!.settings.arguments as Arguments).name}"),
                    Text("Nível: ${(ModalRoute.of(context)!.settings.arguments as Arguments).level}"),
                    
                    // Exibição do tabuleiro de Sudoku
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 9,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: 81,
                        itemBuilder: (context, index) {
                          int row = index ~/ 9;
                          int col = index % 9;
                          int value = sudoku.puzzle[row * 9 + col];

                          Color cellColor;

                          if (value != -1) {
                            // Mantém o fundo branco para valores gerados pela API
                            cellColor = Colors.white;
                          } else if (playerInput[index] == sudoku.solution[row * 9 + col]) {
                            // Altera para azul somente se o jogador inseriu o valor correto
                            cellColor = Colors.blue[200]!;
                          } else if (playerInput[index] != -1 && playerInput[index] != sudoku.solution[row * 9 + col]) {
                            // Altera para vermelho se o jogador inseriu o valor incorreto
                            cellColor = Colors.red[200]!;
                          } else {
                            cellColor = Colors.white; // Fundo padrão para células vazias
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: cellColor,
                              border: Border(
                                top: BorderSide(
                                    color: Colors.black,
                                    width: row % 3 == 0 ? 2.0 : 0.5), // Linha grossa no topo de cada 3 linhas
                                left: BorderSide(
                                    color: Colors.black,
                                    width: col % 3 == 0 ? 2.0 : 0.5), // Linha grossa à esquerda de cada 3 colunas
                                right: BorderSide(
                                    color: Colors.black,
                                    width: (col + 1) % 3 == 0 ? 2.0 : 0.5), // Linha grossa à direita de cada bloco
                                bottom: BorderSide(
                                    color: Colors.black,
                                    width: (row + 1) % 3 == 0 ? 2.0 : 0.5), // Linha grossa na parte inferior de cada bloco
                              ),
                            ),
                            
                            child: Center(
                              child: value == -1
                                  ? TextField(
                                      controller: controllers[index],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      style: TextStyle(fontSize: 20),
                                      onChanged: (input) {
                                        // Converte o valor do input em inteiro
                                        int? newValue = int.tryParse(input);
                                        if (newValue != null && newValue >= 1 && newValue <= 9) {
                                          setState(() {
                                            playerInput[index] = newValue; // Armazena o valor inserido
                                          });
                                        } else {
                                          setState(() {
                                            playerInput[index] = -1; // Reseta o valor se for inválido
                                            controllers[index].clear(); // Limpa o campo se o input for inválido
                                          });
                                        }
                                      },
                                    )
                                  : Text(
                                      value.toString(),
                                      style: TextStyle(fontSize: 20),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    ElevatedButton(
                      onPressed: () {
                        /*print("Botão 'Submeter' foi clicado."); 
                        print(playerInput); 
                        print(sudoku.solution); */  //Prints de teste
                        int result = checkWinCondition();
                        setState(() {
                          result = result; // Atualiza o resultado global
                          name = (ModalRoute.of(context)!.settings.arguments as Arguments).name; // Atualiza o nome global
                          level = (ModalRoute.of(context)!.settings.arguments as Arguments).level; // Atualiza o nível global
                        });
                      },
                      style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white),
                      child: Text("Submeter"),
                    ),
                  ],
                ),
                
              ),
            ),
    );
  }
}
