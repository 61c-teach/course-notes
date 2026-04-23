---
title: "Parallel Programming Languages"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/vyTwKNWKpLw
:width: 100%
:title: "[CS61C FA20] Lecture 34.1 - Thread-Level Parallelism II: Parallel Programming Languages"
:::

::::

## Visuals

:::{figure} images/data-race.png
:label: fig-data-race
:width: 100%
:alt: "Instruction-sequence diagram on two threads or harts showing interleaved loads and stores to the same memory address without synchronization. Register operands and memory operands are labeled so the race manifests as a final value depending on scheduling order; arrows highlight the conflicting accesses that define the bug."

Data race example with RISC-V Instructions.
:::