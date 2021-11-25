{-# OPTIONS --type-in-type #-}

data ⊥ : Set where

℘ : ∀ {ℓ} → Set ℓ → Set _
℘ {ℓ} S = S → Set

U : Set
U = ∀ (X : Set) → (℘ (℘ X) → X) → ℘ (℘ X)

{- If using two impredicative universe layers instead of type-in-type:
U : Set₁
U = ∀ (X : Set₁) → (℘ (℘ X) → X) → ℘ (℘ X)
-}

τ : ℘ (℘ U) → U
τ t = λ X f p → t (λ x → p (f (x X f)))

σ : U → ℘ (℘ U)
σ s = s U τ

Δ : ℘ U
Δ y = (∀ p → σ y p → p (τ (σ y))) → ⊥

Ω : U 
Ω = τ (λ p → (∀ x → σ x p → p x))

R : ∀ p → (∀ x → σ x p → p x) → p Ω
R _ 𝟙 = 𝟙 Ω (λ x → 𝟙 (τ (σ x)))

M : ∀ x → σ x Δ → Δ x
M _ 𝟚 𝟛 = 𝟛 Δ 𝟚 (λ p → 𝟛 (λ y → p (τ (σ y))))

L : (∀ p → (∀ x → σ x p → p x) → p Ω) → ⊥
L 𝟘 = 𝟘 Δ M (λ p → 𝟘 (λ y → p (τ (σ y))))

false : ⊥
false = L R