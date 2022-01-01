---
layout: post
title: A Foray into Combinatorics
---

Recently I watched a Youtube video made by Geoff Marshall (General railway infrastructure and London related transport Youtuber) that
introduced the notion of travelling on the minimum possible stations on the underground network to cover every single character in the
english alphabet (a-z).

## Geoff Marshall's A-Z

<iframe width="560" height="315" src="https://www.youtube.com/embed/rpY8Pi5aJ9k" frameborder="0" allowfullscreen></iframe>

## Smallest Combination of Stations?

Adding routing to this problem as the video does introduces certain complexities; I was initially curious of the smallest number of
stations on any part of the network that will contain the whole alphabet, they need not be contiguous.

## A Naive Approach

Usually I like to first attempt a solution in the 'most logical way' possible so that's what did here. The idea being relatively simple:

- Iterate through the entire station list
- Find the station containing the most characters in the alphabet set
- Add the station to our combination
- Remove the matching characters from the set, remove the station from the station list
- Keep going until a complete combination

I like this method as it makes sense to me and is relatively quick, it's order of operations is roughly `O((C/N)(S*N)+N*C)` where `S` is number of all the stations, `N` is the number of stations required to complete the combination and `C` is number of search characters. The algorithm actually completes in 7 cycles. `N=7`, `C=26` and `S=270` yields `O(14013)`!

This algorithm is relatively fast and finds us a solution of 7 stations, BUT it is actutally possible to do so with a combination of 6 stations and much less characters!

## The "right" Solution

To find us the smallest number of characters possible requires a much more expensive solution. How do we find the absolute smallest combination with the smallest amount of characters? We must generate combinations! Combinations can become expensive quickly as I was about to find out :|

I initially began just generating all 3 station [combinations](https://en.wikipedia.org/wiki/Combination). Which according to Wikipedia and the `nCr` formuala consists of `270C3=3244140` combinations. No luck here as there is no solution of 3 stations.

All 4 station combinations require roughly 216 million combinations and here we run into our first problem with heap space. I just chose to let the JVM consume as much memory as it needed to at this point to bypass the problem but our run time is now in minutes! And what's worse is there are no 4 station combinations satisfying our criteria either.

## Some small Optimisation

At this point I knew I would have to generate all 5 station combinations and I realised this might be the last "feasible" effort as my run time would be just about be manageable. 6 station combinations would require too much computation so I reached for an optimisation at this point to squeeze as much out of my single core program as I could.

There is only 1 station on the line containing the letter Z. And with this information we can just generate all combinations of 4 stations and add the 5th station to every combination, much quicker than generating all 5 station combinations!

However the problem cannot be solved with 5 stations onwards to 6.

## The Solution

Plugging in `270C5` into any calculator gives 11.5 billion combinations which will be too much memory for my machine to handle so again I had to make some changes to my algorithm to 'discard' (let the GC clean up) combinations that don't contain all characters. The algorithm run time is large and the order of operations roughly `O((ScN)(NC))` (roughly 1 trillion :O) though this is an absolute worse case estimation and is likely much lower.

We obtain some solutions but only care about the result with the fewest characters (52) which is:

- Chalk Farm
- Oval
- Queensway
- St. John's Wood
- Uxbridge
- Belsize Park

Code available [here](https://github.com/sgregory8/underground-stations)
