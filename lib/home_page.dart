import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snake/blank_pixel.dart';
import 'package:snake/food_pixel.dart';
import 'package:snake/highscore_tile.dart';
import 'package:snake/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  // Dimensiunile grid-ului
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  //Setarile jocului
  bool gameHasStarted = false;
  final _nameController = TextEditingController();

  // Scorul utilizatorului
  int currentScore = 0;

  // Positia sarpelui
  List<int> snakePos = [0, 1, 2];

  // Directia sarpelui este indreptata spre dreapta initial
  var currentDirection = snake_Direction.RIGHT;

  // Pozitia mancarii
  int foodPos = 55;

  // Lista cu highscore-uri
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs.forEach((element) {
              highscore_DocIds.add(element.reference.id);
            }));
  }

  // Incepe jocul
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        // Tinem sarpele in miscare
        moveSnake();

        // Verificam daca jocul este terminat sau nu
        if (gameOver()) {
          timer.cancel();

          // Il atentionam pe utilizator
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text('Ai pierdut!'),
                  content: Column(
                    children: [
                      Text('Scorul tau este de: ' + currentScore.toString()),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(hintText: 'Introdu numele'),
                      ),
                    ],
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                        submitScore();
                        newGame();
                      },
                      child: Text('Salveaza scorul'),
                      color: Colors.pink,
                    )
                  ],
                );
              });
        }
      });
    });
  }

  void submitScore() {
    // Accesam colectia
    var database = FirebaseFirestore.instance;

    // Adaugam scorul in firebase
    database.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }

  Future newGame() async {
    highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakePos = [
        0,
        1,
        2,
      ];
      foodPos = 55;
      currentDirection = snake_Direction.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void eatFood() {
    currentScore++;
    // Ne asiguram ca noua mancare nu este unde este sarpele
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          // Adaugam capul sarpelui
          // Coliziunea cu peretele din dreapta
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }
        break;

      case snake_Direction.LEFT:
        {
          // Adaugam capul sarpelui
          // Coliziunea cu peretele din stanga
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
        break;

      case snake_Direction.UP:
        {
          // Adaugam capul sarpelui
          // Coliziunea cu peretele de sus
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;

      case snake_Direction.DOWN:
        {
          // Adaugam capul sarpelui
          // Coliziunea cu peretele de jos
          if (snakePos.last + rowSize > totalNumberOfSquares) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }
        break;
      default:
    }

    // Sarpele creste in lungime mancand
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      // stergem coada sarpelui
      snakePos.removeAt(0);
    }
  }

  // Jocul s-a terminat
  bool gameOver() {
    // Jocul se termina cand sarpele se mananca pe el
    // Atunci cand este aceeasi pozitie de doua ori in snakePos

    // Lista corp sarpe (fara cap)
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);

    if (bodySnake.contains(snakePos.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    //responsive
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: screenWidth > 428 ? 428 : screenWidth,
        child: Column(children: [
          // Cele mai bune scoruri
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Scorul utilizatorului
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Scorul curent"),
                      Text(
                        currentScore.toString(),
                        style: TextStyle(fontSize: 36),
                      ),
                    ],
                  ),
                ),

                // Cele mai bune scoruri
                Expanded(
                  child: gameHasStarted
                      ? Container()
                      : FutureBuilder(
                          future: letsGetDocIds,
                          builder: (context, snapshot) {
                            return ListView.builder(
                                itemCount: highscore_DocIds.length,
                                itemBuilder: ((context, index) {
                                  return HighscoreTile(
                                      documentId: highscore_DocIds[index]);
                                }));
                          }),
                )
              ],
            ),
          ),

          // game grid
          Expanded(
            flex: 3,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0 &&
                    currentDirection != snake_Direction.UP) {
                  currentDirection = snake_Direction.DOWN;
                } else if (details.delta.dy < 0 &&
                    currentDirection != snake_Direction.DOWN) {
                  //print('move up');
                  currentDirection = snake_Direction.UP;
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 &&
                    currentDirection != snake_Direction.LEFT) {
                  //print('move right');
                  currentDirection = snake_Direction.RIGHT;
                } else if (details.delta.dx < 0 &&
                    currentDirection != snake_Direction.RIGHT) {
                  //print('move left');
                  currentDirection = snake_Direction.LEFT;
                }
              },
              child: GridView.builder(
                  itemCount: totalNumberOfSquares,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowSize),
                  itemBuilder: (context, index) {
                    if (snakePos.contains(index)) {
                      return const SnakePixel();
                    } else if (foodPos == index) {
                      return const FoodPixel();
                    } else {
                      return const BlankPixel();
                    }
                  }),
            ),
          ),

          //play button
          Expanded(
            child: Container(
              child: Center(
                child: MaterialButton(
                  child: Text('PLAY'),
                  color: gameHasStarted ? Colors.grey : Colors.pink,
                  onPressed: gameHasStarted ? () {} : startGame,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
