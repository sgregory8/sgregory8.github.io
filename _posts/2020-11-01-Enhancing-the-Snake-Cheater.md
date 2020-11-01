---
layout: post
title: Enhancing the Snake Cheater
---

A few weeks ago I developed a small program capable of defeating Snake. The 'science' behind it was fairly simple: follow a set pattern until victory was achieved; and it worked. But it would be nice to develop a more advanced solution so I decided to augment the codebase to provide me with more information to make smarter choices. I'm still working on how to make those choices however...

## Upgrading capturing facilities

Previously the 'cheater' scanned a proportion of the screen looking for the snake's head which was handily coloured blue. Because we didn't have to worry about collision detection with the snake's body that's all the program captured. By scanning the same screenshot for other colours such as the snake's body and the snake's food we can capture other key information for speeding up our snake.

## Capturing the body and food

The methodology for capturing both body and food is straight forward; check the scanned screenshot for body colour (red) and foor colour (green) and store the result, simple.

## Improving Debugging

It felt only natural to include something to help visualise what that the Snake Cheater 'see's' so I decided to use the console to output a low resolution capture of the our snake board whenever the game 'updates' that is to say when a move has been made. The cheating program normally loops a few times per gameplay iteration so it seemed unneccessary to write these duplicate updates.

Unfortunately 'overwriting' console output is not directly achievable out of the box and without implementing more unneccessary UI overhead I decided I could live with an ever growing console output (for now...). A simple double loop through my snake board and voila...

```java
private static void printSnake(SnakePieces[][] snakePieces) {
    StringBuilder stringBuilder = new StringBuilder();
    stringBuilder.append("___________________________________________\n");
    for (int i = 0; i < snakePieces.length; i++) {
      stringBuilder.append("|");
      for (int j = 0; j < snakePieces[i].length; j++) {
        if (snakePieces[j][i] == SnakePieces.HEAD) {
          stringBuilder.append(" H");
        } else if (snakePieces[j][i] == SnakePieces.BODY) {
          stringBuilder.append(" b");
        } else if (snakePieces[j][i] == SnakePieces.FOOD) {
          stringBuilder.append(" F");
        } else {
          stringBuilder.append(" -");
        }
      }
      stringBuilder.append(" |\n");
    }
    stringBuilder.append("___________________________________________");
    System.out.println(stringBuilder.toString());
  }
```

Where `H` is the snake's head, `b` it's body and `F` it's food 

```text
___________________________________________
| b b b b b b b H - - - - - - - - - - - - |
| b - - - - - - - - - - - - - - - - - - - |
| b - - - - - - - - - - - - - - - - - - - |
| b - - - - - - - - - - - - - - - - - - - |
| b b b - - - - - - - - - - - - - - - - - |
| b b b b b - - - - - - - - - - - - - - - |
| b b b b b - - - - - - - - - - - - - - - |
| b b - - b - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - F - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
___________________________________________
```

### Kicking on

Ideally this post would of covered another method to help cheat on the game but path finding methods and algorithms are not something I'm very familiar with and need to spend more time reading into before I attempt implementing them. However it's nice to see a small bit of progress to enhance what's already [existing](https://github.com/sgregory8/snake-cheater)!
