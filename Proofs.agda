----------------------------------------------------------------------
-- This module contains the proofs for the stack-machine's compiler --
-- authors: Matthew Thompson, Natalie Ravenhill, Yu-Yang Lin        --
----------------------------------------------------------------------
module Proofs where

open import Data.Nat
open import Data.Bool renaming (Bool to 𝔹; _∧_ to oldand)
open import Data.List 
open import Data.Product
open import Relation.Binary.PropositionalEquality renaming ([_] to ⟪_⟫)
open import Data.Maybe
open import Data.String renaming (_++_ to _^_)
open import Data.Empty

-- Stuff used for the proofs.
open import AbstractSyntax
open import DenSemantics
open import CompExp

----------------------------------------
---SYNTAX FOR EQUATIONAL REASONING---
-----------------------------------------
_≡[_]_ : ∀ {A : Set} (x : A) {y z : A} → x ≡ y → y ≡ z → x ≡ z
x ≡[ refl ] refl = refl
infixr 2 _≡[_]_

_done : ∀ {A : Set} (x : A) → x ≡ x
x done = refl
infix 2 _done

--
cong-just-elim : {a b : List ℕ} → just a ≡ just b → a ≡ b
cong-just-elim p = cong f p
    where
      f : Maybe (List ℕ) → List ℕ 
      f (just x) = x
      f nothing = [] -- This case doesn't happen

--
cong-just-intro : {A : Set} {a b : A} → a ≡ b → just a ≡ just b
cong-just-intro p = cong f p
    where
      f : {B : Set} → B → Maybe B
      f x = just x

--
cong-list : {A : Set} {a b : A} → (a ∷ []) ≡ (b ∷ []) → a ≡ b
cong-list refl = refl


sym-trans : {A : Set} {a b c : A} → a ≡ b → a ≡ c → b ≡ c
sym-trans refl refl = refl

-------------------------
-- PROOF FOR SOUNDNESS --
-------------------------
--anything that has not been defined in compile will just be Err 
sound : (T : Set) (e : Exp T) (p : program) (n : ℕ) (σ : state) (k : ℕ) →
        ⟨⟨ compile e ⟩⟩ [] , σ , k ≡ just [ n ] → ⟦ e ⟧ σ ≡ just n 

--soundness for booleans, proved by pattern matching (Natalie)
sound .𝔹 (B true) p n σ zero ()
sound .𝔹 (B false) p n σ zero ()
sound .𝔹 (B true) p .1 σ (suc k) refl = refl
sound .𝔹 (B false) p .0 σ (suc k) refl = refl

--soundness for nats, proved by pattern matching (Natalie)
sound .ℕ (N zero) p n σ zero ()
sound .ℕ (N zero) p .0 σ (suc k) refl = refl
sound .ℕ (N (suc x)) p n σ zero ()
sound .ℕ (N (suc x)) p .(suc x) σ (suc k) refl = refl


--soundness for Variables (Natalie & Mat & Yu)
--q proves that we can get n from compiling Var x
--show we can get v from compiling Var x
--then v must be equal to n
sound .ℕ (V x) p n σ k q  with inspect σ x 
sound .ℕ (V x) p n σ zero () | ⟪ eq ⟫
sound .ℕ (V x) p n σ (suc k) q | ⟪ eq ⟫ = sym-trans eq (varlemma1 x σ k n q) where

  varlemma1 :  ∀ x σ k n → ⟨⟨ Var x ∷ [] ⟩⟩ [] , σ , (suc k) ≡ just (n ∷ []) → σ x ≡ just n
  varlemma1 x σ k n p with σ x | inspect σ x
  ... | just m | ⟪ eq ⟫ = cong-just-intro (cong-list (cong-just-elim p))
    where
      f : {A : Set} → A → Maybe A
      f a = just a
  varlemma1 x σ k n () | nothing | ⟪ eq ⟫

--soundness for addition (Natalie)
sound .ℕ (e1 ⊕ e2) p n σ k q with (⟦ e1 ⟧ σ) | (⟦ e2 ⟧ σ) | inspect ⟦ e1 ⟧ σ | inspect ⟦ e2 ⟧ σ 
sound .ℕ (e1 ⊕ e2) p zero σ k q | just zero | just zero | ⟪ eq1 ⟫ | ⟪ eq2 ⟫ = refl
sound .ℕ (e1 ⊕ e2) p n σ k q | just x1 | just x2 | ⟪ eq1 ⟫ | ⟪ eq2 ⟫ = {!!}
sound .ℕ (e1 ⊕ e2) p n σ k q | just x | nothing | ⟪ eq1 ⟫ | ⟪ eq2 ⟫  = {!!}
sound .ℕ (e1 ⊕ e2) p n σ k q | nothing | just x | ⟪ eq1 ⟫ | ⟪ eq2 ⟫  = {!!}
sound .ℕ (e1 ⊕ e2) p n σ k q | nothing | nothing | ⟪ eq1 ⟫ | ⟪ eq2 ⟫ = {!!} where

  lemplus : ∀ σ k n e1 e2 x1 x2 → ⟨⟨ (compile e1 ++ compile e2) ++ Add ∷ [] ⟩⟩ [] , σ , (suc k) ≡ just [ n ]
                    → ⟦ e1 ⟧ σ ≡ just x1 → ⟦ e2 ⟧ σ ≡ just x2 
                    → ⟦ e1 ⊕ e2 ⟧ σ ≡ just (x1 + x2)
  lemplus σ k n e1 e2 x1 x2 = {!!}

-- Soundness for subtraction
sound .ℕ (e ⊝ e₁) p n σ zero q = {!!}
sound .ℕ (e ⊝ e₁) p n σ (suc k) x = {!!}

sound .𝔹 (¬ e) p n σ k x = {!!}

sound .𝔹 (e & e₁) p n σ k x = {!!}

sound .𝔹 (e ∥ e₁) p n σ k x = {!!}

sound .𝔹 (e <= e₁) p n σ k x = {!!}

sound .𝔹 (e >= e₁) p n σ k x = {!!}

sound .𝔹 (e AbstractSyntax.== e₁) p n σ k x = {!!}

sound .ℕ (if_then_else e e₁ e₂) p n σ k x = {!!}

sound .ℕ (e ⊗ e₁) p n σ k x = {!!}

sound .ℕ (e ⊘ e₁) p n σ k x = {!!}

sound .ℕ (for e do e₁) p n σ k x = {!!}
  
------------------------
-- PROOF FOR ADEQUACY --
------------------------
adeq : (T : Set) (e : Exp T) (p : program) (σ : state) (n : ℕ) →
        ⟦ e ⟧ σ ≡ just n → (∃ λ k → ⟨⟨ compile e ⟩⟩ [] , σ , k ≡ just [ n ])
adeq .𝔹 (B x) p σ n x₁ = {!!}
adeq .ℕ (N x) p σ n x₁ = {!!}
adeq .ℕ (V x) p σ n x₁ = {!!}
adeq .ℕ (e ⊕ e₁) p σ n x = {!!}
adeq .ℕ (if_then_else e e₁ e₂) p σ n x = {!!}

adeq _ _ _ _ _ _ = {!!} 
              
adeq-fail : (T : Set) (e : Exp T) (p : program) (σ : state) (n : ℕ) →
        ⟦ e ⟧ σ ≡ nothing → (∃ λ k → ⟨⟨ compile e ⟩⟩ [] , σ , k ≡ nothing)
adeq-fail = {!!}
