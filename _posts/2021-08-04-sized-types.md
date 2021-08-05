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
(Here, the size parameter `α` is in fact an implicit size argument to the constructors;
when I want to write them explicitly I will put them in braces `{}`,
as opposed to regular explicit size arguments, which are in brackets `[]`.)
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
    zero [γ] ⇒ 〈β, m〉
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
Second of all, for the let expression to be well-typed,
we need to be able to project only the size out of `n`,
which means that sizes might now involve arbitrary terms beyond the size algebra.

```
(natToOrd: ∀α. Nat [α] → Ord [α])(n: ∃α. Nat [α]) ⊢ n : ∃α. Nat [α]
(natToOrd: ∀α. Nat [α] → Ord [α])(n: ∃α. Nat [α])(β)(x : Nat [β]) ⊢ natToOrd [β] x : Ord [β]
---------------------------------------------------------------------------------------------------
(natToOrd: ∀α. Nat [α] → Ord [α])(n: ∃α. Nat [α]) ⊢ let 〈β, x〉 := n in natToOrd [β] x : Ord [fst n]
```

## Choose your Fighter

Given that ω is expressible with unsized inductives, it should also be expressible with sized inductives.
What we have is a function from naturals to ordinals, and consequently a function from full naturals to full ordinals.
What we need is some size we can pass to `L`, as well as a function from full naturals to ordinals of that size.
In other words, we need the following function:

```
C' : (∃α. Nat [α] → ∃β. Ord [β]) → ∃β. (∃α. Nat [α] → Ord [β])
```

More generally, for some inductive type `X` that might have a general recursive argument of the form `(a: A) → X a`,
we need to similarly be able to bring out the existential from inside the function to outside.
(We let `ℓ` be an arbitrary universe level, since the argument `A` could live in any universe.)

```
C : {A: Set ℓ} → {X: ∀α. A → Set ℓ} → ((a: A) → ∃α. X [α] a) → ∃α. (a: A) → X [α] a
```

You might notice that this is in fact a form of the axiom of choice specialized to existential quantification over sizes.
The general statement of the axiom is as follows:

```
AC : {A: Set ℓ} → {B: A → Set ℓ} → {X: (a: A) → B a → Set ℓ} →
     ((a: A) → (b : B a) × X a b) → (f: (a: A) → B a) × ((a: A) → X a (f a))
```

We could stop here and accept `C` as a noncomputing axiom.
This would break canonicity for existential pairs, since `C` can yield a closed neutral term that isn't a pair.
However, if projecting the elements out of the pair is allowed, then the axiom is computational.
For the general axiom of choice, this is implemented as

```
AC g = 〈λa: A ⇒ fst (g a), λa: A ⇒ snd (g a)〉
```

By analogy, `C` should be implemented as

```
C g = 〈λa: A → fst (g a), λa: A → snd (g a)〉
```

but this doesn't type check: `λa: A → fst (g a)` is a function from `A` to a size,
whereas we expect the first argument to be merely a size.
Taking inspiration from the ordinals, we could add an operator that constructs the _limit_ of a function to sizes.
That is, given a function `f` from some `A` to a size, we have the size expression `lim A f`.
Then we are able to complete the implementation of `C`.

```
C g = 〈lim A (λa: A → fst (g a)), λa: A → snd (g a)〉
```

Finally, we can define the limit ordinal ω, perhaps with a few more steps than desired.

```
ω : Ord [lim (∃α. Nat [α]) (λn: ∃α. Nat [α] ⇒ fst n)]
ω = let 〈β, x〉 := C (λn: ∃α. Nat [α] ⇒ 〈fst n, natToOrd [fst n] (snd n)〉)
    in L [β] x
```

# At the Limits of Sizes

We now essentially have a new constructor for sizes.
This means we also have to figure out where it fits in the ordering of sizes.
By convention, we define `r < s` to be `r+1 ≤ s`,
and we can conclude `r+1 ≤ s+1` if `r ≤ s` holds.
Furthermore, `α+1 ≤ s` holds if `α < s` is assumed in the environment,
such as in the body of `∀α < s. τ`.

As a limit size, `lim A f` should be the supremum of all of the sizes returned by `f`,
just as `L g` is the supremum of all of the ordinals returned by `g`.
Then firstly, being an upper bound,
if we have some size `s` smaller than any size returned by `f`,
it must also be smaller than `lim A f` itself.

```
Γ ⊢ a : A
Γ ⊢ s ≤ f a
---------------
Γ ⊢ s ≤ lim A f
```

Secondly, being a _least_ upper bound, if every size returned by `f` is smaller than some `s`,
it must be that `lim A f` itself is also smaller than `s`.
In other words, there cannot be a size in between the sizes from `f` and `lim A f`.

```
For every Γ ⊢ a : A,
Γ ⊢ f a ≤ s
--------------------
Γ ⊢ lim A f ≤ s
```

Unfortunately, this likely makes checking the size order undecidable.
For the first rule, the checker needs to somehow summon the correct `a` out of thin air;
for the second rule, the checker needs to somehow verify the premise for _every_ possible `a`.

## Sizes are Too Big

Given that we've been freely using `fst` and `snd` on existential size pairs,
it seems that we should promote sizes to being proper terms.
(Incidentally, in Agda they are.)
Assuming we have some type `Size`, we can write down the typing rules for the introduction forms.
(Here, `s+1 ≡ suc s`.)

```
Γ ⊢ s : Size
--------------
Γ ⊢ suc s : Size

Γ ⊢ A : Set ℓ
Γ ⊢ f : A → Size
------------------
Γ ⊢ lim A f : Size
```

Notice that we have an unbound universe level ℓ.
This suggests that we need to pass ℓ as an argument to either `lim` itself or to `Size`.
Since we'd like to treat sizes uniformly and be able to pass them around without worrying about the level,
we'll adopt the former solution.

If we think of `Size` as an inductive type in Agda, this forces us to put it in `Setω`.
In other words, `Size` in Agda would look like this:

```
open import Agda.Primitive
data Size : Setω where
  suc : Size → Size
  lim : {ℓ : Level} → {A : Set ℓ} → (A → Size) → Size
```

This is a problem because inductive types contain a size as a parameter,
meaning that they, too, all need to live in `Setω`.
Take the naturals, for example: morally, they _should_ be in `Set`,
but again if defining them in Agda (and borrowing some notation for sizes), we have

```
data Nat (α : Size) : Setω where
  zero : (β : Size< α) → Nat [α]
  succ : (β : Size< α) → Nat [β] → Nat [α]
```

The problem would be solved if we could put `Size` in `Set` instead.
In Agda, this requires `Set` to be _impredicative_, in a sense,
which when combined with large elimination of types in `Set` in general would be inconsistent.
It's yet unclear to me whether only allowing `Size` to be in `Set` as a primitive formation rule would be consistent.

```
--------------
Γ ⊢ Size : Set
```

# Summary

* Modern sized types use a bounded form of universal size quantification and induce a strict order on sizes
* The conventional infinite size violates the wellfoundedness of this strict order
* An inductive with an "infinite" size is really one with _some_ size,
  so maybe we can replace it with existential size quantification
* This works for simple inductive types, but not for general inductive types, unless:
  * We add a noncomputing form of the axiom of choice, which would break canonicity; or
  * We add a limit operator for sizes, which likely breaks decidability of size orders,
    and causes problems to do with the universe level of sizes
* Having a consistent, reasonable, and useable sized dependent type system is still an open problem
