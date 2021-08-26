---
layout: post
title: "How to Use Sized Types?<br/>Let Me Count the Ways"
tab_title: "How to Use Sized Types? Let Me Count the Ways"
excerpt_separator: "<!--more-->"
tags:
  - sized types
  - type theory
---

<!--
This is a temporary fix while GitHub Pages' syntax highlighter, Rouge,
does not yet have a lexer for Agda: https://github.com/rouge-ruby/rouge/issues/709.
So in the meantime, we use Haskell's highlighter, and manually disable errors.
-->

<style>
  .highlight .err {
    background-color: inherit;
  }
</style>

_This post is inspired by [this thread](https://lists.chalmers.se/pipermail/agda/2021/012724.html)
from the Agda mailing list._

Because Agda treats `Size` like a first-class type,
there's quite a bit of freedom in how you get to use it.
This makes it a bit unclear where you should start:
should `Size` be a parameter or an index in your type?
What sizes should the constructors' recursive arguments' and return types have?
Here are two options that are usually used (and one that doesn't work.)
The recommended one is using [inflationary sized types](#3-inflationary-sized-types) and `Size<`.

<!--more-->

We'll be looking at adding sized types to a mutually-defined tree/forest inductive type.
A tree parametrized by `A` contains an `A` and a forest,
while a forest consists of a bunch of trees.

```haskell
{-# OPTIONS --sized-types #-}

open import Size

variable
  A : Set

module Forestry where
  data Tree {A : Set} : Set
  data Forest {A : Set} : Set

  data Tree {A} where
    node : A → Forest {A} → Tree
  
  data Forest {A} where
    leaf : Forest
    cons : Tree {A} → Forest {A} → Forest

  traverse : (Tree {A} → Tree {A}) → Forest {A} → Forest {A}
  traverse f leaf = leaf
  -- traverse f (cons (node a forest) rest) = cons (f (node a (traverse f forest))) (traverse f rest)
  traverse f (cons tree rest) with f tree
  ... | node a forest = cons (node a (traverse f forest)) (traverse f rest)

```

We can traverse a forest with a function that acts on trees.
The first (commented out) is to first traverse the forest contained within a tree,
then apply the function to the tree, which is structurally guarded.
The second is to traverse the forest of the tree applied to the function, which is not.
However, if we promise to not alter the size of the tree with our function—that is,
using a size-preserving function—then we'll be able to implement this post-traversal.

# 1. Successor Sized Types

Here's a recipe for turning your inductives into sized inductives.

* In the types of the inductives, add `Size` as an index.
* For every constructor, add a size argument `∀ s`.
* For every recursive constructor argument (that includes the mutual ones), give it size `s`.
* For every constructor return type, give it size `↑ s`.

I call this pattern *successor* sized types since every constructible inductive's size is a successor size.
Then it will always have a larger size than any of its recursive arguments.
I tend to keep the sizes in the inductives' types explicit,
so that size-preserving function signatures are clear,
but make the sizes in the constructors' types implicit,
since those can usually be inferred when the sizes are present in the function signatures.
Applied to trees and forests, this is what we get.

```haskell
module SuccSizedForestry where
  data Tree {A : Set} : Size → Set
  data Forest {A : Set} : Size → Set

  data Tree {A} where
    node : ∀ {s} → A → Forest {A} s → Tree (↑ s)
  
  data Forest {A} where
    leaf : ∀ {s} → Forest (↑ s)
    cons : ∀ {s} → Tree {A} s → Forest {A} s → Forest (↑ s)
```

The traversal function is easy: just add the sizes in the type, and type checking will do the rest.

```haskell
  traverse : ∀ {s} → (∀ {r} → Tree {A} r → Tree {A} r) → Forest {A} s → Forest {A} s
  traverse f leaf = leaf
  traverse f (cons tree rest) with f tree
  ... | node a forest = cons (node a (traverse f forest)) (traverse f rest)
```

There's one strange thing with our current definition:
in `cons`, the tree and the forest need to have the same size.
Given that they're not only two different arguments but also two arguments of different types,
why should they have the same size?
When constructing a forest, you'll certainly run into the issue of
needing to bump up the size of one or the other in order to use `cons`.
Let's see if we can avoid this by using different sizes.

# 2. Suprema Sized Types

Spoiler alert: this doesn't pass termination checking in Agda... but let's proceed anyway.
The recipe is modified slightly.

* In the types of the inductives, add `Size` as an index.
* For every constructor, add a size argument `∀ sᵢ` for each of the recursive arguments.
* For each `i`th recursive constructor argument, give it size `sᵢ`.
* For every constructor return type with `n` recursive arguments, you have two options:
  * Give it size `↑ (s₁ ⊔ˢ s₂ ⊔ˢ ... ⊔ˢ sₙ)`; or
  * Give it size `(↑ s₁) ⊔ˢ (↑ s₂) ⊔ˢ ... ⊔ˢ (↑ sₙ)`.

The supremum operator `s₁ ⊔ˢ s₂` can be thought of as taking the maximum of the two sizes.
The idea is that if you have two arguments of size `s₁` and `s₂`,
the size of the constructed term should have a size larger than whichever is largest,
and `↑ (s₁ ⊔ˢ s₂)` and `(↑ s₁) ⊔ˢ (↑ s₂)` are equivalent.
I've chosen the former below.

```haskell
module SupSizedForestry where
  data Tree {A : Set} : Size → Set
  data Forest {A : Set} : Size → Set

  data Tree {A} where
    node : ∀ {s} → A → Forest {A} s → Tree (↑ s)
  
  data Forest {A} where
    leaf : ∀ {s} → Forest (↑ s)
    cons : ∀ {st sf} → Tree {A} st → Forest {A} sf → Forest (↑ (st ⊔ˢ sf))
    -- cons : ∀ {st sf} → Tree {A} st → Forest {A} sf → Forest ((↑ st) ⊔ˢ (↑ sf))
```

However, the traversal doesn't pass termination checking.
I've specified some of the sizes explicitly for clarity.

```haskell
  traverse : ∀ {s} → (∀ {r} → Tree {A} r → Tree {A} r) → Forest {A} s → Forest {A} s
  traverse f leaf = leaf
  traverse f (cons tree forest) with f tree
  traverse {_} .{↑ ((↑ st) ⊔ˢ sf)} f (cons .{↑ st} {sf} tree forest)
    | (node {st} a forest') = cons (node a (traverse {_} {st} f forest')) (traverse {_} {sf} f forest)
```

It appears that Agda can't deduce that `st` and `sf` are both strictly smaller than `↑ ((↑ st) ⊔ˢ sf)`.
(To see that this is true, if `sf > ↑ st`, then `↑ ((↑ st) ⊔ˢ sf) = ↑ sf > sf > ↑ st`;
otherwise, `↑ ((↑ st) ⊔ˢ sf) = ↑ ↑ st > ↑ st ≥ sf`.)

# 3. Inflationary Sized Types

The last option does work in Agda, and has the benefit of allowing different sizes for different arguments.
Overall, this is the ideal option to choose.
The first option is more of a historical artifact than anything.
The recipe is a little different:

* In the types of the inductives, add `(s : Size)` as a *parameter*.
* For every constructor, add a size argument `∀ (rᵢ : Size< s)` for each of the recursive arguments.
* For each `i`th recursive constructor argument, give it size `rᵢ`.
* The return types of the constructors necessarily have size `s`, since it's a parameter.

The `Size< : Size → Set` type constructor lets us declare a size strictly smaller than a given size.
Then just as in the first option, every recursive argument must have a smaller size.
These are called inflationary sized types because they correspond to inflationary fixed points in the metatheory,
but I prefer to simply think of them as *bounded* sized types.

```haskell
module BoundedSizedForestry where
  data Tree {A : Set} (s : Size) : Set
  data Forest {A : Set} (s : Size) : Set

  data Tree {A} s where
    node : ∀ {r : Size< s} → A → Forest {A} r → Tree s
  
  data Forest {A} s where
    leaf : ∀ {r : Size< s} → Forest s
    cons : ∀ {st sf : Size< s} → Tree {A} st → Forest {A} sf → Forest s
```

Then the traversal is exactly the same as in the first option,
and passes termination checking without any further effort.

```haskell
  traverse : ∀ {s} → (∀ {r} → Tree {A} r → Tree {A} r) → Forest {A} s → Forest {A} s
  traverse f leaf = leaf
  traverse f (cons tree rest) with f tree
  ... | node a forest = cons (node a (traverse f forest)) (traverse f rest)
```

# Bonus: So You Want to Prove ⊥

_This example is lifted from [issue #2820](https://github.com/agda/agda/issues/2820) in the Agda GitHub repository._

Agda's sized types comes with an infinite size `∞` that you can sprinkle in anywhere.
This is handy for specifying sized arguments whose size you don't care about
(e.g. if you're not recurring on them),
and for specifying sized return types that are "too big" to be expressible as a finite size,
such as the return type of a factorial function.
In order for `∞` to behave as you'd expect, it needs to satisfy `∞ + 1 = ∞`,
which implies `∞ + 1 < ∞`.
However, we can also show that the order `<` on sizes is well-founded,
thus yielding a contradiction in the presence of `∞`.

## Step 1: Define an Order on Sizes

Agda already has an order on sizes via `Size<`, but this is hard to manipulate.
We can instead define an inductive type that reflects this order.

```haskell
module False where

  open import Data.Empty

  data _<_ : Size → Size → Set where
    lt : ∀ s → (r : Size< s) → r < s
```

## Step 2: Define Accessibility of Sizes

Next, we define accessibility with respect to this order, which states that for some size `s`,
if every smaller size is accessible, then `s` itself is accessible.
Agda's standard library has an accessibility relation parametrized over an arbitrary order,
but I'll redefine it explicitly for sizes for clarity.

```haskell
  data Acc (s : Size) : Set where
    acc : (∀ {r} → r < s → Acc r) → Acc s
```

## Step 3: Prove Wellfoundedness of Sizes w.r.t. the Order

Now we can state wellfoundedness of sizes, which is simply that every size is accessible.
If this is true, then surely there should be no infinitely-descending chain `... s₃ < s₂ < s₁`.

```haskell
  wf : ∀ s → Acc s
  wf s = acc (λ {(lt .s r) → wf r})
```

This proof appears to rely on the fact that the type of `r` gets unified with `Size< s` when matching on `r < s`.
Then termination checking passes because `wf` is called on a smaller size.
Conventionally, this kind of proof is structurally-decreasing based on case analysis of thing that's accessible,
but we can't inspect sizes like that in Agda.

## Step 4: Prove ∞ < ∞ and Derive ⊥

The problem with saying that sizes are wellfounded with respect to the size order is that they are not!
We have the infinitely-descending chaing `... ∞ < ∞ < ∞`.
The fact that `∞` is *not* accessible can be proven by structural induction on the accessibility relation,
without the help of sized termination checking.

```haskell
  ¬wf∞ : Acc ∞ → ⊥
  ¬wf∞ (acc p) = ¬wf∞ (p (lt ∞ ∞))
```

Finally, we prove falsehood from this and the contradictory fact that `∞` is wellfounded
because we've just proven that *all* sizes are wellfounded.

```haskell
  ng : ⊥
  ng = ¬wf∞ (wf ∞)
```
