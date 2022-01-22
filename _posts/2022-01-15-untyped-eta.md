---
layout: post
title: "Notes on Untyped Conversion"
excerpt_separator: "<!--more-->"
tags:
  - type theory
  - conversion
  - eta conversion
  - equality reflection
---

<!--
## TL;DR

Suppose you had a reflexive, transitive, congruent reduction relation `e ⊳* e`,
and your conversion `e₁ ≈ e₂` is its confluent closure `e₁ ⊳* e *⊲ e₂`.
If you add η-conversion rules, conversion becomes neither congruent nor transitive.

* *Congruence*: Consider `F: (𝒰 → 𝒰) → 𝒰` and `G: 𝒰 → 𝒰`.
  Then `F G ≉ F (λX: 𝒰. G X)` since there is neither η-expansion nor η-contraction.
* *Transitivity*: Consider a variable `f` in scope.
  Then `λx: ⊥. f x ≈ f` and `f ≈ λx: ⊤. f x` both hold by untyped η-conversion,
  but `λx: ⊥. f x ≈ λx: ⊤. f x` could not possibly hold.
-->

<!--more-->

## Untyped Conversion

Untyped conversion (and therefore reduction), I think,
is meant to model the implementation of a conversion checker.
(I'm really not the best person to ask.)
Ideally, you'd want it to be entirely decoupled from the type checker,
which is a very Software Engineering 110 reasonable thing to expect.
An implementation outline might look like this:

1. Reduce both terms sufficiently.
2. If they look different, give up.
3. Recur on subterms.

"Sufficiently" might mean normal form or weak head normal form or whatever reasonable form you like.
So we might formalize that as follows:

```
───────────────────────── β
(λx: τ. e) e' ⊳ e[x ↦ e']

────── ⊳*-refl
e ⊳* e

e₁ ⊳ e₂
e₂ ⊳* e₃
──────── ⊳*-trans
e₁ ⊳* e₃

eᵢ ⊳* eᵢ'
─────────────────────── ⊳*-cong
e[x ↦ eᵢ] ⊳* e[x ↦ eᵢ']

e₁ ⊳* e
e₂ ⊳* e
─────── ≈-red
e₁ ≈ e₂
```

The "sufficiently" part comes from `⊳*-trans`, where you take as many steps as you need.
The congruence rules are the most tedious, since you need one for every syntactic form,
so I've instead lazily written them as a single substitution.
Conversion is an equivalence relation, as you'd expect:
it's reflexive (by `⊳*-refl`), it's symmetric (by swapping premises in `≈-red`),
it's substitutive (by `⊳*-cong`), and it's transitive *if* reduction is confluent,
because then you can construct the conversion by where the pairs meet.
(Confluence left as an exercise for the reader.)

```
e₁ ≈ e₂ ≈ e₃
 \  /  \  /
  e₁₂   e₂₃  ← confluence gives this diamond
    \  /
     e*

e₁ ⊳* e*
e₃ ⊳* e*
────────
e₁ ≈ e₃
```

## Cumulativity + η

Dually to β, let's now add η-contraction, but suppose we had cumulativity
(or more generally, *any* subtyping relation).
Then η-contraction is no good, since it breaks confluence.
Supposing we had types `σ ≤ τ`, `λx: σ. (λy: τ. f y) x` could either β-reduce to `λx: σ. f x`,
or η-contract with congruence to `λy: τ. f y`, but these are no longer α-equivalent due to the type annotation.
Breaking confluence then means breaking transitivity of conversion as well.
η-contraction then isn't an option with Church-style type-annotated intrinsically-typed terms.

What about η-expansion?
If you had a neutral term typed as a function, you may expand it once.
But with untyped conversion, there's no way to tell whether the term is indeed typed as a function,
and you can't go around η-expanding any old neutral term willy-nilly.

## η-Conversion

The remaining solution is then to add η-equivalence as part of conversion.
There are two ways to do this; the first is the obvious way.

```
────────────── ≈-ηₗ (+ ≈-ηᵣ symmetrically)
λx: τ. f x ≈ f
```

This immediately requires explicit transitivity and congruence rules,
since `λx: τ. λy: σ. f x y ≈ f` wouldn't hold otherwise.
The other way is to check that one side is a function,
then apply the other side.

```
e₁ ⊳* λx: τ. e₁'
e₂ ⊳* e₂'
x ∉ FV(e₂')
e₁' ≈ e₂' x
──────────────── ≈-ηₗ (+ ≈-ηᵣ symmetrically)
e₁ ≈ e₂
```

This looks more ideal since it seems like it easily extends the implementation outline:

1. Reduce both terms sufficiently.
2. If one of them looks like a function, recur according to `≈-η`.
3. If they look different, give up.
4. Recur on subterms.

You then still need congruence rules for step 4;
otherwise `F G ≈ F (λX: 𝒰. G X)` would not hold given some `F: (𝒰 → 𝒰) → 𝒰` and `G: 𝒰 → 𝒰`.
It seems like transitivity *might* hold without explicitly adding it as a rule,
again by confluence, but this time requiring induction on derivation heights rather than structural induction,
and first showing that the derivation of any symmetric conversion has the same height.

## Multiple ηs

Suppose we were in a setting with multiple syntactic functions,
for instance the Calculus of Constructions or System F,
where abstraction by and application of a type differs from ordinary term abstractions and applications.

```
Γ, x: σ ⊢ e: τ               Γ, α: ⋆ ⊢ e : τ
───────────────────────      ─────────────────
Γ ⊢ λx: σ. e : Πx: σ. τ      Γ ⊢ Λα. e : ∀α. τ

Γ ⊢ e : Πx: σ. τ             Γ ⊢ e : ∀α. τ
Γ ⊢ e' : σ                   Γ ⊢ σ : ⋆
────────────────────         ────────────────────
Γ ⊢ e e' : τ[x ↦ e']         Γ ⊢ e [σ] : τ[α ↦ σ]

(λx: τ. e) e' ⊳ e[x ↦ e']    (Λα. e) [σ] ⊳ e[α ↦ σ]
```

If both of these functions had η-conversion rules, transitivity wouldn't hold,
especially for open terms.
Specifically, the conversions `λx: τ. f x ≈ f` and `f ≈ Λα. f [α]` are both derivable
(despite being ill-typed when considered simultaneously, since conversion is untyped),
but `λx: τ. f x ≈ Λα. f [α]` is impossible to derive.

## Equality Reflection + η

In Oury's Extensional Calculus of Constructions [[2](#2)],
equality reflection is added to untyped conversion
(`≡` denoting the equality *type*).

```
Γ ⊢ p: x ≡ y
──────────── ≈-reflect
Γ ⊢ x ≈ y
```

There's a clash between the fact that ill-typed terms can still be convertible,
and that equality reflection only makes sense when everything is well-typed.
In particular, you cannot simultaneously have congruence and transitivity of conversion,
since it allows you to derive an inconsistency.
Concretely, using an ill-typed proof of `⊤ ≡ ⊥`
(where `⊤` is trivially inhabited by `∗` and `⊥` is uninhabited),
you can convert from `⊤` to `⊥`.

```
· ⊢ ⊤ ≈ (λp: ⊤ ≡ ⊥. ⊤) refl    (by β-reduction)
      ≈ (λp: ⊤ ≡ ⊥. ⊥) refl    (by ≈-cong and ≈-reflect on (p: ⊤ ≡ ⊥) ⊢ p: ⊤ ≡ ⊥)
      ≈ ⊥                      (by β-reduction)
```

Note the ill-typedness of the application:
`refl` is clearly not a proof of `⊤ ≡ ⊥`.
Evidently this leads to a contradiction,
since you could then convert the type of `∗` from `⊤` to `⊥`.

<!--
## Choose your Own Adventure

1. Use typed conversion. Don't use untyped conversion.
  <br/><small>(This content is not yet available for compiler type preservation.)</small>
2. Convince yourself that contravariant function type domains in subtyping are fine,
  η-contraction is fine, and don't tell anyone on the Coq Development Team.
  <br/><small>(Disclaimer: There may be other reasons this is unfine that I'm unaware of.)</small>
3. Add η-conversion (the second kind), add congruence, and ~~hope~~ show that transitivity holds.
  <br/><small>(Final exercise for the reader.)</small>
-->

## Addendum: What does Coq *actually* do?

Coq's conversion algorithm can be found in its [kernel](https://github.com/coq/coq/blob/master/kernel/reduction.ml),
which is actually one giant algorithm parametrized over whether it should be checking convertibility or cumulativity.
The below is my attempt at writing it down as rules (ignoring cases related to (co)inductives),
with MetaCoq's [conversion](https://metacoq.github.io/html/MetaCoq.PCUIC.PCUICTyping.html#conv) in pCuIC as guidance.
`[ʀ]` represents the relation over which they are parametrized,
which can be either `[≈]` or `[≤]`.

```
i = j
────────── ≈-𝒰
𝒰ᵢ [≈] 𝒰ⱼ

i ≤ j
────────── ≤-𝒰
𝒰ᵢ [≤] 𝒰ⱼ

τ₁ [≈] τ₂
σ₁ [ʀ] σ₂
───────────────────────── ʀ-Π
Πx: τ₁. σ₁ [ʀ] Πx: τ₂. σ₂

t₁ [ʀ] t₂
e₁ [≈] e₂
─────────────── ʀ-app
t₁ e₁ [ʀ] t₂ e₂

τ₁ [≈] τ₂
e₁ [ʀ] e₂
───────────────────────── ʀ-λ
λx: τ₁. e₁ [ʀ] λx: τ₂. e₂

τ₁ [≈] τ₂
t₁ [≈] t₂
e₁ [ʀ] e₂
───────────────────────────────────────────── ʀ-let
let x: τ₁ ≔ t₁ in e₁ [ʀ] let x: τ₂ ≔ t₂ in e₂

e₁ [ʀ] e₂
─────────────────────── (catch-all for remaining syntactic constructs)
t[x ↦ e₁] [ʀ] t[x ↦ e₂]

e₂ x ⊳* e₂'
e₁ [≈] e₂'
──────────────── ʀ-ηₗ
λx: τ. e₁ [ʀ] e₂

e₁ x ⊳* e₁'
e₁' [≈] e₂
──────────────── ʀ-ηᵣ
e₁ [ʀ] λx: τ. e₂
```

The "real" conversion and subtyping rules are then the confluent closure of the above.
The actual implementation performs more reduction as needed;
I think this is just for performance reasons,
and because there's no way to forsee how many steps you'll end up having to take during initial reduction.

```
e₁ ⊳* e₁'
e₂ ⊳* e₂'
e₁' [≈] e₂'
───────────
e₁ ≈ e₂

e₁ ⊳* e₁'
e₂ ⊳* e₂'
e₁' [≤] e₂'
───────────
e₁ ≤ e₂
```

Reflexivity and symmetry of conversion and reflexivity of subtyping are easy to see.
Congruence is built into the rules (shown with the same substitution notation as before).
Evidently conversion implies subtyping, but this time indirectly.

<!--
I don't know.

MetaCoq, the mechanization of pCuIC in Coq, doesn't include η-conversion,
but it defines [conversion](https://metacoq.github.io/html/MetaCoq.PCUIC.PCUICTyping.html#conv) differently as well:
two terms are convertible if they subtype one another.
Subtyping, in turn, is the confluent closure of reduction,
but only up to an ordering on terms respecting cumulativity.
The rules are roughly as follows (excluding those related to (co)inductives), with ≼ denoting this order.

```
─────
e ≼ e

i ≤ j
────────
𝒰ᵢ ≼ 𝒰ⱼ

σ₁ ≼ σ₂
─────────────────────
Πx: τ. σ₁ ≤ Πx: τ. σ₂

e₁ ≼ e₂
───────────
e₁ e ≼ e₂ e

e₁ ≼ e₂
─────────────────────
λx: τ. e₁ ≼ λx: τ. e₂

e₁ ≼ e₂
─────────────────────────────────────
let x: τ ≔ e in e₁ ≼ let x: τ ≔ in e₂
```

```
e₁ ⊳* e₁'
e₂ ⊳* e₂'
e₁' ≼ e₂'
─────────
e₁ ≤ e₂

e₁ ≼ e₂
e₂ ≼ e₁
───────
e₁ ≈ e₂
```

I'm assuming η-conversion rules would then be added to conversion,
with additional congruence rules, and neglecting transitivity as usual.
-->

## References

[<a name="1">1</a>] McBride, Conor. (9 January 2015). _universe hierarchies_. ᴜʀʟ:[https://pigworker.wordpress.com/2015/01/09/universe-hierarchies/](https://pigworker.wordpress.com/2015/01/09/universe-hierarchies/).
<br/>
[<a name="2">2</a>] Oury, Nicolas. (TPHOLs 2005). _Extensionality in the Calculus of Constructions_. ᴅᴏɪ:[10.1007/11541868_18](https://doi.org/10.1007/11541868_18).