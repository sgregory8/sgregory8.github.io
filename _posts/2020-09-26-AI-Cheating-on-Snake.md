---
layout: post
title: AI Cheating on Snake
---

This might be another Snake related post but finding ways to cheat in this game provides some interesting challenges indeed.

## The Idea

Seeing as I've already developed a (hopefully) watertight implementation of the classic Snake game, the aim is to simply achieve the maximum possible score.

## The Cheat Design

Java provides some very useful functionality inside [`java.awt.Robot`](https://docs.oracle.com/javase/9/docs/api/java/awt/Robot.html) which is used to form the fundamental basis of my cheat design. The idea being that it makes simulating key presses and taking screenshots a breeze (with some tinkering).

### Opening the Application

First thing is first, the cheat app will have to open a copy of the game. This is fairly straight forward; I chose to run a new process by running the game jar directly.

```Java
Process process = Runtime.getRuntime()
        .exec(
            "java -jar /Users/gregory1/learning/java-projects/snake/target/Snake-1.01-runnable.jar");
    process.waitFor(5, TimeUnit.SECONDS);
```

After waiting for 5 seconds (to make sure the game is open) we can begin the cheating process.

### Finding the Snake

Using `Robot` it's possible to take a screenshot of a select portion of the screen; seeing as our application size is known and it always opens in the top left of our screen we know where we need to screenshot.

After capturing the screenshot it's a case of looping through the pixel RGB values to find the snake's head. To keep this as efficient as possible I chose to loop through in blocks of 20 pixels (that's the size of the snake head).

```Java
  snakeSnapshot = robot.createScreenCapture(new Rectangle(gameBoardX1, gameBoardY1, 420, 420));
  for (int width = 0; width < (snakeSnapshot.getWidth()) / 20; width++) {
    for (int height = 0; height < (snakeSnapshot.getHeight()) / 20; height++) {
      if (snakeSnapshot.getRGB(width * 20, height * 20) == snakeHeadColour) {
        snakeHeadx = width;
        snakeHeady = height;
      }
    }
  }
```

### Creating the Path

As this was meant to be a relatively quick exercise (it wasn't) I decided to generate a [Hamiltonian path](https://en.wikipedia.org/wiki/Hamiltonian_path) for the snake grid. Essentially I just needed a cycle for the snake to follow such that it vists every square in the grid once and returns to the beginning to repeat the cycle. It's not particularly quick but it is effective.

### Putting it all Together

Now that I know where the snake's head is and the path it should follow it's just a case of sending key events to the OS to tell the snake where to go. Again `Robot` is the way to go.

```Java
// This is left
robot.keyPress(37);
```

### Mac issues with Robot

Despite the `Robot` API being relatively straight forward to use I encountered a couple of issues. The first being I had to specifically allow accessiblity for Intellij (enabled from within security preferences).

The second issue resulted in this error message: `<pid> is calling TIS/TSM in non-main thread environment, ERROR : This is NOT allowed. Please call TIS/TSM in main thread!!!`, which did not cause the application to fail but was solved by adding `-XstartOnFirstThread` to the application run configuration.

## The Result

The end result is a snake that follows a long and tedious path over and over, but it does allow for huge scoring (in fact maximum scoring). It was effective in exposing a few bugs in my implementation of the game itself and demonstrates some aspects of the game are simply too inefficiently implemented (a post for another day?).

The algorithm is also VERY slow. Implementing a set Hamiltonian path is one of the simplest options but with the groundwork in place it's certainly possible to find much quicker solutions.

Code [here](https://github.com/sgregory8/snake-cheater).

<img src="https://raw.githubusercontent.com/sgregory8/sgregory8.github.io/master/images/Hamiltonian_snake.png" width="250">
