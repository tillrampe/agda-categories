{-# OPTIONS --without-K --safe --lossy-unification #-}

module Categories.Diagram.End.Properties where

-- The following conventions are taken in this file: C is the 'source' category
-- and D is the destination. If two source categories are needed, the other is
-- called 'P' for "parameter", following MacLane. F, G and H are functors and ef,
-- eg and eh are witnesses of their respective ends.

open import Level
open import Data.Product using (Σ; _,_)
open import Function using (_$_)

open import Categories.Category using (Category)
open import Categories.Category.Construction.Arrow using (Morphism; mor)
open import Categories.Category.Construction.Functors using (Functors)
open import Categories.Diagram.End using () renaming (End to ∫)
open import Categories.Diagram.Equalizer using (Equalizer)
open import Categories.Diagram.Wedge using (Wedge; module Wedge-Morphism)
open import Categories.Functor using (Functor)
open import Categories.Functor.Bifunctor using (Bifunctor)
open import Categories.NaturalTransformation using (NaturalTransformation; _∘ᵥ_) renaming (_∘ʳ_ to _▹ⁿ_; id to idN)
open import Categories.NaturalTransformation.Dinatural hiding (_≃_)
open import Categories.NaturalTransformation.Equivalence using () renaming (_≃_ to _≃ⁿ_)
open import Categories.NaturalTransformation.NaturalIsomorphism using (NaturalIsomorphism) renaming (_≃_ to _≃ⁱ_)
open import Categories.Object.Product.Indexed
open import Categories.Object.Terminal as Terminal

import Categories.Category.Construction.Wedges as Wedges
import Categories.Morphism as M
import Categories.Morphism.Reasoning as MR

private
  variable
    o ℓ e o′ ℓ′ e′ : Level
    P C D : Category o ℓ e

open Category using (o-level; ℓ-level; e-level)

module _ (F : Bifunctor (Category.op C) C D) where
  open Wedges F

  -- Being an End is the same as being a Terminal object in the category of Wedges
  End⇒Terminal : ∫ F → Terminal Wedges
  End⇒Terminal c =  record
    { ⊤ = wedge
    ; ⊤-is-terminal = record
      { ! = λ {A} → record { u = factor A ; commute = universal }
      ; !-unique = λ {A} f → unique {A} (Wedge-Morphism.commute f)
      }
    }
    where
    open ∫ c

  Terminal⇒End : Terminal Wedges → ∫ F
  Terminal⇒End i = record
    { wedge = ⊤
    ; factor = λ W → u {W₁ = W} !
    ; universal = commute !
    ; unique = λ {_} {g} x → !-unique (record { u = g ; commute = x })
    }
    where
    open Terminal.Terminal i
    open Wedge-Morphism

-- A Natural Transformation between two functors induces an arrow between the
-- (object part of) the respective ends.
module _ {F G : Bifunctor (Category.op C) C D} (F⇒G : NaturalTransformation F G) where
  open ∫ renaming (E to end)
  open Category D

  opaque
    end-η : {{ef : ∫ F}} {{eg : ∫ G}} → end ef ⇒ end eg
    end-η {{ef}} {{eg}} = factor eg (record
      { E = ∫.E ef
      ; dinatural = dtHelper record
        { α = λ c → η (c , c) ∘ dinatural.α ef c
        ; commute = λ {C} {C′} f → begin
          G.₁ (C.id , f) ∘ (η (C , C) ∘ αf C) ∘ D.id       ≈⟨ pullˡ sym-assoc ⟩
          ((G.₁ (C.id , f) ∘ η (C , C)) ∘ αf C) ∘ D.id     ≈⟨ nt.sym-commute (C.id , f) ⟩∘⟨refl ⟩∘⟨refl ⟩
          ((η (C , C′) ∘ F.₁ (C.id , f)) ∘ αf C) ∘ D.id    ≈⟨ assoc²αε ⟩
          η (C , C′) ∘ (F.₁ (C.id , f) ∘ αf C ∘ D.id)      ≈⟨ refl⟩∘⟨ αf-comm f ⟩
          η (C , C′) ∘ F.₁ (f , C.id) ∘ αf C′ ∘ D.id       ≈⟨ assoc²εα ⟩
          ((η (C , C′) ∘ F.₁ (f , C.id)) ∘ αf C′) ∘ D.id   ≈⟨ nt.commute (f , C.id) ⟩∘⟨refl ⟩∘⟨refl ⟩
          ((G.₁ (f , C.id) ∘ η (C′ , C′)) ∘ αf C′) ∘ D.id  ≈⟨ pushˡ assoc ⟩
          G.₁ (f , C.id) ∘ (η (C′ , C′) ∘ αf C′) ∘ D.id    ∎
        }
      })
      where
      module nt = NaturalTransformation F⇒G
      open nt using (η)
      open HomReasoning
      module C = Category C
      module D = Category D
      module F = Functor F
      module G = Functor G
      open DinaturalTransformation (dinatural ef) renaming (α to αf; commute to αf-comm)
      open DinaturalTransformation (dinatural eg) renaming (α to αg; commute to αg-comm)
      open Wedge
      open MR D

module _ {F : Bifunctor (Category.op C) C D} (ω₁ ω₂ : ∫ F) where
  private
    module ω₁ = ∫ ω₁
    module ω₂ = ∫ ω₂
  open Category D
  open M D
  open _≅_
  open Iso
  open MR D
  open HomReasoning

  end-unique : ∫.E ω₁ ≅ ∫.E ω₂
  end-unique .to = ω₁.factor ω₂.wedge
  end-unique .from = ω₂.factor ω₁.wedge
  end-unique .iso .isoʳ = ω₂.unique′ $ pullˡ ω₂.universal ○ ω₁.universal ○ ⟺ identityʳ
  end-unique .iso .isoˡ = ω₁.unique′ $ pullˡ ω₁.universal ○ ω₂.universal ○ ⟺ identityʳ

module _ {C : Category o ℓ e } {D : Category o′ ℓ′ e′} where
  open MR D
  private
    open module D = Category D
    module C = Category C
    variable
     F G H : Bifunctor (Category.op C) C D
  open HomReasoning
  open NaturalTransformation using (η)

  opaque
    unfolding end-η

    -- "Partial functorality"
    end-identity : {{ef : ∫ F}} → end-η (idN {F = F}) ≈ id
    end-identity {F = F} {{ef}} = ∫.unique ef id-comm

    end-η-commute : {{ef : ∫ F}} {{eg : ∫ G}} (α : NaturalTransformation F G) →
                    (c : C.Obj) → ∫.dinatural.α eg c ∘ end-η α ≈ α .η (c , c) ∘ ∫.dinatural.α ef c
    end-η-commute ⦃ _ ⦄ ⦃ eg ⦄ α c = ∫.universal eg

    end-η-resp-≈ : {{ef : ∫ F}} {{eg : ∫ G}} {α β : NaturalTransformation F G} →
                   α ≃ⁿ β → end-η α ≈ end-η β
    end-η-resp-≈ {{ef}} {{eg}} e = ∫.unique eg $ ∫.universal eg ○ ⟺ e ⟩∘⟨refl

    end-η-resp-∘ : (α : NaturalTransformation F G) (β : NaturalTransformation G H)
                   {{ef : ∫ F}} {{eg : ∫ G}} {{eh : ∫ H}} →
                   end-η (β ∘ᵥ α) ≈ end-η β ∘ end-η α
    end-η-resp-∘ α β {{ef}} {{eg}} {{eh}} = eh.unique $ extendʳ eh.universal ○ refl⟩∘⟨ eg.universal ○ sym-assoc
      where module eg = ∫ eg
            module eh = ∫ eh

module _ {F G : Bifunctor (Category.op C) C D} (F≃G : F ≃ⁱ G) {{ef : ∫ F}} {{eg : ∫ G}} where
  open Category D
  open M D
  open _≅_
  open Iso
  open HomReasoning
  open module F≃G = NaturalIsomorphism F≃G
  -- a duplicate proof of [_]-resp-≅ for the "partial" case
  end-resp-≅ : ∫.E ef ≅ ∫.E eg
  end-resp-≅ .to = end-η F⇐G
  end-resp-≅ .from = end-η F⇒G
  end-resp-≅ .iso .isoʳ = ⟺ (end-η-resp-∘ F⇐G F⇒G) ○ end-η-resp-≈ {α = F⇒G ∘ᵥ F⇐G} {β = idN} (λ {x} → F≃G.iso.isoʳ x) ○ end-identity {F = G}
  end-resp-≅ .iso .isoˡ = ⟺ (end-η-resp-∘ F⇒G F⇐G) ○ end-η-resp-≈ {α = F⇐G ∘ᵥ F⇒G} {β = idN} (λ {x} → F≃G.iso.isoˡ x) ○ end-identity {F = F}

  -- See also ≅-yields-end in Categories.Diagram.End.Limit

-- We can characterize an end in terms of products and equalizers
-- Remark 1.2.4 of Coend Calculus
-- See also Categories.Diagram.Limit.Properties.build-lim
module _
  {P : Bifunctor (Category.op C) C D}
  (OP : IndexedProductOf D λ X → Bifunctor.₀ P (X , X))
  (MP : IndexedProductOf D λ f → Bifunctor.₀ P (Morphism.dom {C = C} f , Morphism.cod f))
  where

  open Category D

  private
    module P = Bifunctor P
    module OP = IndexedProductOf OP
    module MP = IndexedProductOf MP

    s t : OP.X ⇒ MP.X
    s = MP.⟨ (λ f → P.₁ʳ (Morphism.arr f) ∘ OP.π (Morphism.dom f)) ⟩
    t = MP.⟨ (λ f → P.₁ˡ (Morphism.arr f) ∘ OP.π (Morphism.cod f)) ⟩

  open HomReasoning
  open MR D

  build-End : Equalizer D s t → ∫ P
  build-End eq = record
    { wedge = record
      { E = obj
      ; dinatural = extranaturalʳ
        (λ X → OP.π X ∘ arr)
        λ {X Y f} → begin
          P.₁ʳ f ∘ (OP.π X ∘ arr)  ≈⟨ extendʳ MP.commute ⟨
          MP.π (mor f) ∘ (s ∘ arr) ≈⟨ refl⟩∘⟨ equality ⟩
          MP.π (mor f) ∘ (t ∘ arr) ≈⟨ extendʳ MP.commute ⟩
          P.₁ˡ f ∘ (OP.π Y ∘ arr)  ∎
      }
    ; factor = λ W → equalize (factor-lemma W)
    ; universal = Equiv.sym (pushʳ universal) ○ OP.commute
    ; unique = λ eq′ → Equiv.sym (unique (OP.unique (sym-assoc ○ eq′)))
    }
    where
      open Equalizer eq
      abstract
        factor-lemma : (W : Wedge P) → s ∘ OP.⟨ Wedge.dinatural.α W ⟩ ≈ t ∘ OP.⟨ Wedge.dinatural.α W ⟩
        factor-lemma W = begin
          s ∘ OP.⟨ dinatural.α ⟩
            ≈⟨ MP.⟨⟩∘ (λ f → P.₁ʳ (Morphism.arr f) ∘ OP.π (Morphism.dom f)) OP.⟨ dinatural.α ⟩ ⟩
          MP.⟨ (λ f → (P.₁ʳ (Morphism.arr f) ∘ OP.π (Morphism.dom f)) ∘ OP.⟨ dinatural.α ⟩) ⟩
            ≈⟨ MP.⟨⟩-cong (pullʳ OP.commute) ⟩
          MP.⟨ (λ f → P.₁ʳ (Morphism.arr f) ∘ dinatural.α (Morphism.dom f)) ⟩
            ≈⟨ MP.⟨⟩-cong (extranatural-commʳ dinatural) ⟩
          MP.⟨ (λ f → P.₁ˡ (Morphism.arr f) ∘ dinatural.α (Morphism.cod f)) ⟩
            ≈⟨ MP.⟨⟩-cong (pullʳ OP.commute) ⟨
          MP.⟨ (λ f → (P.₁ˡ (Morphism.arr f) ∘ OP.π (Morphism.cod f)) ∘ OP.⟨ dinatural.α ⟩) ⟩
            ≈⟨ MP.⟨⟩∘ (λ f → P.₁ˡ (Morphism.arr f) ∘ OP.π (Morphism.cod f)) OP.⟨ dinatural.α ⟩ ⟨
          t ∘ OP.⟨ dinatural.α ⟩
            ∎
          where open Wedge W
