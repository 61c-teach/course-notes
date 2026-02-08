---
title: "B-Format"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/cH5MqwqX_Kg
:width: 100%
:title: "[CS61C FA20] Lecture 12.1 - RISC-V Instruction Formats II: B-Format"
:::

::::

## Visuals

:::{figure} images/branch-isa-register.png
:label: fig-branch-isa-register
:width: 100%
:alt: "TODO"

Branch operation instruction format with registers.
:::

:::{figure} images/branch-isa-offset.png
:label: fig-branch-isa-offset
:width: 100%
:alt: "TODO"

Branch operation instruction format with labeled offset.
:::

:::{figure} images/branch-example.png
:label: fig-branch-example
:width: 100%
:alt: "TODO"

Branch operation instruction example.
:::

:::{figure} images/branch-example-sol.png
:label: fig-branch-example-sol
:width: 100%
:alt: "TODO"

Branch operation instruction example solution.
:::

:::{figure} images/ISB-type-comparison.png
:label: fig-ISB-type-comparison
:width: 100%
:alt: "TODO"

I-Type, S-Type, and B-Type instruction format comparison.
:::

|   |   |   | funct3 |   | opcode |   |
| :-- | -- | -- | -- | -- | -- | --: |
| `imm[12\|10:5]` | `rs2` | `rs1` | `000` | `imm[4:1\|11]` | `1100011` | `beq` |
| `imm[12\|10:5]` | `rs2` | `rs1` | `001` | `imm[4:1\|11]` | `1100011` | `bne` |
| `imm[12\|10:5]` | `rs2` | `rs1` | `100` | `imm[4:1\|11]` | `1100011` | `blt` |
| `imm[12\|10:5]` | `rs2` | `rs1` | `110` | `imm[4:1\|11]` | `1100011` | `bltu` |
| `imm[12\|10:5]` | `rs2` | `rs1` | `101` | `imm[4:1\|11]` | `1100011` | `bge` |
| `imm[12\|10:5]` | `rs2` | `rs1` | `111` | `imm[4:1\|11]` | `1100011` | `bgeu` |