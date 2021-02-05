---
layout: post
title: Tic Tac Toe in C++
---

C++ has always been a language that has interested me. Coming from a more web-orientated environment it's easy to forget how much other languages and frameworks abstract away from the developer. The aim here is to write a (very) small Tic Tac Toe game that inherits multiple improvements over time!

## Drawing the game

Implementing a GUI always introduces complexities. The scope of this project is to implement a minimum viable 'product' so I'll divert to using the console (for now).

## A Simple Game Loop

A simple game loop is all that's required for this example

```cpp
int main(int argc, const char * argv[]) {
    while(!gameOver) {
        takeInput();
        drawBoard();
        gameLogic();
    }
    std::cout << "Winner is player " << p << std::endl;
    return 0;
}
```

## Picking where to move

The board is indexed from 1-9 and the player must enter a posistion as to where they would like to go. The validation logic only checks the square is empty otherwise it will prompt them again. Additional error handling to guard against useless input has not been implemented. Segmentation faults are certainly possible :|

## Deciding a Winner

The 'hardest' part about implementing a simple Tic Tac Toe game is deciding when the game is won (or lost). For simplicity's sake I've made an algorithm that simply checks all of the columns for three of the same character and likewise the rows. The condition is short ciruiting so if the first two characters of a row or column are different it won't evaluate the final check. Diaganols are also checked.

## Improvments

Although syntactically nothing much has changed about how this code is implemented when compared to other languages the point is to build upon the code and implement more functionality that will expose differences in how code is organised, compiled and written using C++! Improvements planned:

1. Implement safer error handling.
2. Implement a GUI that responds to clicks as well as key events.
3. Organise the project by logical concern, i.e keep the GUI logic seperate from the game logic.
4. Tinker with different compilation options and investigate cross platform compatibility

[Code here](https://github.com/sgregory8/tic-tac-toe)
