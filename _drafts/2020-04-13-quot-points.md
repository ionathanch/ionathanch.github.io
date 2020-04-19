---
layout: post
title: "Mathematically, Things Get Hard Real Quick"
excerpt_separator: "<!--more-->"
tags:
  - numbers
  - mathematics
  - computational complexity
  - physics
---

This post is based on the observation that, in many areas of mathematics (if we take computational theory to be a subset thereof), classes of problems start to get hard at curiously small numbers. <!--more--> Somewhat more formally,

> Given a class of decision problems _P_ parameterized by some natural number _n_, for some definition of "difficulty" (e.g. complexity, undecidability, nonexistence), if there is some number _q_ such that _P(q)_ is difficult but _P(q')_ for all q' < q is not, then _q_ is "small".

The definition of "difficulty" is intentionally vague, since the concept differs among different fields, and many not be rigourously defined for others. The definition of "small" is up to taste, but from what I have found so far, it seems that _q ⩽ 7_. I'm calling the values of _q_ the _quot points_ of these problems, because "quot" is Latin for "how many?", as well as being the noise one sputters when encountering a difficult problem. It also evokes the sense of "quotient", in that quot points divide problems into the difficult and the non-difficult. If a problem has quot point _q_, then it can be said to be a _q_-quot problem. Below are various quot points _q_ with some _q_-quot problems.

### _q = 1_

* [**nth-order logic**](https://en.wikipedia.org/wiki/Higher-order_logic): Is the validity of an arbitrary _n_​th-order logic formula decidable? For propositional logic it is, but for first-order logic and higher it is not.

### _q = 2_

* [**nth-order logic**](https://en.wikipedia.org/wiki/Higher-order_logic): Does there exist a sound and complete proof system for _n_​th-order logic? Is the logic compact? For propositional and first-order logic, the answer to both of these is yes, while for second-order and higher-order logics, it is no.

* [**nth-order polymorphism**](https://en.wikipedia.org/wiki/System_F#System_F.CF.89): In a Curry-style _n_​th-order polymorphic lambda calculus where the argument types of type-level functions are at most _(n-1)_​th-order, is type inference and type checking decidable? For 1st-order (simply-typed lambda calculus) it is, but for 2nd-order (System F) and higher (fragments of System F<sub>ω</sub>, or System F with various levels of type operators) it is not.

* [**General relativistic n-body problem**](https://en.wikipedia.org/wiki/Two-body_problem_in_general_relativity#Beyond_the_Schwarzschild_solution): Given the initial positions and velocities of _n_ bodies in the Schwarzschild metric, can their paths be expressed as closed-form expressions? For the 0-body and 1-body problems (trivial), they can, but not for the 2-body problem (in the general case of comparable masses) or more.

### _q = 3_

* [**Rank-k polymorphism**](https://en.wikipedia.org/wiki/Parametric_polymorphism#Higher-ranked_polymorphism): In a Curry-style polymorphic lambda calculus where forall quantifiers are restricted to no more than _k_ arrows deep on the left (i.e. `((forall a. a -> t_1) ... -> t_k)`), is type inference decidable? For rank-0 (simple types), rank-1 (prenex or Hindley-Milner), or rank-2, type inference is decidable, but for rank-3 and higher, it is not.

* [**Classical Newtonian n-body problem**](https://en.wikipedia.org/wiki/N-body_problem): Given the initial positions and velocities of _n_ bodies mutually subject to an inverse-square central force law, can their paths be expressed as closed-form expressions? For the 0-body, 1-body (both trivial), and 2-body problems (e.g. the Kepler problem), they can, but not for the 3-body problem or more.

There are many problems whose complexity is NP-complete only for _q = 3_ or possibly higher. Here are three classical problems that are usually encountered. I won't list any more simply because there are far too many of their kind.

* [**n-SAT**](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem): Given a formula in conjunctive normal form where each clause has _n_ literals, is there an assignment of truth values to its variables such that the formula is satisfied? 1-SAT and 2-SAT are in P, while 3-SAT and higher are NP-complete.

* [**n-dimensional matching**](https://en.wikipedia.org/wiki/3-dimensional_matching): Given a natural number _k_, _n_ finite disjoint sets, and a subset _T_ of their Cartesian product, is there a subset _M_ of _T_ such that _\|M\| > k_ and the elements of the tuples of _M_ are disjoint? 1D matching (trivial) and 2D matching (bipartite matching) are in P, while 3-SAT and higher are NP-complete.

* [**Graph k-colouring**](https://en.wikipedia.org/wiki/Graph_coloring): Given a graph, is there a way to assign each node one of _k_ colours such that no two nodes of the same colour share an edge? 1-colouring (trivial) and 2-colouring are in P, while 3-colouring is in NP. Interestingly, for [4-colouring](https://en.wikipedia.org/wiki/Four_color_theorem) the answer is always yes.

### _q = 4_

* [**Gravitational orbits in d dimensions**](https://en.wikipedia.org/wiki/Anthropic_principle#Dimensions_of_spacetime)<sup>*</sup>: Do stable bound gravitational orbits exist in _d_ dimensions? In 2 and 3 dimensions, the answer is yes; in 4 or more dimensions, the answer is no. (For 0 and 1 dimensions, the concept of an "orbit" is undefined.)

### _q = 5_

The following two are closely related (and the first is usually proven using the second).

* [**Roots of n-degree polynomials**](https://en.wikipedia.org/wiki/Abel%E2%80%93Ruffini_theorem): Is there a general algebraic solution for the roots of an n-degree polynomial? For polynomials of degree four or less there is, but for degree five or higher there is not.

* [**Alternating groups of degree n**](https://en.wikipedia.org/wiki/Alternating_group): Is _A(n)_ solvable? _A(2), A(3), A(4)_ are abelian, so they are solvable, while A(5) and higher are not.

## Things Also Become Simpler Real Quick

There are also certain problems that are hard only for small numbers. That is, the claim is that

> Given a class of decision problems _P_ parameterized by some natural number _n_, for some definition of "difficulty" (e.g. complexity, undecidability, nonexistence), if there is some number _t_ such that for all 0 ⩽ n ⩽ t, _P(n)_ is difficult but for all n' > t, _P(n')_ is not, then _t_ is "small".

These follow the same principle in regards to "difficulty" and "small". Analogously, these will be called _touq points_, and below are _t-touq_ problems.

### _t = 4_

* [**Regular polytopes**](https://en.wikipedia.org/wiki/Regular_polytope): Do there exist regular polytopes in _n_ dimensions beyond the simplices, (with _(n + 1)_ faces of _(n - 1)_-dimensional simplices), the quadruplices (with _2n_ faces of _(n - 1)_-dimensional quadruplices), and the orthoplices (with _2ⁿ_ faces of _(n - 1)_-dimensional simplices)? For dimensions greater than 4, the answer is no. For _n = 4_, the convex ones are the 120-cell, the 600-cell, and the 24-cell, and the star ones are Schläfli–Hess polychora. For _n = 3_, the convex ones are the icosahedron and the dodecahedron, and the star ones are Kepler–Poinsot polyhedra. For _n = 2_, there are infinitely many (star) polygons. The problem is ill-defined for lower dimensions, as the line and the point could be said to be either the only 1-dimensional and 0-dimensional (star) polytopes, or to be generalizations of the infinitely-many 2-dimensional polygons. The same sort of coincidence occurs in 2 dimensions, where a square is both a 2-quadruplex and a 2-orthoplex.

* [**Semiregular polytopes**](https://en.wikipedia.org/wiki/Semiregular_polytope): Do there exist semiregular polytops in _n_ dimensions beyond the [_k₂₁_ polytopes](https://en.wikipedia.org/wiki/Uniform_k_21_polytope)? For dimensions greater than 4, the answer is no. For _n = 4_, these are the rectified 600-cell and the snub 24-cell. For _n = 3_, these are the prisms, the antiprisms, the Archimedean solids, and the Platonic solids. For lower dimensions, the semiregular polytopes are exactly the regular polytopes.

<br>

## <sup>*</sup>An Aside on Gravitation and Electromagnetism in Higher Dimensions

The original result by Ehrenfest [1] (and reëxpressed by Freeman [2] in English) uses Poisson's equation to derive a potential proportional to _1/r<sup>d - 2</sup>_ (or to _ln(r)_ for _d = 2_), giving rise to higher-dimensional analogues of Newtownian gravitation and Coulomb's law. It was shown that bound orbits and the Bohr model are not stable for _d > 3_.

This has been generalized by Tangherlini [3] to a Schwarzschild field (due to a nonrotating, uncharged mass), with the result that stable bound orbits still do not exist in _d > 3_. Since the Schwarzschild metric is a special case of other metrics (Kerr, for rotating masses; Reissner–Nördstrom, for charged masses; Kerr–Newman, for rotating, charged masses), it is not expected that these will have stable bound orbits in _d > 3_ either. There probably are papers that deal with them explicitly.

On the other hand, it was shown [4] that bound states of a single electron in a _1/r<sup>d - 2</sup>_ potential using the Schrödinger equation do exist for _d > 4_. As relativistic effects are usually small corrections, it would be expected that special relativistic equations (e.g. Dirac, Klein–Goron, Proca) would also yield the same results. But then we would delve into the world of quantum field theory and have to consider the strong force, the weak force, and Lagrangians, which is beyond the scope of this aside. As a subaside, Tegmark [5] argues for the impossiblity of more or less than one _time_ dimension.

<hr>

[1] Ehrenfest, Paul. (1920). Welche Rolle spielt die Dreidimensionalität des Raumes in den Grundgesetzen der Physik?. Ann. Phys., 366:, 440-446. [http://doi.org/10.1002/andp.19203660503](http://doi.org/10.1002/andp.19203660503).

[2] Freeman, Ira M. (1969). Why is Space Three-Dimensional?. American Journal of Physics, 37:12, 1222-1224. [https://doi.org/10.1119/1.1975283](https://doi.org/10.1119/1.1975283).

[3] Tangherlini, F. R. Schwarzschild field inn dimensions and the dimensionality of space problem. Nuovo Cim, 27:3 636–651 (1963). [https://doi.org/10.1007/BF02784569](https://doi.org/10.1007/BF02784569).

[4] Caruso, F., Martins, J., and Oguri, V. (2013). On the existence of hydrogen atoms in higher dimensional Euclidean spaces. Physics Letters A, 377:9, 694–698. [http://dx.doi.org/10.1016/j.physleta.2013.01.026](http://dx.doi.org/10.1016/j.physleta.2013.01.026).

[5] Tegmark, Max. (1997). On the dimensionality of spacetime. Classical and Quantum Gravity, 14:4, L69–L75. [http://dx.doi.org/10.1088/0264-9381/14/4/002](http://dx.doi.org/10.1088/0264-9381/14/4/002).