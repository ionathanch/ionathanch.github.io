---
layout: post
title: "Notes on Equality"
excerpt_separator: "<!--more-->"
tags:
  - equality
  - type theory
---

## Propositional Equality

Propositional equality is a notion of equality on terms as a proposition in the theory.
Under the Curry–Howard correspondence between propositions and types, this means that equality is a type.
In most modern proof assistants, the equality type and its constructor is defined as an inductive type.

<!--more-->

```
data _≡_ {A : Type} (a : A) : A → Type where
  refl : a ≡ a
```

A proof of equality (i.e. a term whose type is a propositional equality) can then be eliminated
by the usual construct for deconstructing inductive data.

```
          Γ ⊢ p : a ≡ {A} b
          Γ (y : A) (x : a ≡ y) ⊢ P : Type
          Γ ⊢ d : P[y ↦ a][x ↦ refl]
─────────────────────────────────────────────────────────
    match p in _ ≡ y as x return P with
Γ ⊢ | refl ⇒ d                          : P[y ↦ b][x ↦ p]
    end
```

In the motive `P`, the target is bound to `x` and the right side of the equality is bound as an index to `y`.
Note that the left side is inferred from the type of `p` since it is a parameter.
In a core language with only indices and no parameters, the constructor would have more arguments.

```
data Eq : (A : Type) → A → A → Type where
  refl : (A : Type) → (a : A) → Eq A a a
```

This is reflected accordingly in the structure of the match expression.

```
    Γ ⊢ p : Eq A a b
    Γ (X : Type) (y : A) (z : A) (x : Eq X y z) ⊢ P : Type
    Γ (A : Type) (a : A) ⊢ d : P[X ↦ A][y ↦ a][z ↦ a][x ↦ refl A a]
──────────────────────────────────────────────────────────────────────────
    match p in Eq X y z as x return P with
Γ ⊢ | refl A a ⇒ d                         : P[X ↦ A][y ↦ a][z ↦ b][x ↦ p]
    end
```

## The J Eliminator

In a type theory without inductive data types, propositional equality can be defined in terms of formation,
introduction, elimination, and computation rules.

```
   Γ ⊢ a : A
   Γ ⊢ b : A
──────────────── ≡-form
Γ ⊢ a ≡ b : Type

    Γ ⊢ a : A
────────────────── ≡-intro
Γ ⊢ refl a : a ≡ a


Γ ⊢ p : a ≡ b
Γ ⊢ a : A
Γ ⊢ b : A
Γ ⊢ P : (y : A) → a ≡ y → Type
Γ ⊢ d : P a (refl a)
────────────────────────────── J-elim
     Γ ⊢ J P d p : P b p

────────────────────── J-comp
Γ ⊢ J P d (refl a) ⊳ d
```

Notice that J treats the left side of the equality as a "parameter".
An alternate formulation that doesn't do this would type `P` as `(x y : A) → x ≡ y → Type`.
J can also be treated as a function rather than a construct that takes a fixed number of arguments;
in that case, its type would be:

```
J : (A : Type) → (a b : A) →
    (P : (y : A) → a ≡ y → Type) →
    (d : P a (refl a)) → (p : a ≡ b) → P b p
```

### Uniqueness Rule for J

Some constructs also have an η-conversion or uniqueness rule; for equality,
this resembles a computation rule where the branch is a function application and
the target need not have the canonical `refl` form.

```
Γ ⊢ p : a ≡ b
Γ ⊢ a : A
Γ ⊢ b : A
Γ ⊢ P : (y : A) → a ≡ y → Type
Γ ⊢ e : (x : A) → (p : a ≡ x) → P x p
──────────────────────────────────────── J-uniq
Γ ⊢ J P (e a (refl a)) p ≈ e b p : P b p
```

(Note that this rule is mostly only useful if `e` is a neutral form.) However, adding this rule is dangerous,
because we can now derive the following chain of conversions under the appropriate assumptions and definitions:

```
A : Type
a b : A
p : a ≡ b
l (_ : A) (_ : a ≡ y) : A ≔ a
r (y : A) (_ : a ≡ y) : A ≔ y
P (_ : A) (_ : a ≡ y) : Type ≔ A
────────────────────────────────
a ≈ l b p                   by reduction
  ≈ J P (l a (refl a)) p    by uniq
  ≈ J P a p                 by reduction
  ≈ J P (r a (refl a)) p    by reduction
  ≈ r b p                   by uniq
  ≈ b : A                   by reduction
```

