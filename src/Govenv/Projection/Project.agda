{-# OPTIONS --safe #-}

module Govenv.Projection.Project where

open import Agda.Builtin.String using (String)
open import Govenv.Project

renderProjectName : ProjectId → String
renderProjectName govenv = "Govenv"

projectName : String
projectName = renderProjectName project

projectDescription : String
projectDescription = description
