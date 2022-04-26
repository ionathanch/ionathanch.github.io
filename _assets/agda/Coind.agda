open import Data.Empty

{-# NO_UNIVERSE_CHECK #-}
record Contra : Set where
  coinductive
  constructor contra
  field
    A : Set
    a : A
    ¬a : A → ⊥
open Contra

¬c : Contra → ⊥
¬c = λ c → (¬a c) (a c)

{-# NON_TERMINATING #-}
c : Contra
c = contra Contra c ¬c

ng : ⊥
ng = ¬c c