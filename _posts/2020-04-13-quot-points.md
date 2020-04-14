---
layout: post
title: "Mathematically, Things Get Hard Real Quick"
excerpt_separator: "<!--more-->"
tags:
  - numbers
  - mathematics
  - computational complexity
---

This post is based on the observation that, in many areas of mathematics (if we take computational theory to be a subset thereof), classes of problems start to get hard at curiously small numbers. <!--more--> Somewhat more formally,

> Given a class of decision problems _P_ parameterized by some natural number _n_, for some definition of "difficulty" (e.g. complexity, undecidability, nonexistence), if there is some number _q_ such that _P(q)_ is difficult but _P(q')_ for all q' < q is not, then _q_ is "small".

The definition of "difficulty" is intentionally vague, since the concept differs among different fields, and many not be rigourously defined for others. The definition of "small" is up to taste, but from what I have found so far, it seems that _q ⩽ 7_. I'm calling the values of _q_ the _quot points_ of these problems, because "quot" is Latin for "how many?", as well as being the noise one sputters when encountering a difficult problem. It also evokes the sense of "quotient", in that quot points divide problems into the difficult and the non-difficult. If a problem has quot point _q_, then it can be said to be a _q_-quot problem. Below are various quot points _q_ with some _q_-quot problems.

### _q = 1_

* [**nth-order logic**](https://en.wikipedia.org/wiki/Higher-order_logic): Is the validity of an arbitrary _n_​th-order logic formula decidable? For propositional logic it is, but for first-order logic and higher it is not.

### _q = 2_

* [**nth-order logic**](https://en.wikipedia.org/wiki/Higher-order_logic): Does there exist a sound and complete proof system for _n_​th-order logic? Is the logic compact? For propositional and first-order logic, the answer to both of these is yes, while for second-order and higher-order logics, it is no.

### _q = 3_

* [**Rank-k polymorphism**](https://en.wikipedia.org/wiki/Parametric_polymorphism#Higher-ranked_polymorphism): In a polymorphic type system where forall quantifiers are restricted to no more than _k_ arrows deep on the left (i.e. `((forall a. a -> t_1) ... -> t_k)`), is type inference decidable? For rank-0 (simple types), rank-1 (prenex or Hindley-Milner), or rank-2, type inference is decidable, but for rank-3 and higher, it is not.

* [**n-body problem**](https://en.wikipedia.org/wiki/N-body_problem): Given the initial positions and velocities of _n_ bodies mutually subject to an inverse-square central force law, can their paths be expressed as a closed-form expression? For the 1-body problem (trivial) and 2-body problem (e.g. the Kepler problem), they can, but not for the 3-body problem or higher.

There are many problems whose complexity is NP-complete only for _q = 3_ or possibly higher. Here are three classical problems that are usually encountered. I won't list any more simply because there are far too many of their kind.

* [**n-SAT**](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem): Given a formula in conjunctive normal form where each clause has _n_ literals, is there an assignment of truth values to its variables such that the formula is satisfied? 1-SAT and 2-SAT are in P, while 3-SAT and higher are NP-complete.
* [**n-dimensional matching**](https://en.wikipedia.org/wiki/3-dimensional_matching): Given a natural number _k_, _n_ finite disjoint sets, and a subset _T_ of their Cartesian product, is there a subset _M_ of _T_ such that _\|M\| > k_ and the elements of the tuples of _M_ are disjoint? 1D matching (trivial) and 2D matching (bipartite matching) are in P, while 3-SAT and higher are NP-complete.
* [**Graph k-colouring**](https://en.wikipedia.org/wiki/Graph_coloring): Given a graph, is there a way to assign each node one of _k_ colours such that no two nodes of the same colour share an edge? 1-colouring (trivial) and 2-colouring are in P, while 3-colouring is in NP. Interestingly, for [4-colouring](https://en.wikipedia.org/wiki/Four_color_theorem) the answer is always yes.

### _q = 4_

* [**Stable orbits in n dimensions**](https://en.wikipedia.org/wiki/Anthropic_principle#Dimensions_of_spacetime): Are 2-body orbits due to an inverse-square central force law stable in _n_ dimensions? In 2 and 3 dimensions, yes; in 4 or more dimensions, no.

### _q = 5_

The following two are closely related (and the first is usually proven using the second).

* [**Roots of n-degree polynomials**](https://en.wikipedia.org/wiki/Abel%E2%80%93Ruffini_theorem): Is there a general algebraic solution for the roots of an n-degree polynomial? For polynomials of degree four or less there is, but for degree five or higher there is not.

* [**Alternating groups of degree n**](https://en.wikipedia.org/wiki/Alternating_group): Is _A(n)_ solvable? _A(2), A(3), A(4)_ are abelian, so they are solvable, while A(5) and higher are not.