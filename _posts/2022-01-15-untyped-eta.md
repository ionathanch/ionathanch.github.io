---
layout: post
title: "Notes on Untyped η-Conversion"
excerpt_separator: "<!--more-->"
tags:
  - type theory
  - conversion
  - eta conversion
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

Dually to β, let's now add η, but suppose we had cumulativity
(or more generally, *any* subtyping relation).
Then η-contraction is no good, since it "breaks" subject reduction
(i.e. the preservation of a term's type as it reduces).
Suppose we had types `ρ, σ, τ`, `σ ≤ τ`, and `f: τ → ρ`.
By η-contraction, we would have `λx: σ. f x ⊳ f`,
but the LHS has type `σ → ρ` while the RHS has `τ → ρ`.
This might be fine if `τ → ρ ≤ σ → ρ`,
but <span style="border-bottom: 1px dotted #000" title="*cough* Coq *cough*">some type theories</span>
have [invariant function type domains](https://pigworker.wordpress.com/2015/01/09/universe-hierarchies/)
rather than contravariant ones.
Interestingly, conversion remains transitive if you still have confluence with η-contraction,
which I think you do.
(Another exercise for the reader.)

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

## Choose your Own Adventure

1. Use typed conversion. Don't use untyped conversion.
  <br/><small>(This content is not yet available for compiler type preservation.)</small>
2. Convince yourself that contravariant function type domains in subtyping are fine,
  η-contraction is fine, and don't tell anyone on the Coq Development Team.
  <br/><small>(Disclaimer: There may be other reasons this is unfine that I'm unaware of.)</small>
3. Add η-conversion (the second kind), add congruence, and ~~hope~~ show that transitivity holds.
  <br/><small>(Final exercise for the reader.)</small>

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