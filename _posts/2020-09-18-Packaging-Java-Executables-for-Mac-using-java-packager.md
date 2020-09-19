---
layout: post
title: Packaging Java applications for Mac (and Windows or Linux) using JavaPackager
---

Packaging up applications written in Java to run stand alone has never been easier thanks to JavaPackager.

## The Application

Again we'll be using my [snake game](https://github.com/sgregory8/java-snake) written in Java.

## JavaPackager

[JavaPackager](https://github.com/fvarrui/JavaPackager) is a Gradle/Maven plugin that automates the complete packaging of applications in Linux, Mac and Windows. We'll be using it to create a .dmg containing our game (and runtime) that should allow for easy installation into Mac's Applications directory.

## Including the plugin

Adding the dependency for JavaPackager couldn't be simpler, we simply add the following to our pom.xml

```xml
    <dependency>
      <groupId>io.github.fvarrui</groupId>
      <artifactId>javapackager</artifactId>
      <version>1.2.0</version>
    </dependency>
```

## Configuring the plugin

The README included on the JavaPackager GitHub includes examples of how to configure JavaPackager. I've chosen to adopt the follow config

```xml
<plugin>
        <groupId>io.github.fvarrui</groupId>
        <artifactId>javapackager</artifactId>
        <version>1.2.0</version>
        <executions>
          <execution>
            <phase>package</phase>
            <id>make_dmg</id>
            <goals>
              <goal>package</goal>
            </goals>
            <configuration>
              <name>Snake</name>
              <mainClass>com.gregory.learning.App</mainClass>
              <bundleJre>true</bundleJre>
              <jrePath>A_MAC_JDK</jrePath>
            </configuration>
          </execution>
          <execution>
            <phase>package</phase>
            <id>make_windows</id>
            <goals>
              <goal>package</goal>
            </goals>
            <configuration>
              <name>Snake</name>
              <mainClass>com.gregory.learning.App</mainClass>
              <bundleJre>true</bundleJre>
              <jrePath>A_WINDOWS_JDK</jrePath>
              <platform>windows</platform>
            </configuration>
          </execution>
        </executions>
      </plugin>
```

I have configured two executions which will in turn create a Windows executable and a Mac .dmg. Unfortunately as I'm building from Mac the plugin is unable to generate an MSI. I've chosen to bundle a JRE in both cases as this makes it easier for the user to run the application.

## Including assets

Adding assets to be included with the final package is also straightforward. By default the plugin searches for a directory called assets located at project level. I've used this to include an icon for the game.

## Creating the packages

We've bound the plugin to the package phase so running `mvn clean package` should generate our executables/disk images! The target folder now contains the .dmg and .exe. Mounting the image works the same as any other Mac application and launching it from launchpad is as easy a single click. Find the .dmg amongst the other Snake releases [here](https://github.com/sgregory8/java-snake/releases/tag/1.01).
