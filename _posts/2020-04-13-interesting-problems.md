---
layout: post
title: "Interesting Problems are Small Problems"
excerpt_separator: "<!--more-->"
tags:
  - mathematics
  - computational complexity
  - physics
  - logic
---

This post is based on the observation that, in a variety of fields (e.g. mathematics, logic, computation, physics), while certain classes of problems can be parameterized by some natural number _n_, it appears that the interesting problems―not so simple as to be trivial, but not so complex as to be unsolvable, undecidable, intractable, or nonexistent―always occur at small _n_. Below is a collection of such problems, describing at which _n_ they are interesting, and how so.

<!--more-->

### A Summary

* First-order predicate logic
* Rank-1, rank-2 polymorphic lambda calculus
* System F₃
* 3-SAT, 3D matching, graph 3-colouring
* (Semi)regular polytopes in 3D and 4D
* 2-body problem
* Stable bound orbits in 2D and 3D

## Logic

[Higher-order logic](https://en.wikipedia.org/wiki/Higher-order_logic) can be stratified into _n_​th-order logics, beginning with propositional logic (_n = 0_), first-order logic, second-order logic, and so on. As opposed to propositional logic, first-order logic can simulate computation (either by encoding a Turing machine as a formula or by representing recursive functions in a sufficiently rich arithmetic theory), and is therefore undecidable. However, FOL is both compact and admits a sound and complete finitary proof system, whereas second-order and higher-order logics do not. Therefore, FOL is interesting by being sufficiently complex while still well-behaved.

## Polymorphic Lambda Calculus

The polymorphic lambda calculus System F can be stratified into systems of [rank-_k_ polymorphism](https://en.wikipedia.org/wiki/Parametric_polymorphism#Higher-ranked_polymorphism), where forall quantifiers are restricted to no more than _k_ arrows deep on the left (e.g. `((forall a. a -> t_1) ... -> t_k)`). Beyond rank-1 (prenex or Hindley–Milner) and rank-2 polymorphism, type inference and type checking is undecidable [1], which makes these interesting in terms of practicality. Rank-0 polymorphism is essentially STLC (i.e. nonpolymorphic), where type inference and type checking are trivially decidable.

The higher-order polymorphic lambda calculus [System F<sub>ω</sub>](https://en.wikipedia.org/wiki/System_F#System_Fω) can be stratified into levels as well, where System F₁ corresponds to STLC, System F₂ corresponds to System F above, and System Fₖ allows type constructors with argument types of kind level _(k-1)_. While there exist (Curry-style) lambda terms that cannot be typed in F₂ but can be typed in F₃ and above [2, 3], it is conjectured [4, 5] that all terms typeable in F₃ and above are also typeable in F₃ itself; there is a supposedly incorrect proof of this [6]. This is not to say System F₃ and above are uninteresting because they are too complex; in fact, it is interesting precisely because higher orders of polymorphism may collapse to F₃. This is similar to NP-complete problems below, where classes of problems parametrized by _n_ are all NP-complete for _n ⩾ 3_.

## Computational Complexity

There are many decision problems parametrized by _n_ whose complexity is NP-complete only for _n = 3_ or possibly higher. Here are three classical problems that are usually encountered. I won't list any more simply because there are far too many of their kind.

* [**n-SAT**](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem): Given a formula in conjunctive normal form where each clause has _n_ literals, is there an assignment of truth values to its variables such that the formula is satisfied? In 0-SAT, the answer is trivially yes; 1-SAT and 2-SAT are in P, while 3-SAT and higher are NP-complete.

* [**n-dimensional matching**](https://en.wikipedia.org/wiki/3-dimensional_matching): Given a natural number _k_, _n_ finite disjoint sets, and a subset _T_ of their Cartesian product, is there a subset _M_ of _T_ such that _\|M\| > k_ and the elements of the tuples of _M_ are disjoint? 1D matching is trivial and 2D matching (bipartite matching) is in P, while 3-SAT and higher are NP-complete.

* [**Graph k-colouring**](https://en.wikipedia.org/wiki/Graph_coloring): Given a graph, is there a way to assign each node one of _k_ colours such that no two nodes of the same colour share an edge? 1-colouring is trivial and 2-colouring is in P, while 3-colouring is in NP. Interestingly, for [4-colouring](https://en.wikipedia.org/wiki/Four_color_theorem) the answer is always yes.

## Geometry

In mathematics, there appear to be many interesting structures in four-dimensional space. This is a vastly incomplete list; there are, as far as I know, some unique properties of 4D space to do with n-spheres as well.

In _n_ dimensions, there exist at least the following [regular polytopes](https://en.wikipedia.org/wiki/Regular_polytope): the simplices, (with _(n + 1)_ faces of _(n - 1)_-dimensional simplices), the quadruplices (with _2n_ faces of _(n - 1)_-dimensional quadruplices), and the orthoplices (with _2ⁿ_ faces of _(n - 1)_-dimensional simplices). In 0D and 1D, these all collpase to the trivial point and line, respectively. In 2D, there are infinitely many regular convex and star polytopes (polygons and stars). For dimensions greater than 4, there are no other regular polytopes. However, in 3D and 4D, there exist other regular polytopes than the three categories above. In 3D, the convex polyhedra are the icosahedron and the dodecahedron, and the star polyhedra are Kepler–Poinsot polyhedra. In 4D, the convex polychora are the 120-cell (corresponding to the dodecahedron), the 600-cell (corresponding to the icosahedron), and the 24-cell (with no 3D counterpart), while the star ones are Schläfli–Hess polychora.

Similarly, in _n_ dimensions, there exist at least the following [semiregular polytopes](https://en.wikipedia.org/wiki/Semiregular_polytope): the [_k₂₁_ polytopes](https://en.wikipedia.org/wiki/Uniform_k_21_polytope), and the regular polytopes as described above. In 0D, 1D, and 2D, the semiregular polytopes are exactly the regular polytopes. For dimensions greater than 4, there are no other semiregular polytopes. However, in 3D and 4D, there exist other regular polytopes than the _k₂₁_ polytopes. In 3D, these are the prisms, the antiprisms, and the 13 Archimedean solids (excluding enantiomorphs). In 4D, these are the rectified 600-cell (analogous to the icosidodecahedron) and the snub 24-cell.

## Physics

There are a few observations that point out the uniqueness of three spatial dimensions (and possibly two as well), usually as arguments for the [anthropic principle](https://en.wikipedia.org/wiki/Anthropic_principle#Dimensions_of_spacetime).

In three dimensions, the gravitation potential is propotional to _1/r_ (see below). The [_n_-body problem](https://en.wikipedia.org/wiki/N-body_problem) asks for a general closed-form solution to the paths of _n_ bodies mutually attracted by the gravitational forces due to this potential. A general solution exists only for 2 bodies; with 3 or more bodies, no general solutions exist, although there are many special periodic cases.

### Gravitation and Electromagnetism

Given a potential field described by Poisson's equation, the fundamental solution in _d_ dimensions is a potential propotional to _1/r<sup>d - 2</sup>_ (or to _ln(r)_ for _d = 2_), where _r_ is the distance from the source. This potential applies to Newtonian gravitation and classical electrodynamics. In only _d = 2_ and _d = 3_, there exist stable bound orbits (circular or elliptical); the concept of an orbit is undefined in fewer dimensions. The original result by Ehrenfest [7] (and reëxpressed by Freeman [8] in English) showed that bound planetary orbits and the Bohr model are not stable for _d > 3_.

This has been generalized by Tangherlini [9] to a Schwarzschild field (due to a nonrotating, uncharged mass), with the result that stable bound orbits still do not exist in _d > 3_. Since the Schwarzschild metric is a special case of other metrics (Kerr, for rotating masses; Reissner–Nördstrom, for charged masses; Kerr–Newman, for rotating, charged masses), it is not expected that these will have stable bound orbits in _d > 3_ either. There probably are papers that deal with them explicitly.

On the other hand, it was shown [10] that bound states of a single electron in a _1/r<sup>d - 2</sup>_ potential using the Schrödinger equation do exist for _d > 4_. As relativistic effects are usually small corrections, it would be expected that special relativistic equations (e.g. Dirac, Klein–Goron, Proca) would also yield the same results. But then we would delve into the world of quantum field theory and have to consider the strong force, the weak force, and Lagrangians, which is beyond the scope of this post. As a subaside, Tegmark [11] argues for the impossiblity of more or less than one _time_ dimension.

<hr>

[1] Kfoury, A. J. and Tiuryn, J. Type Reconstruction in Finite Rank Fragments of the Second-Order λ-Calculus. (1992). Information and Computation, 98:2, pp. 228-257. [https://doi.org/10.1016/0890-5401(92)90020-G](https://doi.org/10.1016/0890-5401(92)90020-G).

[2] [https://www.cis.upenn.edu/~bcpierce/types/archives/1993/msg00026.html](https://www.cis.upenn.edu/~bcpierce/types/archives/1993/msg00026.html)

[3] Giannini, P. and Della Rocca, S.R. Characterization of typings in polymorphic type discipline. (1988). Third Annual Symposium on Logic in Computer Science, pp. 61-70. [https://doi.org/10.1109/LICS.1988.5101](https://doi.org/10.1109/LICS.1988.5101).

[4] [https://www.seas.upenn.edu/~sweirich/types/archive/1991/msg00054.html](https://www.seas.upenn.edu/~sweirich/types/archive/1991/msg00054.html).

[5] Giannini, P., Honsell, F., and Ronchi Della Rocca, S. (1993). Type Inference: Some results, Some problems. Fondamenta Informaticae, 19:1-2, pp. 87–125. [https://dl.acm.org/doi/abs/10.5555/175469.175472](https://dl.acm.org/doi/abs/10.5555/175469.175472).

[6] Malecki, S. (1997). Proofs in system Fω can be done in system Fω1. International Workshop on Computer Science Logic, pp. 297-315. [https://doi.org/10.1007/3-540-63172-0_46](https://doi.org/10.1007/3-540-63172-0_46).

[7] Ehrenfest, Paul. (1920). Welche Rolle spielt die Dreidimensionalität des Raumes in den Grundgesetzen der Physik?. Ann. Phys., 366:, pp. 440-446. [http://doi.org/10.1002/andp.19203660503](http://doi.org/10.1002/andp.19203660503).

[8] Freeman, Ira M. (1969). Why is Space Three-Dimensional?. American Journal of Physics, 37:12, 1222-1224. [https://doi.org/10.1119/1.1975283](https://doi.org/10.1119/1.1975283).

[9] Tangherlini, F. R. (1963). Schwarzschild field inn dimensions and the dimensionality of space problem. Nuovo Cim, 27:3, pp. 636–651. [https://doi.org/10.1007/BF02784569](https://doi.org/10.1007/BF02784569).

[10] Caruso, F., Martins, J., and Oguri, V. (2013). On the existence of hydrogen atoms in higher dimensional Euclidean spaces. Physics Letters A, 377:9, pp. 694–698. [http://dx.doi.org/10.1016/j.physleta.2013.01.026](http://dx.doi.org/10.1016/j.physleta.2013.01.026).

[11] Tegmark, Max. (1997). On the dimensionality of spacetime. Classical and Quantum Gravity, 14:4, pp. L69–L75. [http://dx.doi.org/10.1088/0264-9381/14/4/002](http://dx.doi.org/10.1088/0264-9381/14/4/002).
