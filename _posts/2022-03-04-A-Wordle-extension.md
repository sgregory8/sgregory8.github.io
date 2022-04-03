---
layout: post
title: A Wordle extension
---

The hype and buzz around Wordle may have significantly died down but there's always time to plug an extension that makes it even easier!

## How does it work?

The implementation of my wordle AI somewhat mimics how I attempted to play the game myself, I programmed it to follow these conditions:

- Pick a random guess to begin with
- If a letter turns green we know that letter is in the correct place
- If a letter turns yellow we know the secret word contains this letter somewhere
- If a letter turns grey AND the letter isn't repeated in the word then the secret word does not contain the letter

The following conditions work for a fairly simple "AI" and it is generally successful. The list of words the solver uses IS the entire list of "valid" supplied by Wordle itself

## Implementing it as a chrome extension

Chrome provides fairly reasonable documentation on implementing an extension, and packaging my code up was fairly straight forward, the extension is made up of 3 main parts.

1. The AI logic (mentioned above)
2. The popup (as HTML)
3. The messaging system to coordinate the popup content and the AI logic

### The extension in a nutshell

When you click on the extension icon the popup.html is loaded and some buttons are displayed. You're able to query the extension for a hint or just have it guess for you. Both options send a message
to the back end that updates the possible solutions and returns answers to be rendered by the popup. The extension is also able to manipulate the game board itself.

### Give it a try

The extension is available (for free) [here](https://chrome.google.com/webstore/detail/wordle-hinter/egjccogfjbjanegmgkacfkachjokhcnm), and as always code is [here](https://github.com/sgregory8/wordle-hinter)!
