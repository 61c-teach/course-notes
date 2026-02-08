---
title: "J-Format"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/hkVUmw460Kw
:width: 100%
:title: "[CS61C FA20] Lecture 12.3 - RISC-V Instruction Formats II: J-Format"
:::

::::

## Visuals

:::{figure} images/jalr-isa.png
:label: fig-jalr-isa
:width: 100%
:alt: "TODO"

jalr instruction format.
:::

:::{figure} images/jump-operation-walkthrough.png
:label: fig-jump-operation-walkthrough
:width: 100%
:alt: "TODO"

Code illustrated example with jump operation.
:::

:::{figure} images/jal-isa.png
:label: fig-jal-isa
:width: 100%
:alt: "TODO"

jal instruction format.
:::

|   |   | opcode |   |
| :-- | -- | -- | --: |
| `imm[20\|10:1\|11\|19:12]` | `rd` | `1101111` | `jal` |