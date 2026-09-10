{-# OPTIONS --safe #-}

module Govenv.Projection.SemanticDiff where

open import Agda.Builtin.Bool using (Bool; true; false)
open import Agda.Builtin.Char using (Char; primIsSpace)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.Nat using (Nat; zero; suc; _+_; _<_; _==_)
open import Agda.Builtin.String using
  ( String; primStringAppend; primStringEquality
  ; primStringFromList; primStringToList )

data SemanticSpan : Set where
  same : List String → SemanticSpan
  changed : List String → List String → SemanticSpan

record Anchor : Set where
  constructor anchor
  field
    oldSkip : Nat
    newSkip : Nat
    runLength : Nat

open Anchor

private
  infixr 5 _++ₗ_

  _++ₗ_ : {A : Set} → List A → List A → List A
  [] ++ₗ ys = ys
  (x ∷ xs) ++ₗ ys = x ∷ (xs ++ₗ ys)

  reverse : {A : Set} → List A → List A
  reverse values = go values []
    where
    go : {A : Set} → List A → List A → List A
    go [] acc = acc
    go (x ∷ xs) acc = go xs (x ∷ acc)

  length : {A : Set} → List A → Nat
  length [] = zero
  length (_ ∷ xs) = suc (length xs)

  take : {A : Set} → Nat → List A → List A
  take zero xs = []
  take (suc n) [] = []
  take (suc n) (x ∷ xs) = x ∷ take n xs

  drop : {A : Set} → Nat → List A → List A
  drop zero xs = xs
  drop (suc n) [] = []
  drop (suc n) (_ ∷ xs) = drop n xs

  finishWord : List Char → List String → List String
  finishWord [] acc = acc
  finishWord chars acc = primStringFromList (reverse chars) ∷ acc

  splitChars : List Char → List Char → List String → List String
  splitChars [] current acc = reverse (finishWord current acc)
  splitChars (char ∷ rest) current acc with primIsSpace char
  ... | true = splitChars rest [] (finishWord current acc)
  ... | false = splitChars rest (char ∷ current) acc

  words : String → List String
  words value = splitChars (primStringToList value) [] []

  commonRun : List String → List String → Nat
  commonRun [] right = zero
  commonRun left [] = zero
  commonRun (x ∷ xs) (y ∷ ys) with primStringEquality x y
  ... | true = suc (commonRun xs ys)
  ... | false = zero

  countToken : String → List String → Nat
  countToken target [] = zero
  countToken target (word ∷ rest) with primStringEquality target word
  ... | true = suc (countToken target rest)
  ... | false = countToken target rest

  uniqueInBoth : String → List String → List String → Bool
  uniqueInBoth word oldWords newWords
    with countToken word oldWords == 1 | countToken word newWords == 1
  ... | true | true = true
  ... | _ | _ = false

  anchorCost : Anchor → Nat
  anchorCost value = oldSkip value + newSkip value

  betterAnchor : Anchor → Maybe Anchor → Maybe Anchor
  betterAnchor candidate nothing = just candidate
  betterAnchor candidate (just current)
    with anchorCost candidate < anchorCost current
  ... | true = just candidate
  ... | false with anchorCost current < anchorCost candidate
  ...   | true = just current
  ...   | false with runLength current < runLength candidate
  ...     | true = just candidate
  ...     | false = just current

  scanNew :
    List String → List String → Nat → Nat →
    List String → List String → Maybe Anchor → Maybe Anchor
  scanNew allOld allNew oldOffset newOffset oldWords [] best = best
  scanNew allOld allNew oldOffset newOffset [] newWords best = best
  scanNew allOld allNew oldOffset newOffset oldWords@(old ∷ olds)
    newWords@(new ∷ news) best with primStringEquality old new
  ... | false =
      scanNew allOld allNew oldOffset (suc newOffset) oldWords news best
  ... | true with uniqueInBoth old allOld allNew
  ...   | false =
      scanNew allOld allNew oldOffset (suc newOffset) oldWords news best
  ...   | true =
      scanNew allOld allNew oldOffset (suc newOffset) oldWords news
        (betterAnchor
          (anchor oldOffset newOffset (commonRun oldWords newWords)) best)

  scanOld :
    List String → List String → Nat → List String → Maybe Anchor → Maybe Anchor
  scanOld allOld allNew oldOffset [] best = best
  scanOld allOld allNew oldOffset oldWords@(_ ∷ olds) best =
    scanOld allOld allNew (suc oldOffset) olds
      (scanNew allOld allNew oldOffset zero oldWords allNew best)

  bestAnchor : List String → List String → Maybe Anchor
  bestAnchor oldWords newWords =
    scanOld oldWords newWords zero oldWords nothing

  prependSame : List String → List SemanticSpan → List SemanticSpan
  prependSame [] rest = rest
  prependSame values (same next ∷ rest) = same (values ++ₗ next) ∷ rest
  prependSame values rest = same values ∷ rest

  prependChanged :
    List String → List String → List SemanticSpan → List SemanticSpan
  prependChanged [] [] rest = rest
  prependChanged old new (changed oldNext newNext ∷ rest) =
    changed (old ++ₗ oldNext) (new ++ₗ newNext) ∷ rest
  prependChanged old new rest = changed old new ∷ rest

  diffFuel : Nat → List String → List String → List SemanticSpan
  diffFuel zero old new = prependChanged old new []
  diffFuel (suc fuel) [] [] = []
  diffFuel (suc fuel) [] new = prependChanged [] new []
  diffFuel (suc fuel) old [] = prependChanged old [] []
  diffFuel (suc fuel) old@(x ∷ xs) new@(y ∷ ys)
    with primStringEquality x y
  ... | true = prependSame (x ∷ []) (diffFuel fuel xs ys)
  ... | false with bestAnchor old new
  ...   | nothing = prependChanged old new []
  ...   | just (anchor oldOffset newOffset commonLength) =
      prependChanged
        (take oldOffset old)
        (take newOffset new)
        (prependSame
          (take commonLength (drop oldOffset old))
          (diffFuel fuel
            (drop commonLength (drop oldOffset old))
            (drop commonLength (drop newOffset new))))

semanticDiff : String → String → List SemanticSpan
semanticDiff old new =
  diffFuel
    (length oldWords + length newWords)
    oldWords
    newWords
  where
  oldWords : List String
  oldWords = words old

  newWords : List String
  newWords = words new
