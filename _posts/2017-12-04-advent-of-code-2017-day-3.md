---
layout: post
title: "Advent of Code 2017, Day 3"
excerpt_separator: "<!--more-->"
tags:
  - Advent of Code
  - Haskell
categories:
  - Advent of Code 2017
---

My solution for star 2 can be found [here](https://github.com/ionathanch/adventofcode-2017/blob/master/03.hs), but without the four pages of diagramming I did to get there, it’s largely indecipherable, so here’s some explanation on the mental process.

<!--more-->

# Star 1
The spirals of the grid can be divided into “layers”:

```
┌─────────────────────┐
│ 17  16  15  14   13 │  layer 2
│    ┌───────────┐    │
│ 18 │ 5   4   3 │ 12 │  layer 1
│    │   ┌───┐   │    │
│ 19 │ 6 │ 1 │ 2 │ 11 │  layer 0
│    │   └───┘   │    │
│ 20 │ 7   8   9 │ 10 │  layer 1
│    └───────────┘    │
│ 21  22  23  24   25 │  layer 2
└─────────────────────┘
```

The lower-right corner of each layer is the square of an odd number, so each layer consists of the range of boxes `((2l — 1)^2, (2l + 1)^2]`, where `l` is the layer number. Given the nth box, we have `n <= (2l + 1)^2`, or `l >= (sqrt(x) — 1)/2`; the layer is the smallest of these values, so `l = ceiling((sqrt(x) — 1)/2)`.

`l` is also the distance from the centre of the spiral to the middle box of any edge of a layer (e.g. boxes 11, 15, 19, and 23 are 2 away from box 1). The Manhattan distance of any box is then the layer number + its distance from the middle box. We start by finding `d`, the distance of any given box from the corner box to its left.

```
┌─────────────────────┐
│ 17 │16  15  14   13 │
│    ┌───────────┐────│
│ 18 │ 5 │ 4   3 │ 12 │
│    │   ┌───┐───│    │
│ 19 │ 6 │ 1 │ 2 │ 11 │
│    │───└───┘   │    │
│ 20 │ 7   8 │ 9 │ 10 │
│────└───────────┘    │
│ 21  22  23  24 │ 25 │
└─────────────────────┘
   0   1   2   3   = d
```

The possible distances range from `0` (the corner) to `2l-1` (box before the next corner), giving `d = (n — 1) % 2l` . Finally, the distance from the middle box is given by `|d — l|` , so the final Manhattan distance of any box is then

```haskell
D = |d              — l| + l
  = |((n — 1) % 2l) — l| + l
where
l = ceiling((sqrt(n) - 1)/2)
```

For the puzzle input **368078**, this yields **371**.

# Star 2
The grid of values can also be divided into layers:

```
┌─────────────┐
│  5   4    2 │  The initial grid with which we will calculate 
│    ┌───┐    │  the values of subsequent layers.
│ 10 │ 1 │  1 │
│    └───┘    │
│ 11  23   25 │
└─────────────┘
```

The first task is to divide the boxes into different types depending on which neighbouring boxes they need to access. The following diagrammes use `█` for boxes that need to be retrieved, `x` for boxes that don’t yet exist, and `n` for the current box. In the notation below, `s(n)` will retrieve the value of the `n`th box, while `d(n)` will retrieve the number of the box directly below (layer-wise) the `n`th box, so for instance `s(d(23))` retrieves the value of box 8, which is 23. I’ve found seven different cases, six of which are distinct:

```
█ │ x │     "Normal" (all others, including bottom-right pre-corner)
█ │ n │     s(n) = s(n-1) + s(d(n)-1) + s(d(n)) + s(d(n)+1)
█ │ █ │

──────┐
x   n │     "Corner"      (top-right, top-left, bottom-left)
──┐   │     s(n) = s(n-1) + s(d(n-1))
█ │ █ │

█ │ █ │
──┘   │     "Last corner" (bottom-right)
█   n │     s(n) = s(n-1) + s(d(n-1)) + s(d(n-1) + 1)
──────┘

──────┐
x   x │     "Pre-corner"  (top-right, top-left, bottom-left)
──┐   │     s(n) = s(n-1) + s(d(n)) + s(d(n) - 1)
█ │ n │
█ │ █ │

─────────┐
x  n   █ │  "Post-corner" (top-right, top-left, bottom-left)
─────┐   │  s(n) = s(n-1) + s(n-2) + s(d(n)) + s(d(n) + 1)
█  █ │ █ │

█ │ x │
█ │ n │     "First post-corner"      (bottom-right)
──┘   │     s(n) = s(n-1) + s(d(n-1))
x   x │
──────┘

█ │ x │
█ │ n │     "First post-post-corner" (bottom-right)
█ │ █ │     s(n) = s(n-1) + s(n-2) + s(d(n)) + s(d(n) + 1)
──┘   │     (Note that this equation is the same as post-corner)
x   x │
──────┘
```

Any box can be sorted into one of these categories using its level number. Corners are given by `(2l+1)^2 — 2lm` where `m` is one of `{0..3}`, and all other boxes can be determined from this.

The function `s(n)` can be implemented as retrieval from a simple `Vector Int` or `Map Int Int`; the function `d(n)` is a bit tricker. First, given a way to find the difference between the current layer and the previous layer, we can write:

```haskell
d(n) = n - difference
```

Along each edge of the layer, the difference between two layers is constant; as you turn the corner, you add 2 to the difference. Assigning each edge a value from 0 to 3 and going anticlockwise, we have:

```haskell
d(n) = n - (initialDifference + 2 * edge)
```

The initial difference can be found using two successive odd squares, plus a constant.

```
┌─────────────────────┐
│ 17  16  15  14   13 │
│    ┌───────────┐    │
│ 18 │ 5   4   3 │ 12 │
│    │   ┌───┐   │    │
│ 19 │ 6 │ 1 │ 2 │ 11 │  11 - 2 = 9
│    │   └───┘   │    │
│ 20 │ 7   8   9 │ 10 │
│    └───────────┘    │
│ 21  22  23  24   25 │
└─────────────────────┘
```

We will use the above example as a guide. Given a layer `l`, the lower-bound odd square is given by `(2l-1)^2`, and the first post-post-corner is given by `(2l-1)^2 + 2`; in the example, this is 9 and 11, respectively. The odd square before that is `(2l-3)^2`, and the first post-corner of that layer is `(2l-3)^2 + 1`, here being 1 and 2. The difference is then

```haskell
initialDifference = (2l-1)^2      - (21-3)^2       + 1
                  = 4l^2 - 4l + 1 - 4l^2 + 12l - 9 + 1
                  = 8l - 7
```

The length of an edge is given by `2l + 1`, and the circumference is given by `(2l + 1) * 4 - 4 = 8l`. The edge number is then given by how far along the circumference n is (or the "arclength") integer-divided by one-fourth of the circumference, or

```haskell
edge = arclength      `div` 2l
     = (n - (2l-1)^2) `div` 2l
```

Putting it all together, we have:

```haskell
d(n) = n - 8l + 7 - 2 * ((n - (2l-1)^2) `div` 2l)
where
l    = ceiling((sqrt(n) - 1)/2)
```

Then starting with the initial nine boxes, we can calculate successive boxes’ values from box 10 onwards until the value is greater than **368078**, yielding the answer **369601** at box 65.

# Star 2: An Alternate Method
In the above solution, I unwrapped the spiral as a one-dimensional sequence with its index being the only indication of how it relates to other elements. Instead of coming up with these complex mathematical relationships between a box and its neighbours, I could have used a two-dimensional grid with `Vector (Vector Int)` or more likely `Map (Int, Int) Int` and starting at `(0, 0)`. Then obtaining the neighbouring boxes becomes easy, but travelling along the spiral becomes hard, as you have to keep track of how far along you’ve been and when to turn.
