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
  * [Congruence with Dependent Functions](#congruence-with-dependent-functions)
  * [More Computation for Congruence](#more-computation-for-congruence)
* [Mid-Summary](#mid-summary)
* [Extensional Equality](#extensional-equality)
* [Function Extensionality](#function-extensionality)
* [Squash Types](#squash-types)
* [Quotient Types](#quotient-types)
  * [Effectiveness](#effectiveness)
  * [Squashes from Quotients](#squashes-from-quotients)
* [Higher Inductive Types](#higher-inductive-types)
* [Appendix A: Other Relevant Typing Rules](#appendix-a-other-relevant-typing-rules)
* [Appendix B: Level-Heterogeneous Equality](#appendix-b-level-heterogeneous-equality)

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
───────────────────────────────────── J-uniq
Γ ⊢ J P (e a (refl a)) p ≈ e b p
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
This is _equality reflection_, making the type theory extensional, and is known to cause undecidable type checking.

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

Alternatively, we can define substitution as the core eliminator for equality.

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
We can then easily recover K with a single application of substitution.

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

### Congruence with Dependent Functions

When using homogeneous equality, the function applied in congruence must be nondependent for both sides of the equality
to have the same type.
If we use heterogeneous equality, we can allow dependent functions.
Alternatively, since we already have the proof of equality of the elements that the function is applied over,
surely their types must be equal as well.
We can then use substitution to "fix" the type of one side of the resultant equality.
Instead of calling it dependent congruence, we'll call it `apd` in the HoTT tradition.

```
Γ ⊢ P : A → Type
Γ ⊢ p : a ≡ b
Γ ⊢ a : A
Γ ⊢ b : A
Γ ⊢ f : (x : A) → P x
───────────────────────────────────── apd-elim
Γ ⊢ apd P f p : subst P p (f a) ≡ f b

───────────────────────────────── apd-comp
Γ ⊢ apd P f (refl a) ⊳ refl (f a)
```

Unlike congruence, `apd` can only be proven from J, not substitution alone.

```
A : Type
a b : A
P : A → Type
f : (x : A) → P x
p : a ≡ b
──────────────────────────────────────────────────── apd'
Q (y : A) (p : a ≡ y) : Type ≔ subst P p (f a) ≡ f y
----------------------------------------------------
J Q (refl (f a)) p : subst P p (f a) ≡ f b
```

TODO: Can J be proven from `subst` and `apd` alone?

### More Computation for Congruence

Notice that congruence only computes on reflexivity.
We may want to also compute congruence when `f` is constant with respect to its argument:
both sides of the resulting type are definitionally equal, and we expect that it computes to a reflexivity.
If we allow using convertibility as a premise to reduction (which may not be possible in all type systems),
we can add the following computation rule.
If congruence carried all of the relevant types with it, as is the case with `cong'`,
avoiding typing premises is possible as well.

```
Γ ⊢ p : a ≡ b
Γ ⊢ a : A
Γ ⊢ b : A
Γ ⊢ f : A → B
Γ ⊢ f a ≈ f b
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
J          ⊢ apd
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

## Extensional Equality

TODO: Add blurb about extensional equality

```
Γ ⊢ a : A
Γ ⊢ b : A
Γ ⊢ p : a ≡ b
───────────── ≡-reflect
Γ ⊢ a ≈ b : A
```

## Function Extensionality

There are often more equalities that we wish to be able to express than can be proven with just reflexivity and its eliminators.
One of these is function extensionality, which equates two functions when they return the same output for each input.
In other words, functions are then observationally equivalent.
Without extensionality, functions are only provably equal when they are implemented in definitionally equal ways.

```
Γ ⊢ f : (x : A) → B x
Γ ⊢ g : (x : A) → B x
Γ ⊢ h : (x : A) → f x ≡ g x
─────────────────────────── funext
Γ ⊢ funext f g h : f ≡ g
```

Unfortunately, there's no satisfactory way of computing on the equality from function extensionality,
because our eliminators only compute on reflexivity.
In other words, adding function extensionality breaks _canonicity_, because the canonical proof of equality,
reflexivity, is no longer the _only_ closed proof of equality.

On the other hand, we can derive function extensionality from equality reflection using η-conversion of functions.
Let `Γ = (f g : (x : A) → B x) (h : (x : A) → f x ≡ g x)`.
The following derivation tree sketches out how a proof of `f ≡ g` can be derived using `h`.

```
         Γ ⊢ h : (x : A) → f x ≡ g x
         ─────────────────────────── λ-elim
         Γ (x : A) ⊢ h x : f x ≡ g x
         ─────────────────────────── ≡-reflect
            Γ (x : A) ⊢ f x ≈ g x
───────────────────────────────────────────── λ-intro, λ-uniq
Γ ⊢ f ≈ λ (x : A) ⇒ f x ≈ λ (x : A) ⇒ g x ≈ g
───────────────────────────────────────────── ≡-intro, conv
             Γ ⊢ refl f : f ≡ g
```

## Squash Types

Sometimes we would like to treat proofs of a certain proposition as being irrelevant so that
they are all propositionally equal.
This can be done by _squashing_ the type and its term(s), and restricting manipulating the terms in ways that
do not allow us to distinguish among them.
Given some function `f` from `A` to an output type that only depends on the squashed input,
we can "lift" that function to one that takes a squashed `‖A‖` as input instead.

```
Γ ⊢ A : Type
────────────── sq-form
Γ ⊢ ‖A‖ : Type

Γ ⊢ a : A
───────────── sq-intro
Γ ⊢ |a| : ‖A‖

Γ ⊢ a : A
Γ ⊢ b : A
──────────────────────── sq-ax
Γ ⊢ sqax a b : |a| ≡ |b|

Γ ⊢ P : ‖A‖ → Type
Γ ⊢ f : (x : A) → P |x|
Γ ⊢ p : (x y : A) → f x ≅ f y
────────────────────────────── sq-elim
Γ ⊢ unsq P p f : (x : ‖A‖) → P x

────────────────────── sq-comp
Γ ⊢ unsq P f |a| ⊳ f a
```

In addition to the usual formation, introduction, elimination, and computation rules, we also have an axiom that states
that any two squashed values of the squashed type are equal.
Notice that this also breaks canonicity of propositional equality.

Because the function applied in the eliminator is dependent, the condition that it acts identically on all elements
is a heterogeneous equality rather than a homogeneous one.
However, because the return type of the function can only depend on the squashed value,
and we know that the squashed values are all equal by `sqax`, we can alternatively replace `f x ≅ f y` by
`subst P (sqax x y) (f x) ≡ f y`.
On the other hand, since substitution does not reduce on `sqax`, if `P` is nondependent, the condition does not become
`f x ≡ f y` as we would intuitively expect, not unless we have the extra computation rule for congruence.

## Quotient Types

Instead of treating _all_ terms of a type as equal, perhaps we would like to treat only _some_ of them as equal.
Quotient types allow us to do so with a quotient relation `~`: two quotiented terms are equal if they are related.
This is analogous to quotient sets, where an equivalence relation divides up the members of a set into equivalence classes.
Like with squash types, the eliminator allows "lifting" a function `f` on `A` to a function on the quotient space `A⧸~`.

```
Γ ⊢ A : Type
Γ ⊢ ~ : A → A → Type
──────────────────── Q-form
Γ ⊢ A⧸~ : Type

Γ ⊢ a : A
Γ ⊢ ~ : A → A → Type
──────────────────── Q-intro
Γ ⊢ [a]˷ : A⧸~

Γ ⊢ a : A
Γ ⊢ b : A
Γ ⊢ ~ : A → A → Type
────────────────────────────────── Q-ax
Γ ⊢ Qax˷ a b : a ~ b → [a]˷ ≡ [b]˷

Γ ⊢ P : A⧸~ → Type
Γ ⊢ ~ : A → A → Type
Γ ⊢ f : (x : A) → P [x]˷
Γ ⊢ p : (x y : A) → (r : x ~ y) → f x ≅ f y
─────────────────────────────────────────── Q-elim
Γ ⊢ Qelim˷ P p f : (x : A⧸~) → P x

─────────────────────────── Q-comp
Γ ⊢ Qelim˷ P p f [a]˷ ⊳ f a
```

Also like with squash types, `Qax` can yield a noncanonical closed proof of equality.
We can also replace `f x ≅ f y` by `subst P (Qax˷ x y r) (f x) ≡ f y` in the condition of the eliminator
just as was done for squash types, with the same problem of substitution not reducing on `Qax`
unless we have the extra computation rule for congruence.

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
--------------------------------------------------
pe.~sym (coe lemma₂ (pe.~refl a)) : a ~ b
```

### Squashes from Quotients

Squashes can be seen as a special case of quotients where the quotient relation is trivially true.

```
a ~ b ≔ Unit
∥A∥ ≔ A/~
|a| ≔ [a]˷
sqax a b ≔ Qax˷ a b unit
unsq P p f ≔ Qelim˷ P (λ x y _ ⇒ p x y) f
```

## Higher Inductive Types

Higher inductive types are inductive types with quotient-like behaviour: with _equality constructors_,
you can specify new equalities between your elements.
One popular HIT is the interval, which consists of two endpoints and a path between them

```
data 𝕀 : Type where
  𝟎 : 𝕀
  𝟏 : 𝕀
  seg : 𝟎 ≡ 𝟏
```

The eliminator for the interval requires the same kind of condition as quotient types:
when eliminating an element of the interval with some function on an endpoint,
the eliminator must treat both endpoints equally.
On top of that, applying the eliminator to both sides of the segment should yield exactly the same proof that
both endpoints are treated equally.

```
Γ ⊢ P : 𝕀 → Type
Γ ⊢ b₀ : P 𝟎
Γ ⊢ b₁ : P 𝟏
Γ ⊢ s : b₀ ≅ b₁
───────────────────────────────────── 𝕀-elim
Γ ⊢ 𝕀-elim : P b₀ b₁ s : (i : 𝕀) → P i

─────────────────────────── 𝕀-comp₀
Γ ⊢ 𝕀-elim P b₀ b₁ s 𝟎 ⊳ b₀

─────────────────────────── 𝕀-comp₁
Γ ⊢ 𝕀-elim P b₀ b₁ s 𝟏 ⊳ b₁

─────────────────────────────────── 𝕀-comp-seg
Γ ⊢ apd P (𝕀-elim P b₀ b₁ s) seg ⊳ s
```

Again, use of heterogeneous equality can be replaced by a homogeneous one if we do the appropriate substitution;
`s` would then have type `subst P seg b₀ ≡ b₁`.

TODOs:
* Give rules (?) for HITs
* Give elimination principles for quotients defined as HITs

```
data _⧸_ (A : Type) (~ : A → A → Type) : Type where
  [_]˷ : (a : A) → A⧸~
  Qax : (a b : A) → a ~ b → [a]˷ ≡ [b]˷
```

## Cubical Type Theory

TODOs:
* Introduce the interval, interval elements, paths
* Show that paths can be used as a propositional equality
* Prove funext using paths
* Other fun properties of paths

## Appendix A: Other Relevant Typing Rules

Below are the typing rules for functions and a typing rule that uses convertibility to coerce a term to a another type.
We assume that `Type` is well-behaved and causes no problems with consistency.
Convertibility (`≈`) is defined to be the reflexive, symmetric, compatible closure of multi-step reduction (`⊳`) and
whatever other uniqueness rules that are defined throughout.
Convertibility is generally untyped and does not rely on typing judgements, except for J-uniq.

```
Γ ⊢ a : A
Γ ⊢ B : Type
Γ ⊢ A ≈ B
──────────── conv
Γ ⊢ a : B

Γ ⊢ A : Type
Γ (x : A) ⊢ B : Type
──────────────────────── λ-form
Γ ⊢ (x : A) → B : Type

Γ ⊢ A : Type
Γ (x : A) ⊢ e : B
───────────────────────────────── λ-intro
Γ ⊢ λ (x : A) ⇒ e : (x : A) → B

Γ ⊢ e₁ : (x : A) → B
Γ ⊢ e₂ : A
───────────────────── λ-elim
Γ ⊢ e₁ e₂ : B[x ↦ e₂]

──────────────────────────────────── λ-comp
Γ ⊢ (λ (x : A) ⇒ e₁) e₂ ⊳ e₁[x ↦ e₂]

Γ (x : A) ⊢ e₁ ≈ e₂ x 
───────────────────────── λ-uniq
Γ ⊢ (λ (x : A) ⇒ e₁) ≈ e₂
```

## Appendix B: Level-Heterogeneous Equality

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
