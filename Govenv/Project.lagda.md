# Project

Govenv has one canonical project identity. Distributions may project other branding, but they do not rename Govenv itself.

```agda
{-# OPTIONS --safe #-}

module Govenv.Project where

open import Agda.Builtin.String using (String)

data ProjectId : Set where
  govenv : ProjectId

project : ProjectId
project = govenv

description : String
description = "A type system for your repository. Formally define what your project is allowed to become."
```
