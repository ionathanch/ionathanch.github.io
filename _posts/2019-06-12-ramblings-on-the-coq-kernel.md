---
layout: post
title: "Ramblings on the Coq Kernel"
excerpt_separator: "<!--more-->"
tags:
  - Coq
  - OCaml
---

Back during the summer of 2019, I worked a bit on the Coq kernel. At the same time, I posted a _lot_ of toots on Mastodon about whatever random problems I was encountering. I've decided to collect them here, as it might just be that some of these will be useful to me again at some point.

<!--more-->

###### 12 June 2019

> The entire French style guide was deleted and replaced with an English translation (-ish) <br/>
> IMO they should've kept both versions? Would be nice to have translations, don't need to completely delete the French

> - keep "cst" for constants and avoid it for constructors which is otherwise a source of confusion <br/>
> - for constructors, use "cstr" in type constructor (resp. "cstru" in constructor puniverse); avoid "constr" for "constructor" which could be think as the name of an arbitrary Constr.t
>
> okay so in summary:
>   * constants: cst
>   * constructors: cstr
>   * constructions: constr <br />
> so now I need to come up with something for "constraints"

> yikes the execute method uses cstr for constructions tho

> the function names are so long and the parameter names are so short

> stage_cnstrnt
>
> that's just... missing all the vowels

> turns out I just need to pass around the stage variables so I'm just using stg lol

###### 13 June 2019

> I think I have a monad for my stages and a monoid for my stage constraints but this is OCaml and there isn't really anything I can do about that is there

> ohey we have a monad.ml
>
> no do notation tho

> The heck are primitive projections <br/>
> Where do I read about these

> Me: adds a field to a data type <br/>
> OCaml: everything red

> I see why OOP is sometimes good,

> It's easier to insert a new variant instead of modifying an existing one...

> Me: adds new variant <br/>
> OCaml: everything green (pattern matching not exhaustive)

> Even adding a new parameter to my type involves so many changes grrr...

> After much deliberation (walking around drinking a lot of water and sending a very long email to my advisor) I have decided to modify the existing variant directly and deal with the fallout over the next few days <br/>
> THEN I can start doing actual work lol

###### 14 June 2019

> I'm annoyed that constructors take a tuple instead of just the arguments <br/>
> Changing `Ind iu` to `Ind iu * annot` means I have to add parentheses around everything ugh

> [redacted] <br/>
> I'm trying to figure out how hashconsing works which is Not what I set out to do

> I'm almost certain there's no point in hashconsing a nonrecursive and small-depth structure but I haven't figured out what hashconsing is for yet

> it's not a hash function bc it returns smth of the same time so I'm ??? other implementations just hashcons substructures and I'm, there's not substructures here

> I'm screaminggggg why aren't there typeclasses why do I have to manually write what should've been derived by Show

> I swear I've edited the same function copied like six times throughout the codebase

> You know how I decided to go ahead with adding a field to the Ind variant without waiting for my advisor to respond? Well he responded and he had the same idea as me so that's whew didn't waste, like, a whole morning lol

> [redacted]

> why is this change causing errors in tactics. this is terrifying

> I wish they'd used different ASTs for each different place, if only that would mean I wouldn't have to touch stuff in tactics and pretyping, which has nothing to do with me

> "[Jonathan], just use regex to replace all instances of `Ind \W+` to `Ind ($1, _)`" <br/>
> I refuse to relinquish my direct oversight of ALL changes

> [coq.discourse.group/c/coq-development}(coq.discourse.group/c/coq-development) is so empty

###### 16 June 2019

> One response on my question about type-based termination on the Coq Discourse page was  <br/>
> "As far as I know the semantics of sized types is not entirely understood." <br/>
> excuse u maybe u didn't read the PhD but I underst
> 
> well I didn't read the entire PhD. and it wasn't the most understandable thing. and it had typos

