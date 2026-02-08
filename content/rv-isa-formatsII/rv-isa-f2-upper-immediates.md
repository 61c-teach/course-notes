---
title: "Upper Immediates"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/e6WlS-QsNZc
:width: 100%
:title: "[CS61C FA20] Lecture 12.2 - RISC-V Instruction Formats II: Upper Immediates"
:::

::::

## Visuals

:::{figure} images/utype-isa.png
:label: fig-utype-isa
:width: 100%
:alt: "TODO"

U-Type instruction set format.
:::

|   |   | opcode |   |
| :-- | -- | -- | --: |
| `imm[31:12]` | `rd` | `0010111` | `auipc` |
| `imm[31:12]` | `rd` | `0110111` | `lui` |