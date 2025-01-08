// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, avoid_print, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:sudoku/pages/arguments.dart';
import 'package:sudoku_dart/sudoku_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

// Definição da tabela "rodadas" como constante global
const String createTableRodadas = """
CREATE TABLE IF NOT EXISTS rodadas(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR NOT NULL,
  result INTEGER,
  level INTEGER,
  date TEXT
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

  List<int> playerInput = List.filled(81, -1);
  List<TextEditingController> controllers = List.generate(81, (_) => TextEditingController());
  bool isSudokuReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var args = ModalRoute.of(context)!.settings.arguments as Arguments;

      if (args.level == 0) {
        sudoku = Sudoku.generate(Level.easy);
      } else if (args.level == 1) {
        sudoku = Sudoku.generate(Level.medium);
      } else if (args.level == 2) {
        sudoku = Sudoku.generate(Level.hard);
      } else if (args.level == 3) {
        sudoku = Sudoku.generate(Level.expert);
      } else {
        sudoku = Sudoku.generate(Level.easy);
      }

      for (int i = 0; i < 81; i++) {
        playerInput[i] = sudoku.puzzle[i];
        if (sudoku.puzzle[i] != -1) {
          controllers[i].text = sudoku.puzzle[i].toString();
        }
      }

      setState(() {
        isSudokuReady = true;
      });
    });
  }

  // Função para garantir que a coluna 'date' exista na tabela
  Future<void> ensureDateColumn(Database database) async {
    final result = await database.rawQuery("PRAGMA table_info(rodadas);");
    final hasDateColumn = result.any((column) => column['name'] == 'date');
    if (!hasDateColumn) {
      await database.execute("ALTER TABLE rodadas ADD COLUMN date TEXT;");
    }
  }

  // Função para salvar a rodada no banco de dados
  Future<void> _saveRodada(String name, int result, int level) async {
    try {
      sqfliteFfiInit();
      var dbFactory = databaseFactoryFfi;
      final directory = await getApplicationDocumentsDirectory();
      final path = p.join(directory.path, 'sudoku.db');
      final database = await dbFactory.openDatabase(path);

      // Garante que a coluna 'date' exista
      await ensureDateColumn(database);

      String currentDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      await database.insert(
        'rodadas',
        {
          'name': name,
          'result': result,
          'level': level,
          'date': currentDate,
        },
      );
      print('Rodada salva: Jogador=$name, Resultado=$result, Nível=$level, Data=$currentDate');
    } catch (e) {
      print('Erro ao salvar rodada: $e');
    }
  }

  int checkWinCondition() {
    bool hasWon = true;

    for (int i = 0; i < 81; i++) {
      if (playerInput[i] == -1 || playerInput[i] != sudoku.solution[i]) {
        hasWon = false;
        break;
      }
    }

    String playerName = (ModalRoute.of(context)!.settings.arguments as Arguments).name;
    int gameLevel = (ModalRoute.of(context)!.settings.arguments as Arguments).level;

    _saveRodada(playerName, hasWon ? 1 : 0, gameLevel);

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
    if (!isSudokuReady) {
      return Scaffold(
        appBar: AppBar(title: Text("Sudoku")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Sudoku")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Jogador: ${(ModalRoute.of(context)!.settings.arguments as Arguments).name}"),
            Text("Nível: ${(ModalRoute.of(context)!.settings.arguments as Arguments).level}"),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9,
                  childAspectRatio: 1.0,
                ),
                itemCount: 81,
                itemBuilder: (context, index) {
                  int value = sudoku.puzzle[index];

                  Color cellColor;

                  if (value != -1) {
                    cellColor = Colors.white;
                  } else if (playerInput[index] == sudoku.solution[index]) {
                    cellColor = Colors.blue[200]!;
                  } else if (playerInput[index] != -1 && playerInput[index] != sudoku.solution[index]) {
                    cellColor = Colors.red[200]!;
                  } else {
                    cellColor = Colors.white;
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: cellColor,
                      border: Border.all(color: Colors.black),
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
                                int? newValue = int.tryParse(input);
                                if (newValue != null && newValue >= 1 && newValue <= 9) {
                                  setState(() {
                                    playerInput[index] = newValue;
                                  });
                                } else {
                                  setState(() {
                                    playerInput[index] = -1;
                                    controllers[index].clear();
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
                checkWinCondition();
              },
              child: Text("Submeter"),
            ),
          ],
        ),
      ),
    );
  }
}
