import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snake/blank_pixel.dart';
import 'package:snake/food_pixel.dart';
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

  bool gameHasStarted = false;

  // Scorul utilizatorului
  int currentScore = 0;

  // Positia sarpelui
  List<int> snakePos = [0, 1, 2];

  // Directia sarpelui este indreptata spre dreapta initial
  var currentDirection = snake_Direction.RIGHT;

  // Pozitia mancarii
  int foodPos = 55;

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
    // Adaugam scorul in firebase
  }

  void newGame() {
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(children: [
        // high scores
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Scorul utilizatorului
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Scorul curent"),
                  Text(
                    currentScore.toString(),
                    style: TextStyle(fontSize: 36),
                  ),
                ],
              ),

              // Cele mai bune scoruri
              Text('Cele mai bune scoruri: ')
            ],
          ),
        ),

        // game grid
        Expanded(
          flex: 4,
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
    );
  }
}
