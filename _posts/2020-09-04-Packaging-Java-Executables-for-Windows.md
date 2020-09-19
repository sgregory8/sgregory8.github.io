---
layout: post
title: Packaging Java Executables to run in Windows as an .exe
---

Packaging up applications for other people to use once you've developed them can be quite the battle. This post explores packaging up our favourite snake game to run in a Windows environment via a double click with NO dependencies!

## The Game

I decided to write a similar implementation of the [snake game](https://sgregory8.github.io/SNAKE_-_React/) I previously had written in React, in good ol' Java (using Swing). The purpose of this post is not to re-visit the logic of the game, but I did decide to include a title screen and some indication of where the snake's head is this time! For those interested in the game logic check out the [repository](https://github.com/sgregory8/java-snake) and the [releases](https://github.com/sgregory8/java-snake/releases).

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

### Build

Clicking 'Build wrapper' should create an .exe that's runnable. It would be easy to finish here but to share this with someone who doesn't have Java would require sharing the whole folder structure. Expecting a user to maintain these bits and pieces isn't ideal and the notion of a folder called 'jre' doesn't provide much context or benefit to the user.

## 7-Zip

This part is simple and we'll use 7-Zip to add our entire 'output' so far. That is, the folder containing the .exe and the Java runtime environment. We end up with a single .7z archive.

![launch4j basic configuration](/images/7Zip_archive.png)

## 7-Zip SFX

Finally we'll use 7-Zip SFX to create a self extracting archive that runs our .exe! All of this should be completely abstracted away from the user.

### Adding the Archive

We'll navigate to the .7z archive and add the file first. Next we'll make sure we're extracting this to a temporary folder (so the user doesn't have to care where it goes).

![launch4j basic configuration](/images/7Zip_SFX_dialogs.png)

And add the task to run our executable when it's opened

![launch4j basic configuration](/images/7Zip_SFX_task.png)

After clicking 'Make SFX' we should have a new executable generated that just runs! The final size is around 300MB which isn't ideal but tricks to reduce the size of the bundled JRE and compressing the .exe can be used to make it smaller. Nonetheless i've released v1.01 [here](https://github.com/sgregory8/java-snake/releases/tag/1.01) and confirmed it works (at least it does on my Microsoft Surface).