In short, given a propositional equality `a ≡ b`, we are able to derive a _definitional_ equality between `a` and `b`.
This is equality reflection, making the type theory extensional, and is known to cause undecidable type checking.

## The K Eliminator

A complementary eliminator that we can add is the K eliminator, which eliminates equalities with definitionally equal sides.
The it cannot be derived from J or the match expression, nor can it derive J.

```
Γ ⊢ p : a ≡ a
Γ ⊢ a : A
Γ ⊢ P : a ≡ a → Type
Γ ⊢ d : P (refl a)
──────────────────── K-elim
Γ ⊢ K P d p : P p

────────────────────── K-comp
Γ ⊢ K P d (refl a) ⊳ d
```

### UIP from K

K can be used to prove that all equalities on `a` are equal to `refl a`,
and together they prove that all equalities of the same type are equal,
known as the _unicity_ or _uniqueness of identity proofs_.
(UIP in turn, of course, directly implies RIP.)

```
A : Type
a : A
q : a ≡ a
P (p : a ≡ a) : Type ≔ refl a ≡ p
────────────────────────────────── RIP
K P (refl (refl a)) q : refl a ≡ q

A : Type
a b : A
p q : a ≡ b
P (b : A) (p : a ≡ b) : Type ≔ (q : a ≡ b) → p ≡ q
────────────────────────────────────────────────── UIP
J P (RIP A a) p q : p ≡ q

A : Type
a : A
q : a ≡ a
────────────────────────────────── RIP'
UIP A a a (refl a) q : refl a ≡ q
```

## Heterogenous Equality

The formation rule asserts that both sides of the equality must have the same type.
We can loosen this condition to create _heterogenous_ or _John Major_ equality, as coined by Conor McBride.
The eliminator is then adjusted accordingly.
Just as for the usual homogenous equality with J, this could also be equivalently defined as a inductive type.

```
   Γ ⊢ a : A
   Γ ⊢ b : B
──────────────── ≅-form
Γ ⊢ a ≅ b : Type

     Γ ⊢ a : A
─────────────────── ≅-intro
Γ ⊢ refl* a : a ≅ a

Γ ⊢ p : a ≅ b
Γ ⊢ a : A
Γ ⊢ b : B
Γ ⊢ P : (Y : Type) → (y : Y) → a ≅ y → Type
Γ ⊢ d : P A a (refl* a)
─────────────────────────────────────────── J*-elim
          Γ ⊢ J* P d p : P B b p

─────────────────────── J*-comp
Γ ⊢ J* P d (refl a) ⊳ d
```

### UIP from J*

Interestingly, UIP can be derived from J* alone,
since the types of the equalities on both sides of RIP need no longer be the same.

```
A B : Type
a : A
b : B
q : a ≅ b
P (B : Type) (b : B) (p : a ≅ b) : Type ≔ refl* a ≅ p
───────────────────────────────────────────────────── RIP*
J* P (refl* (refl* a)) q : refl* a ≅ q

A B : Type
a : A
b : B
p q : a ≅ b
P (b : A) (p : a ≅ b) : Type ≔ (q : a ≅ b) → p ≅ q
────────────────────────────────────────────────── UIP*
J* P (RIP* A B a b) p q : p ≅ q
```

### J and K from J*

We _cannot_ derive the usual J or K from J\*.
Intuitively, it seems like we should be able to prove K by substituting its motive over RIP*,
but the problem is that J\*'s motive abstracts over the type while K's doesn't,
leading to the proof getting "stuck" at `?` below.
We see a similar problem with trying to derive J where J's motive also doesn't abstract over the type.

```
A : Type
a b : A
p : a ≅ b
P : (A : Type) → A → Type
Q (B : Type) (b : B) (_ : a ≅ b) : Type ≔ P A a → P B b
id (pa : P A a) : P A a ≔ pa
─────────────────────────────────────────────────────── subst*
J* Q id p : P A a → P B b

A : Type
a : A
p : a ≅ a
P : a ≅ a → Type
d : P (refl* a)
───────────────────────────────────────────────────── K?
subst* (a ≅ a) (refl* a) p (RIP* A A a a p) ? d : P p

A : Type
a b : A
p : a ≅ b
P : (y : A) → a ≅ y → Type
d : P a (refl a)
────────────────────────── J?
J* ? d p : P b p
```

## Substitution/Transport

The idea behind substitution (or in the homotopic metaphor, transport) is that given some equality between `a` and `b`,
within some proposition `P`, we can substitute `a` for `b` (correspondingly, given a path between `a` and `b`,
we can transport `P` from `a` to `b`).
As in the last section, we can derive this from the J eliminator.

