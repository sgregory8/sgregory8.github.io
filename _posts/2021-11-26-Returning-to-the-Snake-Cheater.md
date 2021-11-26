---
layout: post
title: Returning to the Snake Cheater
---

Some time ago I started developing a "snake cheater" that would effectively play the snake game automatically. The solution involved something called Hamiltonian Cycles but lead to an ultimately very slow "completion" time. I remarked at the time it might be worth exploring some path finding opportunites so that's the purpose of this post.

## A brief Synopsis of A star

[A star](https://en.wikipedia.org/wiki/A*_search_algorithm) is a path traversal algorithm that is fairly common in all walks of computer science and can be used in just about any area requiring a point a to point b path with reasonable efficiency. A star is guided with the help of a user defined 'heuristic' which leads paths towards the end goal via some methodology. In my case I use distance between two nodes of my snake graph, the shorter the distance between a node and the end goal node the more the algorithm attempts to solve a path via that route!

## The "greedy" Algorithm

With A star implemented we can immediately plug it into our cheater app (with some difficulty) and no longer rely on a set Hamiltonian cycle to path our snake. This initial implementation doesn't take into account self collision so it's not perfect. The results are as expected and it's nice to have a significant speed up in attaining snake food but it often won't last long.

Here's our snake (where `H` is the head, `b` are the body parts and `F` the food)

```text
___________________________________________
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
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - H b b b b b b b - |
| - - - - - - b b b b b b b b b b b b b - |
| - - - - - - - F - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
___________________________________________
```

We can see here that the path generated will travel through the snake, thus ending the game :(

```text
___________________________________________
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
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - 1 - - - - - - - - |
| - - - - - - - - - - - 2 - - - - - - - - |
| - - - - - - - 7 6 5 4 3 - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
___________________________________________
```

## Setting obstacles

We can improve our search algorithm to take into account 'obstacles', and by obstacle we simply mean any part of the snake itself. Seeing as we already capture information about the snake body and head we can simply identify these areas of our graph and set them as obstacles. Our new algorithm can then path around the snake and we achieve something much more effective:

<img src="https://raw.githubusercontent.com/sgregory8/sgregory8.github.io/master/images/Kapture 2021-11-26 at 17.12.00.gif">

### Problems

Unfortunately this still is not perfect and as good as the A start algorithm is (performant too) we can still get into situations where the snake will path inside itself and not be able to find a good way out. Improvements might be able to be made to try to create the longest possible path where no direct path to food an be found but this will not gurantee snake safety. Future renditions might revert back to using a hamiltonian path that can be 'skipped' in certain circumstances to speed the whole process up.

There is only one way to surive this scenario and unfortunately the snake will go right to it's food but also its doom!

```text
___________________________________________
| - - - H F - b b b b b b b b b b - - - - |
| - - b b - b b - - - - - - - - - - - - - |
| - - b b b b - - - - - - - - - - - - - - |
| - - b b b - - - - - - - - - - - - - - - |
| - - b - b - - - - - - - - - - - - - - - |
| - - b - b - - - - - - - - - - - - - - - |
| - - b - b - - - - - - - - - - - - - - - |
| - - b - b - - - - - - - - - - - - - - - |
| - - b - b - - - - - - - - - - - - - - - |
| - - b - b - - - - - - - - - - - - - - - |
| - - b - b - - - - - - - - - - - - - - - |
| - - b - b - - - - - - - - - - - - - - - |
| - - b - b - - - - - - - - - - - - - - - |
| - - b - b b - - - - - - - - - - - - - - |
| - - b b b b - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
| - - - - - - - - - - - - - - - - - - - - |
___________________________________________
```
