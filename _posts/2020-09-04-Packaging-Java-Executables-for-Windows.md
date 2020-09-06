---
layout: post
title: Packaging Java Executables to run in Windows as an .exe
---

Packaging up applications for other people to use once you've developed them can be quite the battle. This post explores packaging up our favourite snake game to run in a Windows environment via a double click with NO dependencies!

## The Game

I decided to write a similar implementation of the [snake game](2020-08-14-SNAKE_||_React.md) I previously had written in React, in good ol' Java (using Swing). The purpose of this post is not to re-visit the logic of the game, but I did decide to include a title screen and some indication of where the snake's head is this time! For those interested in the game logic check out the [repository](https://github.com/sgregory8/java-snake) and the [releases](https://github.com/sgregory8/java-snake/releases).

## The Goal

As stated above the goal is to create an executable that is sharable and runnable via a double click. The user need not have Java installed at all. We'll approach this in a few steps:

1. Use [launch4j](http://launch4j.sourceforge.net/) to create an .exe and bundle a JRE (Java runtime environment)
2. Use [7-Zip](https://www.7-zip.org/) to archive our executable and JRE together
3. Use [7-Zip SFX Maker](https://sourceforge.net/projects/sfx-maker/) to create a self extracting .exe and run the application

The end result should allow easy click access to our Java app.

## launch4j

Downloading launch4j is straight forward. Running it with the latest greatest version of Java proved a problem so I used [openJDK 9.0.4](https://jdk.java.net/archive/). After running the .jar the UI opens and it's a fairly straight forward process populating the various fields.

### Basic

![launch4j basic configuration](/images/launch4j_basic.png)

### JRE

![launch4j basic configuration](/images/launch4j_jre.png)