```
A : Type
a b : A
p : a ≡ b
P : A → Type
Q (y : A) (_ : a ≡ y) : Type ≔ P a → P y
id (pa : P a) : P a ≔ pa
──────────────────────────────────────── subst'
J Q id p : P a → P b
```

Alternatively, we can define subst as the core eliminator for equality.

```
Γ ⊢ p : a ≡ b
Γ ⊢ a : A
Γ ⊢ b : A
Γ ⊢ P : A → Type
───────────────────────── subst-elim
Γ ⊢ subst P p : P a → P b
```

### J and K from Substitution

We can derive all of the nice properties of equality from subst as we do from J
(such as symmetry, transitivity, and congruence), but we cannot derive J itself.
However, with the help of UIP (either as an axiom or through K), we can.
The idea is that using RIP, if we have an equality `p : a ≡ b`,
we can substitute from `P a (refl a)` to `P a p`,
and then we can substitute from there to `P b p` via `p`.

```
A : Type
a b : A
p : a ≡ b
P : (y : A) → a ≡ y → Type
d : P a (refl a)
Q (y : A) : Type ≔ (p : a ≡ y) → P y p
e (p : a ≡ a) : P a p ≔ subst (P a) (RIP A a p) d
───────────────────────────────────────────────── J
subst Q p e p : P b p
```

On the other hand, suppose we only have RIP or UIP with no K.
We can then easily recover K with a single application of subst.

```
A : Type
a : A
p : a ≡ a
P : a ≡ a → Type
d : P (refl a)
─────────────────────────── K
subst P (RIP A a p) d : P p
```

## Mid-Summary

Below summarizes the various relationships among J, K, substitution, and RIP/UIP.
If you have the left side of the turnstile, then you may derive the right side.

```
J          ⊢ subst'
K          ⊢ RIP
RIP, J     ⊢ UIP
UIP        ⊢ RIP
RIP, subst ⊢ J, K
K,   subst ⊢ J
J*         ⊢ RIP*, UIP*, subst*
J*         ⊬ J, K
```

## Extensional Equality and Univalence

* Give typing rules for equality reflection and univalence
* Give example of contradiction if we have both

## Function Extensionality

* Give typing rule for funext
* Give derivation from equality reflection and η-convertibility

## Quotient Types

* Give typing rules for quotient types

## Higher Inductive Types

* Give typing rules (?) for HITs
* Define quotients in terms of HITs

## Cubical Type Theory

* No

## Appendix: Level-Heterogenous Equality

This is a generalization of heterogenous equality to be heterogenous in the universe level as well.

```
Γ ⊢ ℓ₁ : Level
Γ ⊢ ℓ₂ : Level
Γ ⊢ A : Set ℓ₁
Γ ⊢ B : Set ℓ₂
Γ ⊢ a : A
Γ ⊢ b : B
───────────────────────── ≊-form
Γ ⊢ a ≊ b : Set (ℓ₁ ⊔ ℓ₂)

Γ ⊢ a : A
Γ ⊢ A : Set ℓ
Γ ⊢ ℓ : Level
────────────────── ≊-intro
Γ ⊢ refl a : a ≊ a

Γ ⊢ p : a ≊ b
Γ ⊢ a : A
Γ ⊢ b : B
Γ ⊢ A : Set ℓ₁
Γ ⊢ B : Set ℓ₂
Γ ⊢ P : (ℓ : Level) → (Y : Set ℓ) → (y : Y) → a ≊ y → Type
Γ ⊢ d : P ℓ₁ A a (refl a)
────────────────────────────────────────────────────────── H-elim
Γ ⊢ H P d p : P ℓ₂ B b p

Γ ⊢ p : a ≊ b
Γ ⊢ a : A
Γ ⊢ b : B
Γ ⊢ A B : Set ℓ
Γ ⊢ P : (Y : Set ℓ) → (y : Y) → a ≊ y → Type
Γ ⊢ d : P A a (refl a)
──────────────────────────────────────────── I-elim
Γ ⊢ I P d p : P B b p

Γ ⊢ p : a ≊ b
Γ ⊢ a b : A
Γ ⊢ P : (y : A) → a ≊ y → Type
Γ ⊢ d : P a (refl a)
────────────────────────────── J-elim
Γ ⊢ J P d p : P b p

Γ ⊢ p : a ≊ a
Γ ⊢ P : a ≊ a → Type
Γ ⊢ d : P (refl a)
──────────────────── K-elim
Γ ⊢ K P d p : P p
```
