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

## Hurken's Paradox

As it turns out, a lot of the inconsistencies can surface as proofs of what's known as Hurkens' paradox [[1](#1)],
which is a simplification of Girard's paradox [[2](#2)],
which itself is a type-theoretical formulation of the set-theoretical Burali–Forti's paradox [[3](#3)].
I won't claim to deeply understand how any of these paradoxes work,
but I'll present various formulations of Hurkens' paradox in the context of the most well-known inconsistent features.

### Type in Type

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

### Two Impredicative Universe Layers

Hurkens' original construction of the paradox was done in System U⁻, where there are _two_ impredicative universes,
there named `*` and `□`.
We'll call ours `Set` and `Set₁`, with the following typing rules for function types featuring impredicativity.

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
An impredicative `Set₁` above a predicative `Set` may be inconsistent as well,
since we never make use of the impredicativity of `Set` itself.

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

### Strong Impredicative Pairs

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
This means that impredicativity with respect to strong pair types alone is sufficient for inconsistency.

### Unrestricted Large Elimination of Impredicative Universes

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

While impredicative functions can Church-encode weak impredicative pairs, they can't encode strong ones.

```
Σx: A. B ≝ (P : Set) → ((x : A) → B → P) → P
```

If `Set` is impredicative then the pair type itself lives in `Set`,
but if `A` lives in a larger universe, then it can't be projected out of the pair,
which requires setting `P` as `A`.

## Other Paradoxes

There's a variety of other features that yield inconsistencies in other ways,
some of them resembling the set-theoretical Russell's paradox.

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
we can define an inconsistency corresponding to Russell's paradox.

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

### Impredicativity + Excluded Middle + Large Elimination

Another type-theoretic encoding of Russell's paradox is Berardi's paradox [[6](#6)].
It begins with a retraction, which looks like half an isomorphism.

```
record _◁_ {ℓ} (A B : Set ℓ) : Set ℓ where
  constructor _,_,_
  field
    ϕ : A → B
    ψ : B → A
    retract : ψ ∘ ϕ ≡ id
open _◁_
```

We can easily prove `A ⊲ B → A ⊲ B` by identity.
If we postulate the axiom of choice, then we can push the universal quantification over `A ⊲ B` into the existential quantification of `A ⊲ B`,
yielding a `ϕ` and a `ψ` such that `ψ ∘ ϕ ≡ id` only when given some proof of `A ⊲ B`.
However, a retraction of powersets can be stipulated out of thin air using only the axiom of excluded middle.

```
record _◁′_ {ℓ} (A B : Set ℓ) : Set ℓ where
  constructor _,_,_
  field
    ϕ : A → B
    ψ : B → A
    retract : A ◁ B → ψ ∘ ϕ ≡ id
open _◁′_

postulate
  EM : ∀ {ℓ} (A : Set ℓ) → A ⊎ (¬ A)

t : ∀ {ℓ} (A B : Set ℓ) → ℘ A ◁′ ℘ B
t A B with EM (℘ A ◁ ℘ B)
... | inj₁  ℘A◁℘B =
      let ϕ , ψ , retract = ℘A◁℘B
      in ϕ , ψ , λ _ → retract
... | inj₂ ¬℘A◁℘B =
      (λ _ _ → ⊥) , (λ _ _ → ⊥) , λ ℘A◁℘B → ⊥-elim (¬℘A◁℘B ℘A◁℘B)

```

This time defining `U` to be `∀ X → ℘ X`, we can show that `℘ U` is a retract of `U`.
Here, we need an impredicative `Set` so that `U` can also live in `Set` and so that `U` quantifies over itself as well.
Note that we project the equality out of the record while the record is impredicative,
so putting `_≡_` in `Set` as well will help us avoid large eliminations for now.

```
projᵤ : U → ℘ U
projᵤ u = u U

injᵤ : ℘ U → U
injᵤ f X =
  let _ , ψ , _ = t X U
      ϕ , _ , _ = t U U
  in ψ (ϕ f)

projᵤ∘injᵤ : projᵤ ∘ injᵤ ≡ id
projᵤ∘injᵤ = retract (t U U) (id , id , refl)
```

Now onto Russell's paradox.
Defining `_∈_` to be `projᵤ` and letting `r ≝ injᵤ (λ u → ¬ u ∈ u)`,
we can show a curious inconsistent statement.

```
r∈r≡r∉r : r ∈ r ≡ (¬ r ∈ r)
r∈r≡r∉r = cong (λ f → f (λ u → ¬ u ∈ u) r) projᵤ∘injᵤ
```

To actually derive an inconsistency, we can derive functions `r ∈ r → (¬ r ∈ r)` and `(¬ r ∈ r) → r ∈ r` using substitution,
then prove falsehood the same way we did for negative inductive types.
However, the predicate in the substitution is `Set → Set`, which itself has type `Set₁`,
so these final steps do require unrestricted large elimination.
The complete proof can be found at [Berardi.html](/assets/agda/Berardi.html).

### Unrestricted Large Elimination (again)

Having impredicative inductive types that can be eliminated to large types can yield an inconsistency
without having to go through Hurkens' paradox.
To me, at least, this inconsistency is a lot more comprehensible.
This time, we use an impredicative representation of the ordinals [[7](#7)],
prove that they are well-founded with respect to some reasonable order on them,
then prove a falsehood by providing an ordinal that is obviously *not* well-founded.
This representation can be type checked using Agda's `NO_UNIVERSE_CHECK` pragma,
and normally it would live in `Set₁` due to one constructor argument type living in `Set₁`.

```
{-# NO_UNIVERSE_CHECK #-}
data Ord : Set where
  ↑_ : Ord → Ord
  ⊔_ : {A : Set} → (A → Ord) → Ord

data _≤_ : Ord → Ord → Set where
  ↑s≤↑s : ∀ {r s} → r ≤ s → ↑ r ≤ ↑ s
  s≤⊔f  : ∀ {A} {s} f (a : A) → s ≤ f a → s ≤ ⊔ f
  ⊔f≤s  : ∀ {A} {s} f → (∀ (a : A) → f a ≤ s) → ⊔ f ≤ s
```

An ordinal is either a successor ordinal, or a limit ordinal.
(The zero ordinal could be defined as a limit ordinal.)
Intuitively, a limit ordinal `⊔ f` is the supremum of all the ordinals returned by `f`.
This is demonstrated by the last two constructors of the preorder on ordinals:
`s≤⊔f` states that `⊔ f` is an upper bound of all the ordinals of `f`,
while `⊔f≤s` states that it is the *least* upper bound.
Finally, `↑s≤↑s` is simply the monotonicity of taking the successor of an ordinal with respect to the preorder.
It's possible to show that `≤` is indeed a preorder by proving its reflexivity and transitivity.

```
s≤s : ∀ {s : Ord} → s ≤ s
s≤s≤s : ∀ {r s t : Ord} → r ≤ s → s ≤ t → r ≤ t
```

From the preorder we define a corresponding strict order.

```
_<_ : Ord → Ord → Set
r < s = ↑ r ≤ s
```

In a moment, we'll see that `<` can be proven to be *wellfounded*,
which is equivalent to saying that in that there are no infinite descending chains.
Obviously, for there to be no such chains, `<` must at minimum be irreflexive — but it's not!
There is an ordinal that is strictly less than itself,
which we'll call the "infinite" ordinal,
defined as the limit ordinal of *all* ordinals,
which is possible due to the impredicativity of `Ord`.

```
∞ : Ord
∞ = ⊔ (λ s → s)

∞<∞ : ∞ < ∞
∞<∞ = s≤⊔f (λ s → s) (↑ ∞) s≤s
```

To show wellfoundedness, we use an *accessibility predicate*,
whose construction for some ordinal `s` relies on showing that all smaller ordinals are also accessible.
Finally, wellfoundness is defined as a proof that *all* ordinals are accessible,
using a lemma to extract accessibility of all smaller or equal ordinals.

```
record Acc (s : Ord) : Set where
  inductive
  pattern
  constructor acc
  field
    acc< : (∀ r → r < s → Acc r)

accessible : ∀ (s : Ord) → Acc s
accessible (↑ s) = acc (λ { r (↑s≤↑s r≤s) → acc (λ t t<r → (accessible s).acc< t (s≤s≤s t<r r≤s)) })
accessible (⊔ f) = acc (λ { r (s≤⊔f f a r<fa) → (accessible (f a)).acc< r r<fa })
```

But wait, we needed impredicativity *and* large elimination.
Where is the large elimination?

It turns out that it's hidden within Agda's pattern-matching mechanism.
Notice that in the limit case of `accessible`, we only need to handle the `s≤⊔f` case,
since this is the only case that could possibly apply when the left side is a successor and the right is an ordinal.
However, if you were to write this in plain CIC for instance,
you'd need to first explicitly show that the order could not be either of the other two constructors,
requiring showing that the successor and limit ordinals are provably distinct
(which itself needs large elimination, although this is permissible as an axiom),
then due to the proof architecture show that if two limit ordinals are equal, then their components are equal.
This is known as *injectivity of constructors*.
Expressing this property for ordinals requires large elimination,
since the first (implicit) argument of limit ordinals are in `Set`.

You can see how it works explicitly by writing the same proof in Coq,
where the above steps correspond to inversion followed by dependent destruction,
then printing out the full term.
The `s≤⊔f` subcase of the `⊔ f` case alone spans 50 lines!

In any case, we proceed to actually deriving the inconsistency, which is easy:
show that `∞` is in fact *not* accessible using `∞<∞`,
then derive falsehood directly.

```
¬accessible∞ : Acc ∞ → ⊥
¬accessible∞ (acc p) = ¬accessible∞ (p ∞ ∞<∞)

ng : ⊥
ng = ¬accessible∞ (accessible ∞)
```

The complete Agda proof can be found at [Ordinals.html](/assets/agda/Ordinals.html),
while a partial Coq proof of accessibility of ordinals can be found at [Ordinals.html](/assets/coq/Ordinals.html).

## Summary

The combinations of features that yield inconsistencies are:

* Type-in-type: `· ⊢ Set : Set`
* Impredicative `Set` and `Set₁` where `· ⊢ Set : Set₁`
* Strong impredicative pairs
* Impredicative inductive types + unrestricted large elimination
* Negative inductive types
* Non-strictly-positive inductive types + impredicativity
* Impredicativity + excluded middle + unrestricted large elimination
* Impredicative inductive types + unrestricted large elimination (again)

## Source Files

<p></p>
<details>
  <summary>Hurkens' paradox using type-in-type: <a href="/assets/agda/Hurkens.html">Hurkens.html</a></summary>
  <iframe src="/assets/agda/Hurkens.html" width="100%"></iframe>
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
<details>
  <summary>Berardi's paradox using impredicativity, excluded middle, and large elimination: <a href="/assets/agda/Berardi.html">Berardi.html</a></summary>
  <iframe src="/assets/agda/Berardi.html" width="100%"></iframe>
</details>
<details>
  <summary>Nonwellfoundedness of impredicative ordinals: <a href="/assets/agda/Ordinals.html">Ordinals.html</a></summary>
  <iframe src="/assets/agda/Ordinals.html" width="100%"></iframe>
</details>
<details>
  <summary>Accessibility of ordinals: <a href="/assets/coq/Ordinals.html">Ordinals.html</a></summary>
  <iframe src="/assets/coq/Ordinals.html" width="100%"></iframe>
</details>

<script>
  let details = document.querySelectorAll("details");
  details.forEach((detail) => {
    detail.hasBeenExpanded = false;
    detail.addEventListener("toggle", () => {
      if (!detail.hasBeenExpanded) {
        detail.hasBeenExpanded = true;
        let iframe = detail.getElementsByTagName("iframe")[0];
        let offset = iframe.src.includes("agda") ? 28 : 4; // Experimentally determined
        iframe.height = iframe.contentDocument.body.scrollHeight + offset + "px";
      }
    });
  });
</script>

<style>
#references + p {
  text-align: left;
  font-size: smaller;
}
</style>

## References

[<a name="1">1</a>] Hurkens, Antonius J. C. (TLCA 1995). _A Simplification of Girard's Paradox_. ᴅᴏɪ:[10.1007/BFb0014058](https://doi.org/10.1007/BFb0014058).
<br/>
[<a name="2">2</a>] Coquand, Thierry. (INRIA 1986). _An Analysis of Girard's Paradox_. [https://hal.inria.fr/inria-00076023](https://hal.inria.fr/inria-00076023).
<br/>
[<a name="3">3</a>] Burali–Forti, Cesare. (RCMP 1897). _Una questione sui numeri transfini_. ᴅᴏɪ:[10.1007/BF03015911](https://doi.org/10.1007/BF03015911).
<br/>
[<a name="4">4</a>] Gilbert, Gaëtan; Cockx, Jesper; Sozeau, Matthieu; Tabareau, Nicolas. (POPL 2019). _Definitional Proof-Irrelevance without K_. ᴅᴏɪ:[10.1145/3290316](https://doi.org/10.1145/3290316).
<br/>
[<a name="5">5</a>] Coquand, Theirry; Paulin, Christine. (COLOG 1988). _Inductively defined types_. ᴅᴏɪ:[10.1007/3-540-52335-9\_47](https://doi.org/10.1007/3-540-52335-9_47).
<br/>
[<a name="6">6</a>] Barbanera, Franco; Berardi, Stefano. (JFP 1996). _Proof-irrelevance out of excluded middle and choice in the calculus of constructions_. ᴅᴏɪ:[10.1017/S0956796800001829](https://doi.org/10.1017/S0956796800001829).
<br/>
[<a name="7">7</a>] Pfenning, Frank; Christine, Paulin-Mohring. (MFPS 1989). _Inductively defined types in the Calculus of Constructions_. ᴅᴏɪ:[10.1007/BFb0040259](https://doi.org/10.1007/BFb0040259).