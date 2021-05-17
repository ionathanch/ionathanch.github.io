---
layout: post
title: "Interesting Problems at Small Values"
katex: true
tags:
  - mathematics
  - topology
  - computational complexity
  - computics
  - physics
  - logic
---

<!-- { % katexmm % } -->

This post is based on the observation that, in a variety of fields (e.g. logic, computics, mathematics, physics), while certain classes of problems can be parameterized by some natural number $n$, it appears that the interesting problems―not so simple as to be trivial, but not so complex as to be unsolvable, undecidable, intractable, or nonexistent―always occur at small $n$. Below is a collection of such problems, describing at which $n$ they are interesting, and how so.

<!--more-->

### A Summary

* First-order predicate logic
* Rank-1, rank-2 polymorphic lambda calculus
* System F$$_{_3}$$
* 3-SAT, 3D matching, graph 3-colouring
* (Semi)regular polytopes in 3D and 4D
* Exotic $\mathbb{R}^4$ and exotic 4-spheres
* 2-body problem
* Stable bound orbits in 2D and 3D

## Logic

[Higher-order logic](https://en.wikipedia.org/wiki/Higher-order_logic) can be stratified into $n$​th-order logics, beginning with propositional logic $(n = 0)$, first-order logic, second-order logic, and so on. As opposed to propositional logic, first-order logic can simulate computation (either by encoding a Turing machine as a formula or by representing recursive functions in a sufficiently rich arithmetic theory), and is therefore undecidable. However, FOL is both compact and admits a sound and complete finitary proof system, whereas second-order and higher-order logics do not. Therefore, FOL is interesting by being sufficiently complex while still well-behaved.

## Computics

### Polymorphic Lambda Calculus

The polymorphic lambda calculus System F can be stratified into systems of [rank-​$k$ polymorphism](https://en.wikipedia.org/wiki/Parametric_polymorphism#Higher-ranked_polymorphism), where forall quantifiers are restricted to no more than $k$ arrows deep on the left (e.g. `((∀ a. a → t1) ... → tk)`). Beyond rank-1 (prenex or Hindley–Milner) and rank-2 polymorphism, type inference and type checking is undecidable [[1](#1)], which makes these interesting in terms of practicality. Rank-0 polymorphism is essentially STLC (i.e. nonpolymorphic), where type inference and type checking are trivially decidable.

The higher-order polymorphic lambda calculus [System F$$_{\omega}$$](https://en.wikipedia.org/wiki/System_F#System_Fω) can be stratified into levels as well, where System F$_{_1}$ corresponds to STLC, System F$$_{_2}$$ corresponds to System F above, and System F$$_{_k}$$ allows type constructors with argument types of kind level $(k - 1)$. While there exist (Curry-style) lambda terms that cannot be typed in F$$_{_2}$$ but can be typed in F$$_{_3}$$ and above [[2](#2), [3](#3)], it is conjectured [[4](#4), [5](#5)] that all terms typeable in F$$_{_3}$$ and above are also typeable in F$$_{_3}$$ itself; there is a supposedly incorrect proof of this [[6](#6)]. This is not to say System F$$_{_3}$$ and above are uninteresting because they are too complex; in fact, it is interesting precisely because higher orders of polymorphism may collapse to F$$_{_3}$$. This is similar to NP-complete problems below, where classes of problems parametrized by $n$ are all NP-complete for $n \geq 3$.

### Computational Complexity

There are many decision problems parametrized by $n$ whose complexity is NP-complete only for $n=3$ or possibly higher. Here are three classical problems that are usually encountered. I won't list any more simply because there are far too many of their kind.

* [**n-SAT**](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem): Given a formula in conjunctive normal form where each clause has $n$ literals, is there an assignment of truth values to its variables such that the formula is satisfied? In 0-SAT, the answer is trivially yes; 1-SAT and 2-SAT are in P, while 3-SAT and higher are NP-complete.

* [**n-dimensional matching**](https://en.wikipedia.org/wiki/3-dimensional_matching): Given a natural number $k$, $n$ finite disjoint sets, and a subset $T$ of their Cartesian product, is there a subset $M$ of $T$ such that $\|M\| > k$ and the elements of the tuples of $M$ are disjoint? 1D matching is trivial and 2D matching (bipartite matching) is in P, while 3-SAT and higher are NP-complete.

* [**Graph k-colouring**](https://en.wikipedia.org/wiki/Graph_coloring): Given a graph, is there a way to assign each node one of $k$ colours such that no two nodes of the same colour share an edge? 1-colouring is trivial and 2-colouring is in P, while 3-colouring is in NP. Interestingly, for [4-colouring](https://en.wikipedia.org/wiki/Four_color_theorem) the answer is always yes.

## Mathematics

In mathematics, there appear to be many interesting structures in four-dimensional space. This is a vastly incomplete list; there are, as far as I know, some unique properties of 4D space to do with n-spheres as well.

### Geometry

In $n$ dimensions, there exist at least the following [regular polytopes](https://en.wikipedia.org/wiki/Regular_polytope): the simplices, (with $(n+1)$ faces of $(n-1)$-dimensional simplices), the quadruplices (with $2n$ faces of $(n-1)$-dimensional quadruplices), and the orthoplices (with $2^n$ faces of $(n-1)$-dimensional simplices). In 0D and 1D, these all collpase to the trivial point and line, respectively. In 2D, there are infinitely many regular convex and star polytopes (polygons and stars). For dimensions greater than 4, there are no other regular polytopes. However, in 3D and 4D, there exist other regular polytopes than the three categories above. In 3D, the convex polyhedra are the icosahedron and the dodecahedron, and the star polyhedra are Kepler–Poinsot polyhedra. In 4D, the convex polychora are the 120-cell (corresponding to the dodecahedron), the 600-cell (corresponding to the icosahedron), and the 24-cell (with no 3D counterpart), while the star ones are Schläfli–Hess polychora.

Similarly, in $n$ dimensions, there exist at least the following [semiregular polytopes](https://en.wikipedia.org/wiki/Semiregular_polytope): the [$$k_{_{21}}$$ polytopes](https://en.wikipedia.org/wiki/Uniform_k_21_polytope), and the regular polytopes as described above. In 0D, 1D, and 2D, the semiregular polytopes are exactly the regular polytopes. For dimensions greater than 4, there are no other semiregular polytopes. However, in 3D and 4D, there exist other regular polytopes than the $$k_{_{21}}$$ polytopes. In 3D, these are the prisms, the antiprisms, and the 13 Archimedean solids (excluding enantiomorphs). In 4D, these are the rectified 600-cell (analogous to the icosidodecahedron) and the snub 24-cell.

### Topology

Exotic smooth structures on $\mathbb{R}^n$ are smooth topological manifolds that are homeomorphic but not diffeomorphic to $\mathbb{R}^n$. It was shown by Stallings [[7](#7)] that no such structures exist for $n \neq 4$, while it was shown by Taubes [[8](#8)] that uncountably many exist for $n = 4$. Similarly, exotic piecewise-linear structures on the $n$-sphere are not PL-homeomorphic to the $n$-sphere. The [generalized PL Poincaré conjecture](https://en.wikipedia.org/wiki/Generalized_Poincar%C3%A9_conjecture) states that there are no such structures; this holds true for $n \neq 4$, but it is yet unknown whether this holds for $n = 4$ (see [[9](#9)]).

## Physics

There are a few observations that point out the uniqueness of three spatial dimensions (and possibly two as well), usually as arguments for the [anthropic principle](https://en.wikipedia.org/wiki/Anthropic_principle#Dimensions_of_spacetime).

In three dimensions, the gravitation potential is propotional to $\frac{1}{4}$ (see below). The [$n$-body problem](https://en.wikipedia.org/wiki/N-body_problem) asks for a general closed-form solution to the paths of $n$ bodies mutually attracted by the gravitational forces due to this potential. A general solution exists only for 2 bodies; with 3 or more bodies, no general solutions exist, although there are many special periodic cases.

### Gravitation and Electromagnetism

Given a potential field described by Poisson's equation, the fundamental solution in $d$ dimensions is a potential propotional to $\frac{1}{r^{d-2}}$ (or to $\ln(r)$ for $d = 2$), where $r$ is the distance from the source. This potential applies to Newtonian gravitation and classical electrodynamics. In only $d = 2$ and $d = 3$, there exist stable bound orbits (circular or elliptical); the concept of an orbit is undefined in fewer dimensions. The original result by Ehrenfest [[10](#10)] (and reëxpressed by Freeman [[11](#11)] in English) showed that bound planetary orbits and the Bohr model are not stable for $d > 3$.

This has been generalized by Tangherlini [[12](#12)] to a Schwarzschild field (due to a nonrotating, uncharged mass), with the result that stable bound orbits still do not exist in $d > 3$. Since the Schwarzschild metric is a special case of other metrics (Kerr, for rotating masses; Reissner–Nördstrom, for charged masses; Kerr–Newman, for rotating, charged masses), it is not expected that these will have stable bound orbits in $d > 3$ either. There probably are papers that deal with them explicitly.

On the other hand, it was shown [[13](#13)] that bound states of a single electron in a $\frac{1}{r^{d-2}}$ potential using the Schrödinger equation do exist for $d > 4$. As relativistic effects are usually small corrections, it would be expected that special relativistic equations (e.g. Dirac, Klein–Goron, Proca) would also yield the same results. But then we would delve into the world of quantum field theory and have to consider the strong force, the weak force, and Lagrangians, which is beyond the scope of this post. As a subaside, Tegmark [[14](#14)] argues for the impossiblity of more or less than one _time_ dimension.

<!-- { % endkatexmm % } -->

<hr>

[<a name="1">1</a>] Kfoury, A. J. and Tiuryn, J. "Type Reconstruction in Finite Rank Fragments of the Second-Order λ-Calculus". (1992). _Information and Computation_, 98:2, pp. 228–257. [https://doi.org/10.1016/0890-5401(92)90020-G](https://doi.org/10.1016/0890-5401(92)90020-G){:target="_blank"}.

[<a name="2">2</a>] [https://www.cis.upenn.edu/~bcpierce/types/archives/1993/msg00026.html](https://www.cis.upenn.edu/~bcpierce/types/archives/1993/msg00026.html){:target="_blank"}.

[<a name="3">3</a>] Giannini, P. and Della Rocca, S.R. "Characterization of typings in polymorphic type discipline". (1988). _Third Annual Symposium on Logic in Computer Science_, pp. 61–70. [https://doi.org/10.1109/LICS.1988.5101](https://doi.org/10.1109/LICS.1988.5101){:target="_blank"}.

[<a name="4">4</a>] [https://www.seas.upenn.edu/~sweirich/types/archive/1991/msg00054.html](https://www.seas.upenn.edu/~sweirich/types/archive/1991/msg00054.html){:target="_blank"}.

[<a name="5">5</a>] Giannini, P., Honsell, F., and Ronchi Della Rocca, S. (1993). "Type Inference: Some results, Some problems". _Fondamenta Informaticae_, 19:1–2, pp. 87–125. [https://dl.acm.org/doi/abs/10.5555/175469.175472](https://dl.acm.org/doi/abs/10.5555/175469.175472){:target="_blank"}.

[<a name="6">6</a>] Malecki, S. (1997). "Proofs in system Fω can be done in system Fω1". _International Workshop on Computer Science Logic_, pp. 297–315. [https://doi.org/10.1007/3-540-63172-0_46](https://doi.org/10.1007/3-540-63172-0_46){:target="_blank"}.

[<a name="7">7</a>] Stallings, J. (1961). "The Piecewise-Linear Structure of Euclidean Space". _Proceedings of the Cambridge Philosophical Society_, 58:, pp. 481–488. [https://doi.org/10.1017/s0305004100036756](https://doi.org/10.1017/s0305004100036756){:target="_blank"}.

[<a name="8">8</a>] Taubes, C. H. (1987). "Gauge Theory on Asymptotically Periodic 4-Manifolds". _Journal of Differential Geometry_, 25:3, pp. 363–430. [https://doi.org/10.4310/jdg/1214440981](https://doi.org/10.4310/jdg/1214440981){:target="_blank"}.

[<a name="9">9</a>] Freedman, M., Gompf, R., Morrison, S., Walker, K. (2010). "Man and Machine Thinking about the Smooth 4-Dimensional Poincaré Conjecture". _Quantum Topology_, 1:2, pp. 171–208. [https://doi.org/10.4171/qt/5](https://doi.org/10.4171/qt/5){:target="_blank"}.

[<a name="10">10</a>] Ehrenfest, Paul. (1920). "Welche Rolle spielt die Dreidimensionalität des Raumes in den Grundgesetzen der Physik?". _Ann. Phys._, 366:, pp. 440–446. [http://doi.org/10.1002/andp.19203660503](http://doi.org/10.1002/andp.19203660503){:target="_blank"}.

[<a name="11">11</a>] Freeman, Ira M. (1969). "Why is Space Three-Dimensional?". _American Journal of Physics_, 37:12, 1222–1224. [https://doi.org/10.1119/1.1975283](https://doi.org/10.1119/1.1975283){:target="_blank"}.

[<a name="12">12</a>] Tangherlini, F. R. (1963). "Schwarzschild field inn dimensions and the dimensionality of space problem". _Nuovo Cim_, 27:3, pp. 636–651. [https://doi.org/10.1007/BF02784569](https://doi.org/10.1007/BF02784569){:target="_blank"}.

[<a name="13">13</a>] Caruso, F., Martins, J., and Oguri, V. (2013). "On the existence of hydrogen atoms in higher dimensional Euclidean spaces". _Physics Letters A_, 377:9, pp. 694–698. [http://dx.doi.org/10.1016/j.physleta.2013.01.026](http://dx.doi.org/10.1016/j.physleta.2013.01.026){:target="_blank"}.

[<a name="14">14</a>] Tegmark, Max. (1997). "On the dimensionality of spacetime". _Classical and Quantum Gravity_, 14:4, pp. L69–L75. [http://dx.doi.org/10.1088/0264-9381/14/4/002](http://dx.doi.org/10.1088/0264-9381/14/4/002){:target="_blank"}.