[editor's note: I _definitely_ did not understand the semantics. please excuse my brashness here]

> for some reason the typos bother me the most <br/>
> not the fact that the typing rules doesn't explain how unification of sizes work... or that there's no inference version of it except for the algorithm in the previous paper... it's the typos

[editor's note: surprise! the unification is the constraint-solving!]

###### 17 June 2019

> I've broken something except it's in ./theories/ZArith/Znumtheory.v so I have no idea what I did to do that

> and I have no idea how to debug lol it errored while compiling not while running something so idk how to trigger that in ocamldebug

> OH I forgot to erase my sizes on leaving the inference algorithm lmao

###### 18 June 2019

> There's a missing parameter in these functions I'm looking at
>
> How did this compile <br/>
> The signature is all incorrect

> The signatures are correct, ok, but because of currying although the parameters have the wrong names they were inferred to have the right types
>
> Dangerous

> Is there an easier way of writing `a_ref <- f !a_ref` bc I initially wrote `f` functionally

> wait is the syntax `:=` not `<-` oops

> the OCaml tutorial is extremely suck

[editor's note: and I stand by this!]

> `:=` for ref cells (what I wanted), `<-` for... object fields? dunno not my problem

> I guess my variable is of type `((SConstraint.t ref) option)` lmao

> o no how 2 chain functions with optional parameters with no default <br/>
> OCaml makes them all be `'a option` o no

> ah use ? when applying also

###### 19 June 2019

> "Fatal Error: Failure: Validation failed: tuple size: found 2, expected 1 (in tag=11)."
>
> pal <br/>
> I don't know what this means

> "Error: Unbound module Discharge"
>
> this one's not my fault

###### 20 June 2019

> I hate this why is `SProp` failing in my CI build and on my machine but not on Coq's master

###### 21 June 2019

> Master test suite passes <br/>
> Dev test suite fails <br/>
> Debugging passes <br/>
> Hmmmm

###### 26 June 2019

> Ok ok  <br/>
> "The Arity of an inductive type is the context of indices so that the context of parameters + the arity + the sort = the full type of the inductive type" <br/>
> So
> `(** Arity context of [Ii] with parameters: [forall params, Ui] *)` <br/>
> what

> I think it means the arity using the variables bound to the parameters in the context of parameters??

###### 27 June 2019

> where tf are the coinductives <br/>
> how could you have a cofix but no coind

[editor's note: the `Ind` is used for both inductives and coinductives!]

> well! I've made a grave error and idk what the correct way is to proceed so I've been not thinking about it for the past hour lmao

> maybe if I don't think about it, it will go away <br/>
> My TODO list: still contains the item <br/>
> damn

> Compileen changes... this should fix all me mistakes

> as SOON as my thing compiles I am OUTTA here

###### 28 June 2019

> "The algorithm works as follows: given a bare term t ◦ the algorithm computes a generic term t (such that \|t\| = t ◦ ), a generic type T and a constraint set C on generic size annotations, such that for every substitution ρ satisfying C, ρt has type ρT ."
>
> that's not an algorithm mister

###### 3 July 2019

> [redacted]

> val whd_betaiotazeta <br/>
> val whd_all <br/>
> val whd_allnolet <br/>
> val whd_betaiota
>
> ??? what's the difference
>
> I know let reduction is zeta so I would think allnolet would be the same as betaiota?? and that betaiotazeta is the same as all??

> oh my god there's delta reduction sfjghgpff

###### 4 July 2019

> ok I spent the morning double-checking my stage annotations for Case and now FINALLY I can begin implementation of RecCheck

> [redacted]

> Two Door Cinema Club: play't <br/>
> RecCheck: algorithm'd <br/>
> Coq: compileth <br/>
> OCaml docs: UPN'T

> Two months into working on this I ask where the dependencies are lmao

> I've been mulling it over and I COULD implement a graph myself but why?? would I?? do that??

> WHY can't I use a previously-defined module in the signature of another module

> I'm [the fool] who mixed up module types and modules

###### 5 July 2019

> For some reason the cofixpoints don't come with the vector that tells me whicheth argument is the corecursive one <br/>
> why tho

###### 8 July 2019

> COQC      theories/ZArith/Znumtheory.v <br/>
> File "./theories/ZArith/Znumtheory.v", line 251, characters 56-61: <br/>
> Error: cannot find a declared ring structure over "Z"
>
> That's, like, not my problem

###### 9 July 2019

> why are you like this

{% include image.html
           img="assets/images/coq-kernel/ocaml-unit-tests.png" %}

{% include image.html
           img="assets/images/coq-kernel/test-suite-make-unit-tests.png" %}

> Me: ah, I'm in the wrong folder <br/>
> Coq OCaml unit tests:

{% include image.html
           img="assets/images/coq-kernel/unit-tests-make-unit-tests.png" %}

> I forgot I can't build the test suite because
>
> File "./theories/ZArith/Znumtheory.v", line 251, characters 56-61: <br/>
> Error: cannot find a declared ring structure over "Z"
>
> asdlkfj;aslkdfj;alskdjfslkj

> let me in, let me iiiiin

###### 15 July 2019

> oops the reference implementation of the typechecker is broken cool so uhhh what do

> the problem is that global variables have full types which breaks typechecking in fixpoints and Sacchini's solution was to introduce size variables in the syntax to explicitly say that such and such type should not be a full type but I CANNOT change the syntax of Coq

> sfsfsdfg I can't typecheck an is_even function??? qwhawthaht

[editor's note: I remember this problem! I don't remember what the underlying issue was. I think it was nested match-cases...]

###### 22 July 2019

> I really be missing an annotation on a simple lambda inference <br/>
> what simple yet foolish mistake could I have maken to cause this

> I really don't wanna debug this

{% include image.html
           img="assets/images/coq-kernel/unsatisfied-stage-constraints.png" %}

> something funny is going on with tuple types

> Huh, it is just a normal prod type
idk why it's making things break

> Do I really have to write my own unzip function

###### 25 July 2019

> Not sure what I'd like to do next... I don't /really/ wanna get rid of guard checking bc not everything passes sized typing <br/>
> I think the next thing to do is just to deal with Definition types not preserving size and Consts not having stage annotations, which actually can be solved by making constraints global, but I don't want to do that either... hmm...

> ATM I'm running tests to see what existing functions fail sized typechecking which I'll include in my report <br/>
> After that I might do performance comparisons <br/>
> Also I gotta try out nonterminating functions to see if they really get caught

> I've decided to do recursive arg inference next even though I said I didn't want to get rid of guard checking <br/>
> After everything from prev toot ofc

###### 26 July 2019

> [redacted]

###### 30 July 2019

> "the standing policy over quite many years now has been to never introduce new external dependencies and try to remove those that exist"
>
> soooo what am I supposed to do if I want this weighted directed graph

[editor's note: for those curious, I ended up copying code from ocamlgraph into an internal library]

###### 1 August 2019

> I have no idea what the naming convention is in this codebase I mean in the same file I see "lna" for list of names and "tl", "bl" for list of types and bodies like ??? okay dokay <br/>
> and I /think/ "ln" for my array of indices means "list of number" but it's neither a list nor numbers (they're ints) <br/>
> I'm changing it to `int option array` so I guess I'm changing it to "lon"??

> Except okay look. <br/>
> `((t,i),(lna,tl,bl))` <br/>
> We have
>   * t: array of indices
>   * i: index
>   * lna: list of names
>   * tl: list of types
>   * bl: list of bodies <br />
> So if I want to name an optional int should I do io or oi

> changing a data structure, causing rippling changes throughout the entire codebase: easy <br/>
> naming a variable: hard

> it's only used in `Pp.opt int i` so... `Pp.opt int io` or `Pp.opt int oi`

> `Opt Int` makes `oi` the solution that makes the most sense and prevents it from being read as IO (input/output) but `oi` on its own just looks so incorrect

> In a DIFFERENT file instead of `ln` for list of numbers it's called `vn` for...??? vector of numbers?? vectors aren't arrays pls

> it's called `ri` in YET aNOTHER file WTF does ri MEAN

> aRray of Integers

###### 7 August 2019

> I've tried all the solutions I've thought up they all have problems and don't work
>
> wwhwhhat now

###### 9 August 2019

> I think I have a solution to the conundrum of my polymorphic stage variables but it's complex and I don't like it

> "This kind of expression is not allowed as right-hand side of `let rec'"
>
> ooookay

> Can I not pattern-match to the head and tail of a list on the left side of a let??

###### 12 August 2019

> wat

{% include image.html
           img="assets/images/coq-kernel/nat-set-not-co-inductive.png" %}

> I somehow got a segmentation fault <br/>
> how does this happen

> I seem to have broken relative variables, somehow the de bruijn indexing is subtracting 1

> I don't know what on earth I might've done to break this lol

> It's broken when it I infer a constant, when it passes the body of the constant into the function, which I don't think it even should be doing??

> so I THINK the problem was that when I was decomposing a product type I forgot that the previous parameter is supposed to be in the context of later parameters and I wasn't pushing them into the local environment which made all the de Bruijn indices go bad
yeah <br/>
> [redacted]

> It's kinda terrifying I didn't uncover a bug this big until now <br/>
> Like how do I know I don't have other huge-ass bugs floating around <br/>
> I mean once I'm fully finished and I can start writing integration tests I'll finally have tests, but I don't use Coq which means there'll probably be a looot of stuff I won't think to cover

###### 14 August 2019

> Segmentation fault (core dumped)
>
> not again

> I was getting this because I was doing f @@ g a instead of f (g a)
>
> ...???

> somebody at ocaml doesn't want me using haskell patterns

> \*let me in meme\* let me $, leeet meeee $

> NOPE that's not the problem. great

> let me call my function without crashing

> I think it's [this](https://github.com/ocaml/ocaml/issues/8681) and idk how to work around it

> I thought I fixed it but there's still a segmentation fault and I honestly don't even know how to approach it shdghds

###### 15 August 2019

> anyway, so the segmentation isn't the fault of the OCaml compiler, because I installed the beta version that has the fix to the segmentation issue and recompiled Coq and the fault was still there <br/>
> so I guess at least we know what it isn't <br/>
> also I compiled Coq at a point in my branch where I thought things would work out okay until a specific point but it failed before then? so idk what's up with that

> I'm currently installing the latest base compiler at 4.08.1 instead of 4.09.0 so that's gonna go on for a while, then I might have to recompile Coq, and then it's back to figuring out the cause of the segmentation fault

> I'll also have to reinstall merlin oops

> I've got my first lead! Both of the programs that fail with a segfault have a mysterious unbound relative variable... hmm...

> Me: this variable is bound <br/>
> Coq: _UNBOUND_REL_1 <br/>
> Me: but it's right here. I've even extracted it and printed it out for you. <br/>
> Coq: _UNBOUND_REL_1 <br/>
> Me: this is relative variable number 1!!! what more do you want!!! <br/>
> Coq: _UNBOUND_REL_1

> [redacted]

[editor's note: this is the end of my notes on this segmentation problem?? how did I solve it??]

###### 21 August 2019

> I'm such a fool <br/>
> I originally named my file weightedDirectedGraph but then I changed it to weightedDigraph and I forgot to change the module name in the .mllib file from WeightedDirectedGraph to WeightedDigraph

> So I switched the implementation of the graph from my own messy Map to a nice official HashTbl kind of thing from ocamlgraph and I think it's slower???

###### 23 August 2019

> compiling master branch from scratch in a different directory bc I want to compare the difference between my branch and master to see what this weird bug is about

###### 25 August 2019

> Note to self need to add constraints from subtyping Consts, Vars, and Rels oops

###### 30 August 2019

> I found a bug, which was not the bug I was hoping to find, but every mistake fixed is good, and I'm extremely glad that bugs I've been finding only cause terminating programs to not typecheck and not nonterminating programs to typecheck <br/>
> Soundness is far more important than how complete it is whew

[editor's note: the bug was that I was assigning the same stage variable to each mutually-defined inductive type instead of a fresh one for each of them]

> Great. Now I HAVE to talk about mutual inductive definitions in my thesis

###### 6 September 2019

> something seems wrong about typing minus as nat* -> nat* -> nat* instead of nat* -> nat -> nat* but I can't figure out what...

###### 8 September 2019

> So about primitive record projections:
>   * Don't need annotations bc they project from a construction which can be a constant with annotations
>   * Don't need to annotate its type since constructor types come with full types and records aren't (co)inductive so they don't need finite annotations <br />
> However:
>   * Getting the number of annotations from a const requires counting them from their definition bodies which is Bad