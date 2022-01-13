Require Import Coq.Program.Equality.
Require Import Coq.Unicode.Utf8_core.

Reserved Notation "r ≤ s" (at level 70, no associativity).

Inductive Ord : Type :=
| suc : Ord → Ord
| lim : ∀ {A : Type}, (A → Ord) → Ord.

Inductive Leq : Ord → Ord → Prop :=
| mono     : ∀ {r s}, r ≤ s → suc r ≤ suc s
| cocone   : ∀ {s A f}, (∃ (a : A), s ≤ f a) → s ≤ lim f
| limiting : ∀ {s A f}, (∀ (a : A), f a ≤ s) → lim f ≤ s
where "r ≤ s" := (Leq r s).

Definition Lt (r s : Ord) : Prop := suc r ≤ s.
Notation "r < s" := (Lt r s).

(* Admitted for brevity. *)
Property reflLeq (s : Ord) : s ≤ s. Admitted.
Property transLeq {r s t : Ord} (rs : r ≤ s) (st : s ≤ t) : r ≤ t. Admitted.

Inductive Acc (s : Ord) : Prop :=
| acc : (∀ r, r < s → Acc r) → Acc s.

Lemma accLeq : ∀ r s, r ≤ s → Acc s → Acc r.
Proof.
  intros r s rs acc.
  induction acc as [s p IH].
  exact (acc r (λ t tr, p t (transLeq tr rs))).
Qed.

Theorem accOrd : ∀ s, Acc s.
Proof.
  intros s.
  induction s as [s IH | A f IH].
  - destruct IH as [p].
    refine (acc (suc s) (λ r rsucs, acc r (λ t tr, p t (transLeq tr _)))).
    inversion rsucs as [r' s' rs | |].
    exact rs.
  - refine (acc (lim f) (λ r rlimf, _)).
    inversion rlimf as [| r' A' f' erfa eqr eqA |].
    dependent destruction H.
    destruct erfa as [a rfa].
    destruct (IH a) as [p].
    exact (p r rfa).
Qed.