---
layout: post
title: "The State of Sized Types"
excerpt_separator: "<!--more-->"
tags:
  - sized types
  - type theory
---

Sized types hold great potential as a very practically useful way to do type-based termination checking,
but sufficiently expressive sized types in dependent type theory come with a host of problems,
mostly related to its incompatibility with the infinite size found in most simpler or nondependent type systems.
This post attempts to describe some potential but ultimately unsatisfying solutions.

<!--more-->

# The Latest and Greatest in Sized Types

_If you're already familiar with sized types, in particular the kind that Agda has,
you can skip to the [next section](#infernal-infinity).
However, I do introduce my own syntax for sized types here._

Sized types are all about type-based termination checking:
if a program is well-typed, then we can be sure that its execution will terminate.
Practically speaking, information about the relative difference in syntatic size
of an inductive construction is stored in the type of the inductive.
Using the classic example of the naturals, we can augment its inductive definition with sizes.

```
data Nat : Set where
  zero : Nat
  succ : Nat

data Nat [α] : Set where
  zero : ∀β < α. Nat [α]
  succ : ∀β < α. Nat [β] → Nat [α]
```

This says that `Nat` takes some size parameter `α`, and to construct a `Nat` of size `α`,
we must provide a smaller size `β`, and in the case of the `succ`, a `Nat` of that size as well.
For instance, letting `∘` be some arbitrary size, we have that

```
⊢ zero {∘+1} [∘] : Nat [∘+1]
⊢ succ {∘+2} [∘+1] (zero {∘+1} [∘]) : Nat [∘+2]
```

which tracks with the intuitive understanding that the construction for the natural 1 is larger
than the construction for the natural 0 (and, incidentally, the intuitive _meaning_ that 0 < 1).
However, since `∘+1` is smaller than `∘+2`, `∘+3`, `∘+4`, and so on,
we can in fact give the construction for 1 a larger size:

```
⊢ succ {∘+4} [∘+1] (zero {∘+1} [∘]) : Nat [∘+4]
```

Generally, for inductive types at least, if a type has some size `s`, then we think of it as
being syntactically _no larger_ than `s`.

## Using Sized Inductive Types

Writing recursive functions on sized inductives is roughly unchanged,
especially in Agda, where size arguments are often marked implicit and then inferred.
Here, I'll write all size abstractions and applications explicitly,
including size parameters to constructors in braces as above.

The greatest benefit of using sized types is the ability to declare functions as _size-preserving_,
where the thing that comes out has the same size as the thing that goes in.
For instance, consider the type signature of a `monus` function:
its output is definitely no larger than the natural we subtract from.

```
monus : ∀α β. Nat [α] → Nat [β] → Nat [α]
```

Then we can define a `div` function using `monus`.

```
fix div [α] [β] (n : Nat [α]) (m : Nat [β]) : Nat [α] :=
  case n of
    zero [γ] ⇒ zero {α} [γ]
    succ [γ] k ⇒ succ {α} [γ] (div [γ] [β] (monus [γ] [β] k m) m)
```

In the case expression, we're given a size variable `γ` that the type system knows is smaller than
the size of the target `n` that we're destructing, which here is `α`.
Then our recursive call occurs on an argument of the smaller size `γ`.
This is why sizes denote a _relative_ size difference rather than an _absolute_ size:
when type checking fixpoints, we only need to ensure that recursive calls are done on something smaller,
regardless of its actual concrete size.
The typing rule for fixpoints, roughly below, describes this requirement.

```
Γ(α)(f: ∀β < α → σ[α ↦ β]) ⊢ e : σ
----------------------------------
Γ ⊢ fix f [α] : σ := e : ∀α. σ
```

Note that the first, decreasing argument of the recursive call to `div` is not the syntatically smaller argument `k`,
but because `monus` preserves its size, we know that it also has the same size.
Then `div` will pass type checking regardless of the implementation (or visibility thereof) of `monus`.

## Historical Notes

This presentation of having bounded sizes like `∀α < s. τ` is also known in the literature as
_inflationary fixed points_ (and dually _deflationary fixed points_ for coinductives).
Before the mid-2010s and before the implementation of sized types in Agda,
sized type theories commonly only had a successor operator `s+1`,
meaning that the sized naturals would have to be defined like this:

```
data Nat : ∀α. Set where
  zero : ∀α. Nat [α+1]
  succ : ∀α. Nat [α] → Nat [α+1]
```

Even nonrecursive constructors like `zero` have to have a successor size for the type system
to be logically consistent (i.e. sound).
This has carried over to the bounded-sizes presentation,
where conventionally zero also has a smaller size argument.
I'm not sure if this is strictly required for consistency.
In any case, the convention now is to use bounded sizes,
which appears to mitigate problems with pattern matching on sizes in Agda in particular.

# Infernal Infinity

The grammar of possible size expressions, also known as the _size algebra_,
is usually restricted to size variables and addition by constants,
so that sizes are nicely inferrable and don't require complex solvers.
However, this does restrict the number of things we can express.
This is why most sized type theories (and Agda) also has an _infinite_ size `∞`.
Just as `Nat [s]` represents a natural no larger than `s`,
`Nat [∞]` then represents _any_ possible natural,
also referred to as a _full_ natural, in contrast to _sized_ naturals.
For instance, to even express the type signature of a `plus` function,
we need the return type to be a full natural, since we can't express the addition of two sizes.

```
fix plus [α] [β] (n : Nat [α]) (m : Nat [β]) : Nat [∞] :=
  case n of
    zero [γ] ⇒ m
    succ [γ] k ⇒ succ {∞} [∞] (plus [γ] [β] k m)
```

Notice that all sizes are strictly smaller than `∞`, _including itself_.
This is how both the size parameter and the size argument of `succ` are `∞`;
if not, this function wouldn't be implementable.

This poses a problem for Agda in particular,
because we simultaneous expect `<` to be a well-behaved strict order,
but `∞` clearly violates this expectation.
These two simple facts yield an inconsistency,
as described by this [Agda issue](https://github.com/agda/agda/issues/2820).
In short, the behaviour of `<` can be encoded as an inductive type,
and well-founded induction on sizes can be defined using it.
Using `∞` on it then brings the tower of well-ordered sizes crashing down.

## Like, What _Is_ Infinity?

There are a few proposed solutions to this problem,
most of them centered around removing the `∞ < ∞` property of the infinite size.
This causes problems for Agda when it comes to coinductive types, but more fundamentally,
this property is really the _defining_ property of what infinity is.
To remove it would be like defining a `⊥` type without the property of being uninhabited.
On the other hand, we do want `<` to behave intuitively like a strict order on sizes,
which is how we justify recursion on smaller sizes.
We seem to be at an impasse now, but there's still one last question to ask ourselves:
Do we _really need_ an infinite size?

Going back to full and sized naturals, given that using `∞` appears to allow us to ignore sizes entirely,
maybe we could just used the unsized naturals from the very beginning in lieu of full naturals.
The practical problem with this is that we now need to juggle with two inductive types representing the same thing,
and more importantly, these two representations are incompatible with one another,
since we would not be able to apply an unsized natural to a function that takes a size and a sized natural of that size.

The key insight is that it's not that an unsized natural inherently has _no_ possible size to it,
but rather that it has some _unknown_ size.
We can express this in the type theory using an existentially-quantified inductive type, `∃α. Nat [α]`.
(For coindutives, the corresponding notion is simply a universally-quantified coinductive type,
although reaching this conclusion goes through a different informal argument).

To test this hypothesis, we should first be able to express our `plus` function above using it,
directly replacing `Nat [∞]` with `∃δ. Nat [δ]`, constructing such a thing as a pair `〈s, e〉`
and destructing it by `let 〈α, x〉 := p in ...`.

```
fix plus [α] [β] (n : Nat [α]) (m : Nat [β]) : ∃δ. Nat [δ] :=
  case n of
    zero [γ] ⇒ 〈α, zero {α} [γ]〉
    succ [γ] k ⇒
      let 〈δ, x〉 := plus [γ] [β] k m
      in  〈δ+1, succ {δ+1} [δ] x〉
```

So far, so good! The resulting code is a little wordier, but intuitively type checks.
Next, to make sure that it _means_ what we expect it to, supposing that we have unsized naturals,
we should be able to take an arbitrary one and transform it into an `∃α. Nat [α]`.
Obviously such a (recursive) function would need to be syntactically guard-checked for termination.

```
fix cast (n : Nat) : ∃δ. Nat [δ] :=
  case n of 
    zero ⇒ 〈∘+1, zero {∘+1} [∘]〉
    succ k ⇒
      let 〈δ, x〉 := cast k
      in 〈δ+1, succ {δ+1} [δ] x〉
```

In the base case, we need some concrete size; we can easily add a base size ∘ to the size algebra.
The recursive case does the same thing as `plus`, unpacking the pair and then packing it back up.
It seems like it would be easier to also add a size addition operator to the size algebra
so that `plus` can be expressed without existential quantification,
but what about the `n`th Fibonacci number?
What about the `n`th factorial?
It wouldn't be practical to allow arbitrary functions producing sizes if we want sizes to be practically inferrable,
so the existentially quantifying over sizes is a happy medium between expressivity and inferrability.

It then appears that this solves the problem of the infinite size.
There's no way to reproduce the inconsistency in Agda where an infinite size is applied to well-founded induction
because infinite sizes are "actually" just unknown concrete sizes.
But spoilers:

# Existential Size Quantification is Still Insufficient

You can imagine extending this technique for circumventing the infinite size
for more inductive types than just the naturals.
However, it only works for _simple_ inductive types;
when we extend to _general_ inductive types,
where the recursive argument of constructors can be a _function_ that returns the inductive,
it starts to break down.

As a concrete example, we'll look at _Brouwer ordinal trees_, a general inductive type representing the ordinals.
First, we start with the inductive data definition: an ordinal is zero, a successor ordinal, or a limit ordinal.

```
data Ord [α] : Set where
  Z : ∀β < α. Ord [α]
  S : ∀β < α. Ord [β] → Ord [α]
  L : ∀β < α. (∃α. Nat [α] → Ord [β]) → Ord [α]
```

The limit ordinal of a given function from (full) naturals to ordinals can be seen as the supremum of all the ordinals returned by that function.
For instance, we can define the ordinals equivalent to the naturals by a straightforward mapping.

```
fix natToOrd [α] (n : Nat [α]) : Ord [α] :=
  case n of
    zero [β] ⇒ Z {α} [β]
    succ [β] k ⇒ S {α} [β] (natToOrd [β] k)
```

If we were working with unsized inductives, the first limit ordinal ω would be easily defined as `L natToOrd`.
However, we run into a problem when we attempt the same with sized inductives:

```
L {?+1} [?] (λn: ∃α. Nat [α] ⇒ let 〈β, x〉 := n in natToOrd [β] x)
```

First of all, what should the size that goes in the hole `?` be?
The function argument of `L` potentially returns a different size for each result,
rather than a fixed, common size for all of them.
Second of all, the body of the function suggests that it would be possible to "leak" the size out of an existential,
if we want it to be well-typed.

```
(natToOrd: ∀α. Nat [α] → Ord [α])(n: ∃α. Nat [α]) ⊢ n : ∃α. Nat [α]
(natToOrd: ∀α. Nat [α] → Ord [α])(n: ∃α. Nat [α])(β)(x : Nat [β]) ⊢ natToOrd [β] x : Ord [β]
---------------------------------------------------------------------------------------------------
(natToOrd: ∀α. Nat [α] → Ord [α])(n: ∃α. Nat [α]) ⊢ let 〈β, x〉 := n in natToOrd [β] x : Ord [fst n]
```

In other words, `fst n`, the first projection of the existential pair,
is now a size expression, and since it is also a regular term,
size expressions are not restricted to the original size algebra and might be any term.
This does not bode well for the practicality of size inference as mentioned.

(_You can skip to the [next section](#pick-your-poison-infinity-or-axiom) now if you like.
The next two subsections aren't yet very polished._)

## A Tangled Tango of Terms and Sizes

If we do accept arbitrary terms producing sizes, treating the second issue as a nonproblem,
we might be able to solve the first issue.
The idea is that we borrow from the ordinals and allow a way to define a size as the limit of a function returning sizes.
Then we are able to define the ordinal ω.

```
let f (n: ∃α. Nat [α]) := let 〈β, x〉 := n in natToOrd [β] x
    g (n: ∃α. Nat [α]) := let 〈β, x〉 := n in β
in  L {(lim (∃α. Nat [α]) g)+1} [lim (∃α. Nat [α]) g] f
```

Rather than `lim` taking a function from full naturals, it takes a function from some arbitrary type.
This allows us to generalize the `lim` size operator to more general inductive types than just ordinals.
Furthermore, the above suggests that for any `(a : A)` and a function `f` from `A` to a size, `f a < lim A f`,
which is the behaviour we expect from a supremum operator.

Given that terms are involved in the order on sizes too,
definitionally checking whether one size is smaller than another becomes greatly complicated.
The worst case scenario would require users to provide entire proofs of sizes being smaller than another.
The whole purpose of sizes types is to determine these things without the help of the user,
because otherwise they would just use their own termination measures,
which would take the same amount of effort.
But it gets worse!

## A Tangled Tango of Sizes and Levels

At this point, sizes are beginning to be treated like terms, and the notion of size itself becomes a type.
We could _literally_ define size as an inductive type itself (unsized, of course).

```
data Size {ℓ} : Set (ℓ+1) where
  suc : Size → Size
  lim : (A : Set ℓ) → (A → Size) → Size
```

A problem becomes immediately apparent: the universe level that a size lives in is one larger than that of the type the `lim` operator.
This means that if we want to define sized naturals using `Size` as a parameter, for instance,
it would have to live in a universe larger than the one it really _should_ live in.
Letting `ln` being the `n`th universe level, we have

```
data Nat (s: Size {l0}) : Set l1 where
  zero : ∀(β: Size {l0}) < s. Nat [s]
  succ : ∀(β: Size {l0}) < s. Nat [β] → Nat [s]
```

Even when we restrict the sizes involved in `Nat` to universe level `l0`, the type of `Nat` itself has to be in level `l1`.
So if we have a `lim` operator, putting `Nat` in the bottomost universe `Set` where it belongs becomes somewhat suspect.
We could have an _impredicative_ bottommost universe, so that `Size` itself can live in `Set` regardless of the type in `lim`,
but it's unclear whether this would be sound,
and whether the usual restrictions on eliminating types in an impredicative Set are too restrictive.

# Pick Your Poison: Infinity or Axiom

Let's go back a few steps and forget about the `lim` operator on sizes.
The problem we wish to solve is to somehow obtain the appropriate size from a function that might return inductives with a myriad of sizes.
In other words, we want some sort of function with the following type signature:

```
cast : {A: Set ℓ} → {T: ∀α. Set ℓ} → (A → ∃α. T [α]) → ∃α. (A → T [α])
```

This lets us define that pesky ordinal ω, as expected, although with far more code.

```
let 〈β, f〉 := cast (λn: ∃α. Nat [α] ⇒ let 〈γ, x〉 := n in 〈γ, natToOrd [γ] x〉)
in  L [β] f
```

Now hear me out: what if we made `cast` a noncomputing axiom?
I've compiled a list of pros and cons for your convenience:

<u>CONS</u>
* Breaks canonicity of existential size quantifications
* Doesn't compute
* Makes constructive type theorists sad

<u>PROS</u>
* Literally solves every single problem that sized types has
* This is an exaggeration, but you have to admit it comes close

It certainly feels like this axiom could have computational behaviour by using the `lim` operator.
But one thing about sizes that I feel should be reiterated again is that they describe a _relative_ difference in sizes,
not a concrete _absolute_ size of a particular inductive.
Therefore, it shouldn't matter what the size that the `cast` axiom appears to summon out of thin air actually _is_,
as long as we can be sure that every inductive type for which we allow a `cast`ing definitely _does_ have a size—and surely they do,
for an inductive whose inhabitants we can write down is a finite inductive.
However, it's unclear to me what effect a `cast` axiom, or even existential size quantification,
would have on how sizes are inferred and solved for in practice in a proof assistant.

# Summary

* Modern sized types use a bounded form of universal size quantification and induce a strict order on sizes
* The conventional infinite size violates the wellfoundedness of this strict order
* An inductive with an "infinite" size is really one with _some_ size,
  so maybe we can replace it with existential size quantification
* This works for simple inductive types, but not for general inductive types, unless:
  * We complicate the size algebra by adding an operator to find a "limit" size; or
  * We add an axiom to avoid needing to compute exact sizes
* Having a consistent, useable dependent sized type system is still an open problem
