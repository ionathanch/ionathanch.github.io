---
layout: post
title: "An Analysis of An Analysis of Girard's Paradox"
excerpt_separator: "<!--more-->"
tags:
  - type theory
  - inconsistency
---

While it's rather difficult to accidentally prove an inconsistency in a well-meaning type theory that isn't obviously inconsistent
(have you ever unintentionally proven that a type corresponding to an ordinal is strictly larger than itself? I didn't think so),
it feels like it's comparatively easy to add rather innocent features to your type theory that will suddenly make it inconsistent.
And there are so many of them!
And sometimes it's the *interaction* among the features rather than the features themselves that produce inconsistencies.

<!--more-->

As it turns out, a lot of the inconsistencies can surface as proofs of what's known as Hurkens' paradox [[1](#1)],
which is a simplification of Girard's paradox [[2](#2)],
which itself is a type-theoretical formulation of the set-theoretical Burali–Forti's paradox [[3](#3)].
I won't claim to deeply understand how any of these paradoxes work,
but I'll present various formulations of Hurkens' paradox in the context of the most well-known inconsistent features.

## Type in Type

The most common mechanization of Hurkens' paradox you can find online is using type-in-type,
where the type of the universe `Type` has `Type` itself as its type,
because most proof assistants have ways of turning this check off.
We begin with what Hurkens calls a _powerful paradoxical universe_,
which is a type `U` along with two functions `τ : ℘ (℘ U) → U` and `σ : U → ℘ (℘ U)`.
Conceptually, `℘ X` is the powerset of `X`, implemented as `X → Type`;
`τ` and `σ` then form an isomorphism between `U` and the powerset of its powerset, which is an inconsistency.
Hurkens defines `U`, `τ`, and `σ` as follows, mechanized in Agda below.

```
U : Set
U = ∀ (X : Set) → (℘ (℘ X) → X) → ℘ (℘ X)

τ : ℘ (℘ U) → U
τ t = λ X f p → t (λ x → p (f (x X f)))

σ : U → ℘ (℘ U)
σ s = s U τ
```

The complete proof can be found at [Hurkens.html](/assets/agda/Hurkens.html),
but we'll focus on just these definitions for the remainder of this post.

## Strong Impredicative Pairs

A _strong (dependent) pair_ is a pair from which we can project its components.
An _impredicative pair_ in some impredicative universe `𝒰` is a pair that lives in `𝒰` when either of its components live in `𝒰`,
regardless of the universe of the other component.
It doesn't matter too much which specific universe is impredicative as long as we can refer to both it and its type,
so we'll suppose for this section that `Set` is impredicative.
The typing rules for the strong impredicative pair are then as follows;
we only need to allow the first component of the pair to live in any universe.

```
Γ ⊢ A : 𝒰
Γ, x: A ⊢ B : Set
──────────────────
Γ ⊢ Σx: A. B : Set

Γ ⊢ a : A
Γ ⊢ b : B[x ↦ a]
─────────────────────
Γ ⊢ (a, b) : Σx: A. B

Γ ⊢ p : Σx: A. B
────────────────
Γ ⊢ fst p : A

Γ ⊢ p : Σx: A. B
────────────────────────
Γ ⊢ snd p : B[x ↦ fst p]

Γ ⊢ (a, b) : Σx: A. B
──────────────────────
Γ ⊢ fst (a, b) ≡ a : A

Γ ⊢ (a, b) : Σx: A. B
─────────────────────────────
Γ ⊢ snd (a, b) ≡ b : B[x ↦ a]
```

If we turn type-in-type off in the previous example, the first place where type checking fails is for `U`,
which with predicative universes we would expect to have type `Set₁`.
The idea, then, is to squeeze `U` into the lower universe `Set` using the impredicativity of the pair,
then to extract the element of `U` as needed using the strongness of the pair.
Notice that we don't actually need the second component of the pair, which we can trivially fill in with `⊤`.
This means we could instead simply use the following record type in Agda.

```
record Lower (A : Set₁) : Set where
  constructor lower
  field raise : A
```

The type `Lower A` is equivalent to `Σx: A. ⊤`, its constructor `lower a` is equivalent to `(a, tt)`,
and the projection `raise` is equivalent to `fst`.
To allow type checking this definition, we need to again turn on type-in-type, despite never actually exploiting it.
If we really want to make sure we really never make use of type-in-type,
we can postulate `Lower`, `lower`, and `raise`, and use rewrite rules to recover the computational behaviour of the projection.

```
{-# OPTIONS --rewriting #-}

postulate
  Lower : (A : Set₁) → Set
  lower : ∀ {A} → A → Lower A
  raise : ∀ {A} → Lower A → A
  beta : ∀ {A} {a : A} → raise (lower a) ≡ a

{-# REWRITE beta #-}
```

Refactoring the existing proof is straightforward:
any time an element of `U` is used, it must first be raised back to its original universe,
and any time an element of `U` is produced, it must be lowered down to the desired universe.

```
U : Set
U = Lower (∀ (X : Set) → (℘ (℘ X) → X) → ℘ (℘ X))

τ : ℘ (℘ U) → U
τ t = lower (λ X f p → t (λ x → p (f (raise x X f))))

σ : U → ℘ (℘ U)
σ s = raise s U τ
```

Again, the complete proof can be found at [HurkensLower.html](/assets/agda/HurkensLower.html).
One final thing to note is that impredicativity (with respect to function types) of `Set` isn't used either;
all of this code type checks in Agda, whose universe `Set` is not impredicative.
This means that impredicativity with respect to pair types alone is sufficient for inconsistency.

## Unrestricted Large Elimination of Impredicative Universes

In contrast to strong pairs, weak (impredicative) pairs don't have first and second projections.
Instead, to use a pair, one binds its components in the body of some expression
(continuing our use of an impredicative `Set`).

```
Γ ⊢ p : Σx: A. B
Γ, x: A, y: B ⊢ e : C
Γ ⊢ C : Set
────────────────────────────
Γ ⊢ let (x, y) := p in e : C
```

The key difference is that the type of the expression must live in `Set`, and not in any arbitrary universe.
Therefore, we can't generally define our own first projection function, since `A` might not live in `Set`.

Weak impredicative pairs can be generalized to inductive types in an impredicative universe,
where the restriction becomes disallowing arbitrary _large elimination_ to retain consistency.
This appears in the typing rule for case expressions on inductives.

```
Γ ⊢ t : I p… a…
Γ ⊢ I p… : (y: u)… → 𝒰
Γ, y: u, …, x: I p… a… ⊢ P : 𝒰'
elim(𝒰, 𝒰') holds
< other premises omitted >
───────────────────────────────────────────────────────────────
Γ ⊢ case t return λy…. λx. P of [c x… ⇒ e]… : P[y… ↦ a…][x ↦ t]
```

The side condition `elim(𝒰, 𝒰')` holds if:
* `𝒰 = Set₁` or higher; or
* `𝒰 = 𝒰' = Set`; or
* `𝒰 = Set` and
  * Its constructors' arguments are either forced or have types living in `Set`; and
  * The fully-applied constructors have orthogonal types; and
  * Recursive appearances of the inductive type in the constructors' types are syntactically guarded.

The three conditions of the final case come from the rules for definitionally proof-irrelevant `Prop` [[4](#4)];
the conditions that Coq uses are that the case target's inductive type must be a singleton or empty,
which is a subset of those three conditions.
As the pair constructor contains a non-forced, potentially non-`Set` argument in the first component,
impredicative pairs can only be eliminated to terms whose types are in `Set`,
which is exactly what characterizes the weak impredicative pair.
On the other hand, allowing unrestricted large elimination lets us define not only strong impredicative pairs,
but also `Lower` (and the projection `raise`), both as inductive types.

## Two Impredicative Universe Layers

Hurkens' original construction of the paradox was done in System U⁻, where there are _two_ impredicative universes,
there named `*` and `□`.
We'll call ours `Set` and `Set₁`, with the following typing rules for function types.

```
Γ ⊢ A : 𝒰
Γ, x: A ⊢ B : Set
────────────────── Π-Set
Γ ⊢ Πx: A. B : Set

Γ ⊢ A : 𝒰
Γ, x: A ⊢ B : Set₁
─────────────────── Π-Set₁
Γ ⊢ Πx: A. B : Set₁
```

Going back to the type-in-type proof, consider now `℘ (℘ X)`.
By definition, this is `(X → Set) → Set`; since `Set : Set₁`, by Π-Set₁,
the term has type `Set₁`, regardless of what the type of `X` is.
Then `U = ∀ X → (℘ (℘ X) → X) → ℘ (℘ X)` has type `Set₁` as well.
Because later when defining `σ : U → ℘ (℘ U)`, given a term `s : U`, we want to apply it to `U`,
the type of `X` should have the same type as `U` for `σ` to type check.
The remainder of the proof of inconsistency is unchanged, as it doesn't involve any explicit universes,
although we also have the possibility of lowering the return type of `℘`.

```
℘ : ∀ {ℓ} → Set ℓ → Set₁
℘ {ℓ} S = S → Set

U : Set₁
U = ∀ (X : Set₁) → (℘ (℘ X) → X) → ℘ (℘ X)
```

Note well that having two impredicative universe layers is _not_ the same thing as having two parallel impredicative universes.
For example, by turning on `-impredicative-set` in Coq, we'd have an impredicative `Prop` and an impredicative `Set`,
but they are in a sense parallel universes: the type of `Prop` is `Type`, not `Set`.
The proof wouldn't go through in this case, since it relies on the type of the return type of `℘` being impredicative as well.
With cumulativity, `Prop` is a subtype of `Set`, but this has no influence for our puposes.

## Bonus: Other Inconsistencies

There's a variety of other features that yield inconsistencies while having nothing to do with Girard's paradox,
and some of them are comparatively simple.

### Negative Inductive Types

A negative inductive type is one where the inductive type appears to the left of an odd number of arrows in a constructor's type.
For instance, the following definition will allow us to derive an inconsistency.

```
record Bad : Set where
  constructor mkBad
  field bad : Bad → ⊥
open Bad
```

The field of a `Bad` essentially contains a negation of `Bad` itself (and I believe this is why this is considered a "negative" type).
So when given a `Bad`, applying it to its own field, we obtain its negation.

```
notBad : Bad → ⊥
notBad b = b.bad b
```

Then from the negation of `Bad` we construct a `Bad`, which we apply to its negation to obtain an inconsistency.

```
bottom : ⊥
bottom = notBad (mkBad notBad)
```

### Positive Inductive Types

_This section is adapted from [Why must inductive types be strictly positive?](http://vilhelms.github.io/posts/why-must-inductive-types-be-strictly-positive/)_.

A positive inductive type is one where the inductive type appears to the left of an even number of arrows in a constructor's type.
(Two negatives cancel out to make a positive, I suppose.)
If it's restricted to appear to the left of _no_ arrows (0 is an even number), it's a _strictly_ positive inductive type.
Strict positivity is the usual condition imposed on all inductive types in Coq.
If instead we allow positive inductive types in general, when combined with an impredicative universe (we'll use `Set` again),
we can define another inconsistency corresponding to Russell's paradox.

```
{-# NO_POSITIVITY_CHECK #-}
record Bad : Set₁ where
  constructor mkBad
  field bad : ℘ (℘ Bad)
```

From this definition, we can prove an injection from `℘ Bad` to `Bad` via an injection from `℘ Bad` to `℘ (℘ Bad)`
defined as a partially-applied equality type.

```
f : ℘ Bad → Bad
f p = mkBad (_≡ p)

fInj : ∀ {p q} → f p ≡ f q → p ≡ q
fInj {p} fp≡fq = subst (λ p≡ → p≡ p) (badInj fp≡fq) refl
  where
  badInj : ∀ {a b} → mkBad a ≡ mkBad b → a ≡ b
  badInj refl = refl
```

Evidently an injection from a powerset of some `X` to `X` itself should be an inconsistency.
However, it doesn't appear to be provable without using some sort of impredicativity.
(We'll see.)
Coquand and Paulin [[5](#5)] use the following definitions in their proof, which does not type check without type-in-type,
since `℘ Bad` otherwise does not live in `Set`.
In this case, weak impredicative pairs would suffice, since the remaining definitions can all live in the same impredicative universe.

```
P₀ : ℘ Bad
P₀ x = Σ[ P ∈ ℘ Bad ] x ≡ f P × ¬ (P x)

x₀ : Bad
x₀ = f P₀
```

From here, we can prove `P₀ x₀ ↔ ¬ P₀ x₀`. The rest of the proof can be found at [Positivity.html](/assets/agda/Positivity.html).

## Source Files

<p></p>
<details>
  <summary>Hurkens' paradox using type-in-type: <a href="/assets/agda/Hurkens.html">Hurkens.html</a></summary>
  <iframe id="h" src="/assets/agda/Hurkens.html" width="100%"></iframe>
</details>
<p></p>
<details>
  <summary>Hurkens' paradox using <code>Lower</code>: <a href="/assets/agda/HurkensLower.html">HurkensLower.html</a></summary>
  <iframe src="/assets/agda/HurkensLower.html" width="100%"></iframe>
</details>
<p></p>
<details>
  <summary>Russell's paradox using a positive inductive type and impredicative pairs: <a href="/assets/agda/Positivity.html">Positivity.html</a></summary>
  <iframe src="/assets/agda/Positivity.html" width="100%"></iframe>
</details>

<script>
  let details = document.querySelectorAll("details");
  details.forEach((detail) => {
    detail.hasBeenExpanded = false;
    detail.addEventListener("toggle", () => {
      if (!detail.hasBeenExpanded) {
        detail.hasBeenExpanded = true;
        let iframe = detail.getElementsByTagName("iframe")[0];
        iframe.style.height = iframe.contentDocument.body.scrollHeight + 30 + "px";
      }
    });
  });
</script>

## References

[<a name="1">1</a>] Hurkens, Antonius J. C. (1995). _A Simplification of Girard's Paradox_. doi:[10.1007/BFb0014058](https://doi.org/10.1007/BFb0014058).
<br/>
[<a name="2">2</a>] Coquand, Thierry. (1986). _An Analysis of Girard's Paradox_. https://hal.inria.fr/inria-00076023.
<br/>
[<a name="3">3</a>] Burali–Forti, Cesare. (1897). _Una questione sui numeri transfini_. doi:[10.1007/BF03015911](https://doi.org/10.1007/BF03015911).
<br/>
[<a name="4">4</a>] Gilbert, Gaëtan; Cockx, Jesper; Sozeau, Matthieu; Tabareau, Nicolas. (2019). _Definitional Proof-Irrelevance without K_. doi:[10.1145/3290316](https://doi.org/10.1145/3290316).
<br/>
[<a name="5">5</a>] Coquand, Theirry; Paulin, Christine. _Inductively defined types_. doi:[10.1007/3-540-52335-9_47](https://doi.org/10.1007/3-540-52335-9_47).
