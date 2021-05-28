---
layout: post
title: "Notes on Propositional Equality"
excerpt_separator: "<!--more-->"
tags:
  - equality
  - type theory
---

Propositional equality is a notion of equality on terms as a proposition in the theory.
Under the Curry–Howard correspondence between propositions and types, this means that equality is a type.

<!--more-->

## Table of Contents

* [Inductively-Defined Equality](#inductively-defined-equality)
* [The J Eliminator](#the-j-eliminator)
  - [Uniqueness Rule for J](#uniqueness-rule-for-j)
* [The K Eliminator](#the-k-eliminator)
  * [UIP from K](#uip-from-k)
* [Heterogeneous Equality](#heterogeneous-equality)
  * [UIP from J*](#uip-from-j)
  * [J and K from J*](#j-and-k-from-j)
* [Substitution/Transport](#substitutiontransport)
  * [J and K from Substitution](#j-and-k-from-substitution)
* [Congruence and Coercion](#congruence-and-coercion)
  * [More Computation for Congruence](#more-computation-for-congruence)
* [Mid-Summary](#mid-summary)
* [Extensional Equality and Univalence](#extensional-equality-and-univalence)
* [Function Extensionality](#function-extensionality)
* [Quotient Types](#quotient-types)
  * [Effectiveness](#effectiveness)
* [Higher Inductive Types](#higher-inductive-types)
* [Appendix: Level-Heterogeneous Equality](#appendix-level-heterogeneous-equality)

## Inductively-Defined Equality

In most modern proof assistants, the equality type and its constructor is defined as an inductive type.

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
J' : (A : Type) → (a b : A) →
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
because we can now derive the following chain of conversions (below the dashed bar) under the appropriate assumptions
(above the solid bar) and definitions (between the two bars):

```
A : Type
a b : A
p : a ≡ b
────────────────────────────────
l (_ : A) (_ : a ≡ y) : A ≔ a
r (y : A) (_ : a ≡ y) : A ≔ y
P (_ : A) (_ : a ≡ y) : Type ≔ A
--------------------------------
a ≈ l b p                   by reduction
  ≈ J P (l a (refl a)) p    by uniq
  ≈ J P a p                 by reduction
  ≈ J P (r a (refl a)) p    by reduction
  ≈ r b p                   by uniq
  ≈ b                       by reduction
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

K can be used to prove that all equalities on `a` are equal to `refl a` (RIP),
and together they prove that all equalities of the same type are equal,
known as the _unicity_ or _uniqueness of identity proofs_ (UIP).
(We treat RIP as a function whose parameters are the assumptions above the solid bar.)
UIP in turn, of course, directly implies RIP.

```
A : Type
a : A
q : a ≡ a
────────────────────────────────── RIP
P (p : a ≡ a) : Type ≔ refl a ≡ p
----------------------------------
K P (refl (refl a)) q : refl a ≡ q

A : Type
a b : A
p q : a ≡ b
────────────────────────────────────────────────── UIP
P (b : A) (p : a ≡ b) : Type ≔ (q : a ≡ b) → p ≡ q
--------------------------------------------------
J P (RIP A a) p q : p ≡ q

A : Type
a : A
q : a ≡ a
────────────────────────────────── RIP'
UIP A a a (refl a) q : refl a ≡ q
```

## Heterogeneous Equality

The formation rule asserts that both sides of the equality must have the same type.
We can loosen this condition to create _heterogeneous_ or _John Major_ equality, as coined by Conor McBride.
The eliminator is then adjusted accordingly.
Just as for the usual homogeneous equality with J, this could also be equivalently defined as a inductive type.

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
───────────────────────────────────────────────────── RIP*
P (B : Type) (b : B) (p : a ≅ b) : Type ≔ refl* a ≅ p
-----------------------------------------------------
J* P (refl* (refl* a)) q : refl* a ≅ q

A B : Type
a : A
b : B
p q : a ≅ b
────────────────────────────────────────────────── UIP*
P (b : A) (p : a ≅ b) : Type ≔ (q : a ≅ b) → p ≅ q
--------------------------------------------------
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
─────────────────────────────────────────────────────── subst*
Q (B : Type) (b : B) (_ : a ≅ b) : Type ≔ P A a → P B b
id (pa : P A a) : P A a ≔ pa
-------------------------------------------------------
J* Q id p : P A a → P B b

A : Type
a : A
P : a ≅ a → Type
d : P (refl* a)
p : a ≅ a
───────────────────────────────────────────────────── K?
subst* (a ≅ a) (refl* a) p (RIP* A A a a p) ? d : P p

A : Type
a b : A
P : (y : A) → a ≅ y → Type
d : P a (refl a)
p : a ≅ b
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
P : A → Type
p : a ≡ b
──────────────────────────────────────── subst'
Q (y : A) (_ : a ≡ y) : Type ≔ P a → P y
id (pa : P a) : P a ≔ pa
----------------------------------------
J Q id p : P a → P b
```

Alternatively, we can define subst as the core eliminator for equality.

```
Γ ⊢ p : a ≡ b
Γ ⊢ a b : A
Γ ⊢ P : A → Type
───────────────────────── subst-elim
Γ ⊢ subst P p : P a → P b

──────────────────────────── subst-comp
Γ ⊢ subst P (refl a) pa ⊳ pa
```

### J and K from Substitution

We can derive all of the nice properties of equality from subst as we do from J
(such as symmetry, transitivity, and congruence), but we cannot derive J itself.
However, with the help of UIP (either as an axiom or through K), we can.
The idea is that using RIP, if we have an equality `p : a ≡ a`,
we can substitute from `P a (refl a)` to `P a p`,
and then we can substitute from there to `P b p` via `p`.

```
A : Type
a b : A
P : (y : A) → a ≡ y → Type
d : P a (refl a)
p : a ≡ b
───────────────────────────────────────────────── J'
Q (y : A) : Type ≔ (p : a ≡ y) → P y p
e (p : a ≡ a) : P a p ≔ subst (P a) (RIP A a p) d
-------------------------------------------------
subst Q p e p : P b p
```

On the other hand, suppose we only have RIP or UIP with no K.
We can then easily recover K with a single application of subst.

```
A : Type
a : A
P : a ≡ a → Type
d : P (refl a)
p : a ≡ a
─────────────────────────── K'
subst P (RIP A a p) d : P p
```

## Congruence and Coercion

Congruence of equality and coercion of a term along an equality of types can both be proven from substitution alone.

```
A B : Type
a b : A
f : A → B
p : a ≡ b
────────────────────────────────── cong'
P (y : A) : Type ≔ f a ≡ f y
----------------------------------
subst P p (refl (f a)) : f a ≡ f b

A B : Type
p : A ≡ B
a : A
──────────────────────── coe'
id (T : Type) : Type ≔ T
------------------------
subst id p a : B
```

On the other hand, we could define these two properties as built-in eliminators for equality.
If we deal only in homogeneous equality, then the function applied in congruence must be non-dependent,
but it can be dependent if we instead typed it as a heterogeneous equality.

```
Γ ⊢ p : a ≡ b
Γ ⊢ a : A
Γ ⊢ b : A
Γ ⊢ f : A → B
──────────────────────── cong-elim
Γ ⊢ cong f p : f a ≡ f b

Γ ⊢ p : A ≡ B
Γ ⊢ A : Type
Γ ⊢ B : Type
───────────────── coe-elim
Γ ⊢ coe p : A → B

──────────────────────────────── cong-comp
Γ ⊢ cong f (refl a) ⊳ refl (f a)

────────────────────── coe-comp
Γ ⊢ coe (refl A) a ⊳ a
```

These two, in turn, can be used to define substitution.

```
A : Type
a b : A
P : A → Type
p : a ≡ b
────────────────────────── subst'
coe (cong P p) : P a → P b
```

### More Computation for Congruence

Notice that congruence only computes on reflexivity.
We may want to also compute congruence when `f` is constant with respect to its argument:
both sides of the resulting type are definitionally equal, and we expect that it computes to a reflexivity.
If we allow using convertibility as a premise to reduction (which may not be possible in all type systems),
we can add the following computation rule.
If congruence carried all of the relevant types with it, as is the case with `cong'`,
avoiding typing premises and typed convertibility is possible as well.

```
Γ ⊢ p : a ≡ b
Γ ⊢ a : A
Γ ⊢ b : A
Γ ⊢ f : A → B
Γ ⊢ f a ≈ f b : B
───────────────────────── cong-comp'
Γ ⊢ cong f p ⊳ refl (f a)

Γ ⊢ f a ≈ f b
────────────────────────────────── cong'-comp'
Γ ⊢ cong' A B a b f p ⊳ refl (f a)
```

If substitution is defined by coercion and congruence, then substitution will also compute
when the motive `P` is constant with respect to `a` and `b`.
Furthermore, J defined using substition will compute this way as well.
Note that this is orthogonal to UIP: congruence applied to an equality `p : a ≡ a` not (yet) definitionally equal to
`refl a` will not compute without this rule even with RIP.

## Mid-Summary

Below summarizes the various relationships among J, K, substitution, and RIP/UIP.
If you have the left side of the turnstile, then you may derive the right side.

```
J          ⊢ subst
K          ⊢ RIP
RIP, J     ⊢ UIP
UIP        ⊢ RIP
RIP, subst ⊢ J, K
K,   subst ⊢ J
J*         ⊢ RIP*, UIP*, subst*
J*         ⊬ J, K
subst      ⊢ coe, cong
coe, cong  ⊢ subst
```

Equality also satisfies the two other properties of equivalence relations: symmetry and transitivity.
We prove them here with substitution, but they can be proven directly using J as well.

```
A : Type
a b : A
p : a ≡ b
────────────────────────── sym
P (y : A) : Type ≔ y ≡ a
--------------------------
subst P p (refl a) : b ≡ a

A : Type
a b c : A
p : a ≡ b
q : b ≡ c
──────────────────────── trans
P (y : A) : Type ≔ a ≡ y
------------------------
subst P q p : a ≡ c
```

## Extensional Equality and Univalence

* Give typing rules for equality reflection and univalence
* Give example of contradiction if we have both

## Function Extensionality

* Give typing rule for funext
* Give derivation from equality reflection and η-convertibility

## Quotient Types

TODO: Blurb introducing and explaining quotient types

```
Γ ⊢ A : Type
Γ ⊢ ~ : A → A → Type
──────────────────── Q-form
Γ ⊢ A⧸~ : Type

Γ ⊢ a : A
Γ ⊢ ~ : A → A → Type
──────────────────── Q-intro
Γ ⊢ [a]˷ : A⧸~

Γ ⊢ a b : A
Γ ⊢ ~ : A → A → Type
────────────────────────────────── Q-ax
Γ ⊢ Qax˷ a b : a ~ b → [a]˷ ≡ [b]˷

Γ ⊢ a : A⧸~
Γ ⊢ P : A⧸~ → Type
Γ ⊢ ~ : A → A → Type
Γ ⊢ f : (x : A) → P [x]˷
Γ ⊢ p : (x y : A) → (r : x ~ y) → f x ≅ f y
─────────────────────────────────────────── Q-elim
Γ ⊢ Qelim˷ P p f a : P a

─────────────────────────── Q-comp
Γ ⊢ Qelim˷ P p f [a]˷ ⊳ f a
```

Because the function applied in the eliminator could be a dependent function, the condition that it acts identically
on related elements is a heterogeneous equality rather than a homogeneous one.
However, we _know_ that the return types of the function must be equal, since they only depend on the quotiented elements,
and quotients of related elements are equal by `Qax`.
Therefore, we could alternatively replace `f x ≅ f y` by `subst P (Qax˷ x y r) (f x) ≡ f y`.

When `P` is constant with respect to its argument, we expect that the condition should become `f x ≡ f y`.
However, this does not hold, since substitution does not reduce on the equality from `Qax`.
The problem arises from quotients destroying _canonicity_ of equality: with the existence of `Qax`,
there are now closed proofs of equality that are not constructed by `refl`.
This specific problem with a constant `P` can be circumvented by the additional computation rule for congruence,
but the larger problem of noncanonicity still exists.

### Effectiveness

An important property that quotient types can have is _effectiveness_:
the only elements belonging to an equivalence class of a quotiented element with respect to propositional equality
are the ones related by the quotient relation.
For a quotient to be effective, the relation must be an equivalence relation; that is,
it must be reflexive, symmetric, and transitive.
It also has to satisfy a weak form of propositional extensionality: if `x ~ z ↔ y ~ z`, then `x ~ z ≡ y ~ z`.
This can be derived from full propositional extensionality, which equates any two bi-implicated relations.
We stick to only the weak extensionality, which is all we need, and collect all these facts in a record type.

```
record PropEquiv (A : Type) (~ : A → A → Type) : Type where
  ~refl : (x : A) → x ~ x
  ~sym : (x y : A) → x ~ y → y ~ x
  ~trans : (x y z : A) → x ~ y → y ~ z → x ~ z
  ~ext : (x y z : A) → (y ~ z → x ~ z) → (x ~ z → y ~ z) → x ~ z ≡ y ~ z
```

With these, we can prove a lemma we will need later: if `x ~ y`, then for any `z`, `x ~ z ≡ y ~ z`.

```
A : Type
~ : A → A → Type
pe : PropEquiv A ~
z x y : A
r : x ~ y
────────────────────────────────────────────────────── lemma₁
yzxz : y ~ z → x ~ z ≔ pe.~trans x y z r
xzyz : x ~ z → y ~ z ≔ pe.~trans y x z (pe.~sym x y r)
------------------------------------------------------
pe.~ext x y z yzxz xzyz : x ~ z ≡ y ~ z
```

Let `a` be some particular `A` we can quotient by `~`, and let `P : A → Type` be a function defined by `λ x ⇒ x ~ a`.
Then we can "lift" `P` to a function `P̂ : A⧸~ → Type` using `Qelim˷`, since `lemma₁` gives us the required condition that
if `x ~ y` then `P x ≡ P y` when instantiated with `a`.

Now we are ready to tackle effectiveness.
Suppose we have `p : [a]˷ ≡ [b]˷`, where `~` is a propositional equivalence relation.
We wish to show that `a ~ b`.
By congruence on `p`, using our lifted function, we have that `P̂ [a]˷ ≡ P̂ [b]˷`, which computes to `a ~ a ≡ b ~ a`.
Finally, by reflexivity of `~`, coercion along the equality, and symmetry of `~`, we obtain `a ~ b`.
The full proof is outlined below.

```
A : Type
~ : A → A → Type
pe : PropEquiv A ~
a b : A
p : [a]˷ ≡ [b]˷
────────────────────────────────────────────────── eff
P (x : A) : Type ≔ x ~ a
Q (_ : A⧸~) : Type ≔ Type
P̂ (x : A⧸~): Type ≔ Qelim˷ Q (lemma₁ A ~ pe a) P x
lemma₂ : a ~ a ≡ b ~ a ≔ cong P̂ p
id (T : Type) : Type ≔ T
--------------------------------------------------
pe.~sym (coe lemma₂ (pe.~refl a)) : a ~ b
```

## Higher Inductive Types

* Give typing rules (?) for HITs
* Define quotients in terms of HITs

## Cubical Type Theory

* No

## Appendix: Level-Heterogeneous Equality

This is a generalization of heterogeneous equality to be heterogeneous in the universe level as well.

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
