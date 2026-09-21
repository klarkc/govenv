module Govenv.Adapter.ArchitectureAssurance where

open import Agda.Builtin.IO using (IO)
open import Agda.Builtin.List using (List; []; _∷_)
open import Agda.Builtin.Maybe using (Maybe; just; nothing)
open import Agda.Builtin.String using
  (String; primStringAppend)
open import Agda.Builtin.Unit using (⊤)
open import Govenv.Assurance.GV1 using
  ( Subject; Observation; dependencies
  ; Diagnostic; sourceOutsideGovenv
  ; Obligation; rule )
open import Govenv.Kernel.Fact using
  (Facts; observed; empty; _∷ᶠ_)
open import Govenv.Kernel.Rule using (Rule)
open import Govenv.Kernel.Verdict using
  (holds; violated; unknown)

private
  infixr 5 _++_

  _++_ : String → String → String
  _++_ = primStringAppend

candidateFacts :
  List String → Facts Subject Observation dependencies
candidateFacts paths = observed paths ∷ᶠ empty

candidateResult : List String → Maybe String
candidateResult paths with Rule.check rule (candidateFacts paths)
... | holds = nothing
... | violated (sourceOutsideGovenv path) =
  just
    ("GV1 source boundary violation: versioned Agda source outside " ++
     "Govenv source roots: " ++ path)
... | unknown _ =
  just "GV1 source placement assurance is unknown."

postulate
  runObservedCheck :
    (List String → Maybe String) → IO ⊤

{-# FOREIGN GHC
import qualified Data.Text as Text
import qualified System.Exit as Exit
import qualified System.Process as Process

runObservedCheckImpl
  :: ([Text.Text] -> Maybe Text.Text)
  -> IO ()
runObservedCheckImpl validate = do
  stdoutText <-
    Process.readProcess
      "git"
      ["ls-files", "--", "*.agda", "*.lagda.md"]
      ""
  let paths =
        filter (not . Text.null) .
        map Text.pack .
        lines $
        stdoutText
  case validate paths of
    Nothing -> pure ()
    Just diagnostic -> Exit.die (Text.unpack diagnostic)
#-}

{-# COMPILE GHC runObservedCheck = runObservedCheckImpl #-}

main : IO ⊤
main = runObservedCheck candidateResult
