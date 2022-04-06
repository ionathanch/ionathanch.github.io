---
layout: post
title: "Notes on W Types and Inductive Types"
excerpt_separator: "<!--more-->"
tags:
  - W type
  - well-founded trees
  - inductive types
  - type theory
categories:
  - Notes
---

<!--more-->

## Table of Contents

* [Well-Founded Trees](#well-founded-trees)
  * [Example: Ordinals with a twist](#example-ordinals-with-a-twist)
* [Indexed Well-Founded Trees](#indexed-well-founded-trees)
  * [Example: Mutual inductives — even and odd naturals](#example-mutual-inductives--even-and-odd-naturals)
  * [Example: Nonuniformly parametrized inductive — accessibility predicate](#example-nonuniformly-parametrized-inductive--accessibility-predicate)
  * [Example: Nonuniformly parametrized inductive — perfect trees](#example-nonuniformly-parametrized-inductive--perfect-trees)
* [Indexed Inductives and Fording](#indexed-inductives-and-fording)
  * [Example: Function images](#example-function-images)
  * [Example: The finite sets](#example-the-finite-sets)
* [Nested Inductives](#nested-inductives)
  * [Example: Finitely branching trees](#example-finitely-branching-trees)
  * [Non-example: Truly nested inductive — bushes](#non-example-truly-nested-inductive--bushes)
* [Inductive–Inductives](#inductiveinductives)
  * [Example: Intrinsically well-formed contexts and types](#example-intrinsically-well-formed-contexts-and-types)
* [Inductive–Recursives](#inductiverecursives)
* [Indexed Well-Founded Trees as Canonized Well-Founded Trees](#indexed-well-founded-trees-as-canonized-well-founded-trees)

## Well-Founded Trees

```
data W (A : 𝒰) (B : A → 𝒰) : 𝒰 where
  sup : ∀ a → (B a → W A B) → W A B
```

`A` selects the constructor as well as providing the constructor's nonrecursive arguments.
`B` then selects the recursive element as well as providing the recursive element's arguments.

#### Example: Ordinals with a twist

```
data Ord (A : 𝒰) : 𝒰 where
  Z : A → Ord A
  S : Ord A → Ord A
  L : (ℕ → Ord A) → Ord A

Ord A = W (A + 𝟙 + 𝟙) B
  where
  B (in1 a) = 𝟘
  B (in2 ∗) = 𝟙
  B (in3 ∗) = ℕ
Z a = sup (in1 a) absurd
S o = sup (in2 ∗) (λ _ → o)
L f = sup (in3 ∗) f
```

## Indexed Well-Founded Trees

```
data IW (I : 𝒰)
        (A : I → 𝒰)
        (B : ∀ i → A i → 𝒰)
        (d : ∀ i → (a : A i) → B i a → I) :
        I → 𝒰 where
  isup : ∀ i → (a : A i) →
         ((b : B i a) → IW I A B d (d i a b)) →
         IW I A B d i
```

The indexed W type can be seen as either encoding an inductive type with nonuniform parameters
or as encoding mutual inductive types, which are indexed inductive types anyway.
`I` selects the nonuniform parameters, which I'll call the index for now
`A` selects the constructor, `B` selects the recursive element,
and `d` returns the index of that recursive element.

#### Example: Mutual inductives — even and odd naturals

```
data Even : 𝒰 where
  Z : Even
  Sₑ : Odd → Even
data Odd : 𝒰 where
  Sₒ : Even → Odd

EvenOdd = IW 𝟚 A B d
  where
  Even = in1 ∗
  Odd  = in2 ∗
  A Even = 𝟚  -- Even has two constructors
  A Odd  = 𝟙  -- Odd  has one constructor
  B Even (in1 ∗) = 𝟘  -- Z  has no  recursive elements
  B Even (in2 ∗) = 𝟙  -- Sₑ has one recursive element
  B Odd  ∗ = 𝟙        -- Sₒ has one recursive element
  d Even (in1 ∗) = absurd
  d Even (in2 ∗) ∗ = Odd
  d Odd  ∗       ∗ = Even
Z = isup Even (in1 ∗) absurd
Sₑ o = isup Even (in2 ∗) (λ _ → o)
Sₒ e = isup Odd ∗ (λ _ → e)
```

#### Example: Nonuniformly parametrized inductive — accessibility predicate

```
variable
  T : 𝒰
  _<_ : T → T → 𝒰

data Acc (t : T) : 𝒰 where
  acc : (∀ s → s < t → Acc s) → Acc t

Acc t = IW T (λ _ → 𝟙) (λ t ∗ → ∃[ s ] s < t) (λ t ∗ (s , _) → s) t
```

#### Example: Nonuniformly parametrized inductive — perfect trees

```
data PTree (A : 𝒰) : 𝒰 where
  leaf : A → PTree A
  node : PTree (A × A) → PTree A

PTree = IW 𝒰 (λ A → A + 𝟙) B d
  where
  B A (in1 a) = 𝟘
  B A (in2 ∗) = 𝟙
  d A (in1 a) = absurd
  d A (in2 ∗) ∗ = A × A
leaf A a = isup A (in1 a) absurd
node A t = isup A (in2 ∗) (λ _ → t)
```

## Indexed Inductives and Fording

So far, (nonuniformly) parametrized inductives and mutual inductives can be encoded.
Indexed inductives can be encoded as well by first going through a round of fording
to turn them into nonuniformly parametrized inductives.
Meanwhile, mutual inductives can also be represented as nonuniform parametrized inductives
by first turning them into indexed inductives.

#### Example: Function images

```
variable
  A B : 𝒰

data Image (f : A → B) : B → 𝒰 where
  image : ∀ x → Image f (f x)

-- Forded image type
data Image' (f : A → B) (b : B) : 𝒰 where
  image' : ∀ x → b ≡ f x → Image f b

Image' f b = W (∃[ x ] b ≡ f x) 𝟘
image' x p = sup (x , p) absurd
```

#### Example: The finite sets

```
data Fin : ℕ → 𝒰 where
  FZ : ∀ n → Fin (S n)
  FS : ∀ n → Fin n → Fin (S n)

-- Forded finite sets type
data Fin' (m : ℕ) : 𝒰 where
  FZ' : ∀ n → m ≡ S n → Fin m
  FS' : ∀ n → m ≡ S n → Fin n → Fin m

Fin' = IW ℕ (λ m → 𝟚 × ∃[ n ] m ≡ S n) B d
  where
  B m (in1 ∗ , n , p) = 𝟘
  B m (in2 ∗ , n , p) = 𝟙
  d m (in1 ∗ , n , p) = absurd
  d m (in2 ∗ , n , p) ∗ = n
FZ' m n p     = isup m (in1 ∗ , n , p) absurd
FS' m n p fin = isup m (in2 ∗ , n , p) (λ _ → fin)
```

## Nested Inductives

Nested inductive types, when represented as recursive μ types, have nested type binders.
Nonindexed inductive types potentially with nonuniform parameters, on the other hand, are single μ types.

```
Ord A = μX: 𝒰. A + X + (ℕ → X)
EvenOdd = μX: 𝟚 → 𝒰. λ { in1 ∗ → 𝟙 + X (in2 ∗) ; in2 ∗ → X (in1 ∗) }
Acc = μX: T → 𝒰. λ t → ∀ s → s < t → X s
PTree = μX: 𝒰 → 𝒰. λ A → A + X (A × A)
Fin' m = μX: ℕ → 𝒰. (∃[ n ] m ≡ S n) + (∃[ n ] (m ≡ S n) × X n)
```

Nested inductives, when not nested within themselves,
can be defunctionalized into indexed inductives,
which can then be forded into nonuniformly parametrized inductives,
which can finally be encoded as indexed W types.

#### Example: Finitely-branching trees

```
data FTree : 𝒰 where
  ftree : List FTree → FTree

FTree = μX: 𝒰. List X = μX: 𝒰. μY: 𝒰. 𝟙 + X × Y

data I : 𝒰 where
  Tree : I
  List : I → I

data Eval : I → 𝒰 where
  nil : Eval (List Tree)
  cons : Eval Tree → Eval (List Tree) → Eval (List Tree)
  ftree : Eval (List Tree) → Eval Tree

data Eval' (i : I) : 𝒰 where
  nil'  : i ≡ List Tree → Eval' i
  cons' : i ≡ List Tree → Eval' Tree → Eval' (List Tree) → Eval' i
  ftree : i ≡ Tree → Eval' (List Tree) → Eval' i

Eval' = IW I A B d
  where
  A i = i ≡ List Tree + i ≡ List Tree + i ≡ Tree
  B _ (in1 _) = 𝟘
  B _ (in2 _) = 𝟚
  B _ (in3 _) = 𝟙
  d _ (in1 _) = absurd
  d _ (in2 _) (in1 ∗) = Tree
  d _ (in2 _) (in2 ∗) = List Tree
  d _ (in3 _) ∗ = List Tree
```

#### Non-example: Truly nested inductive — bushes
It's unclear how this might be encoded either as indexed inductives or as an indexed W type.

```
data Bush (A : 𝒰) : 𝒰 where
  bnil : Bush A
  bcons : A → Bush (Bush A) → Bush A

Bush = μX: 𝒰 → 𝒰. λ A → 𝟙 + A × X (X A)
```

## Inductive–Inductives

While mutual inductives allow the types of constructors of multiple inductives
to refer to one another,
inductive–inductives further allow one inductive to be a parameter or index of another.

```
data A : 𝒰 where
  …
data B : A → 𝒰 where
  …
```

#### Example: Intrinsically well-formed contexts and types
That is, the entries of a context must be well formed under the correct context,
while the context under which types are well formed must themselves be well formed.

```
data Ctxt : 𝒰 where
  · : Ctxt
  _∷_ : ∀ Γ → Type Γ → Ctxt

data Type : Ctxt → 𝒰 where
  U : ∀ Γ → Type Γ
  Var : ∀ Γ → Type (Γ ∷ U Γ)
  Pi : ∀ Γ → (A : Type Γ) → Type (Γ ∷ A) → Type Γ
```

To encode this inductive–inductive type, it's split into two mutual inductives:
an "erased" one with the type interdependency removed (i.e. `Type'` does not have a `Ctxt'` parameter),
and one describing the relationship between the two.

```
data Ctxt' : 𝒰 where
  · : Ctxt'
  _∷_ : Ctxt → Type → Ctxt

data Type' : 𝒰 where
  U : Ctxt' → Type'
  Var : Ctxt' → Type'
  Pi : Ctxt' → Type' → Type' → Type'

data Ctxt-wf : Ctxt' → 𝒰 where
  ·-wf : Ctxt-wf ·
  ∷-wf : ∀ {Γ} {A} → Ctxt-wf Γ → Type-wf Γ A → Ctxt-wf (Γ ∷ A)

data Type-wf : Ctxt' → Type' → 𝒰 where
  U-wf : ∀ {Γ} → Ctxt-wf Γ → Type-wf Γ (U Γ)
  Var-wf : ∀ {Γ} → Ctxt-wf Γ → Type-wf (Γ ∷ U Γ) (Var Γ)
  Pi-wf : ∀ {Γ} {A B} → Ctxt-wf Γ → Type-wf Γ A →
          Type-wf (Γ ∷ A) B → Type-wf Γ (Pi Γ A B)
```

In other words, `Ctxt'` and `Type'` describe the syntax,
while `Ctxt-wf` and `Type-wf` describe the well-formedness rules.

```
Γ ⩴ · | Γ ∷ A            (Ctxt')
A, B ⩴ U | Var | Π A B   (Type' with Ctxt' argument omitted)

─── ·-wf
⊢ ·

⊢ Γ  Γ ⊢ A
────────── ∷-wf
⊢ Γ ∷ A

⊢ Γ
────────── U-wf
Γ ⊢ U type

⊢ Γ
──────────────── Var-wf
Γ ∷ U ⊢ Var type

⊢ Γ  Γ ⊢ A  Γ ∷ A ⊢ B
───────────────────── Pi-wf
Γ ⊢ Π A B type
```

The final encoding of a context or a type is then the erased type
paired with its well-formedness.

```
Ctxt = Σ[ Γ ∈ Ctxt' ] Ctxt-wf Γ
Type (Γ , Γ-wf) = Σ[ A ∈ Type' ] Type-wf Γ A

· = · , ·-wf
(Γ , Γ-wf) ∷ (A , A-wf) = Γ ∷ A , ∷-wf Γ-wf A-wf
U (Γ , Γ-wf) = U Γ , U-wf Γ-wf
Var (Γ , Γ-wf) = Var Γ , Var-wf Γ-wf
Pi (Γ , Γ-wf) (A , A-wf) (B , B-wf) = Pi Γ A B , Pi-wf Γ-wf A-wf B-wf
```

These indexed mutual inductives can then be transformed into a single indexed inductive with an additional index,
then into a nonuniformly parametrized inductive, and finally into an indexed W type.
The same technique can be applied to generalized inductive–inductives, e.g. "infinitary" `Pi`.

```
data Type' : 𝒰 where
  …
  Pi∞ : Ctxt' → (ℕ → Type') → Type'

data Type-wf : Ctxt' → Type' → 𝒰 where
  …
  Pi∞-wf : ∀ {Γ} {T : ℕ → Type'} → Ctxt-wf Γ →
          (∀ n → Type-wf Γ (T n)) → Type-wf Γ (Pi∞ Γ T)

Pi∞ (Γ , Γ-wf) TT-wf = Pi∞ Γ (fst ∘ TT-wf) , Pi∞-wf Γ-wf (snd ∘ TT-wf)
```

## Inductive–Recursives

You can't encode these as W types apparently.

## Indexed Well-Founded Trees as Canonized Well-Founded Trees

_This section is lifted from Dan Doel's [encoding](https://hub.darcs.net/dolio/agda-share/browse/WhyNotW.agda)
of indexed W types as W types following the canonical construction from
[Why Not W?](https://jashug.github.io/papers/whynotw.pdf) by Jasper Hugunin._

An indexed W type can be encoded as an unindexed one by first storing the index
together with the `A` type as in `IW'` below.
Then, define the `canonical` predicate to assert that, given some index selector `d`
as would be found in an indexed well-founded tree,
not only is the current index the one we expect,
but the index of all recursive elements are the ones dictated by `d`.
That is, `f b` gives the actual recursive element from which we can extract the index,
while `d i a b` gives the expected index, and we again assert their equality.
Finally, an encoded indexed W type `EIW` is a `IW'` type such that the index is canonical.

```
variable
  I : 𝒰
  A : I → 𝒰
  B : ∀ i → A i → 𝒰
  d : ∀ i → (a : A i) → B i a → I

IW' (I : 𝒰) →
    (A : I → 𝒰) →
    (B : ∀ i → A i → 𝒰) → 𝒰
IW' I A B = W (∃[ i ] A i) (λ (i , a) → B i a)

canonical : (∀ i → (a : A i) → B i a → I) → IW' I A B → I → 𝒰
canonical d (sup (i , a) f) i' = (i ≡ i') × (∀ b → canonical d (f b) (d i a b))

EIW : (I : 𝒰) →
      (A : I → 𝒰) →
      (B : ∀ i → A i → 𝒰) →
      (d : ∀ i → (a : A i) → B i a → I) → I → 𝒰
EIW I A B d i = Σ[ w ∈ IW' I A B ] (canonical d w i)

isup : (i : I) → (a : A i) → ((b : B i a) → EIW I A B d (d i a b)) → EIW I A B d i
isup i a f = sup (i , a) (fst ∘ f) , refl i , (snd ∘ f)
```