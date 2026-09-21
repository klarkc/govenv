# Governance

Governance is Govenv's constitutional normative domain. It describes repository
or system states, transitions, effects, and semantic properties whose validity
is independent of which contributor or agent produced them.

Governance is distinct from protocol: two contributors may follow
different valid processes and still produce the same constitutionally valid
state. Operational guidance therefore does not become governance merely because
Govenv publishes it.

The governed roadmap is the canonical typed inventory of governance decisions.

```agda
{-# OPTIONS --safe #-}

module Govenv.Governance where

open import Govenv.Kernel.Roadmap using (Roadmap)
open import Govenv.Roadmap using (roadmap)

governance : Roadmap
governance = roadmap
```
