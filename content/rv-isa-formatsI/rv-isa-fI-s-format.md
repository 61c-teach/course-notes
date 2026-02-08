---
title: "S-Format"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/JmxA8jF-LME
:width: 100%
:title: "[CS61C FA20] Lecture 11.5 - RISC-V Instruction Formats I: S-Format"
:::

::::

## Visuals

:::{figure} images/store-operation-isa.png
:label: fig-store-operation-isa
:width: 100%
:alt: "TODO"

Store operation (S-Type) instruction set.
:::

:::{figure} images/store-example.png
:label: fig-store-example
:width: 100%
:alt: "TODO"

Store operation instruction set example.
:::

:::{figure} images/R-I-S-type-comparison.png
:label: fig-R-I-S-type-comparison
:width: 100%
:alt: "TODO"

Instruction set comparsion between R-Type, I-Type, and S-Type.
:::

|   |   |   | funct3 |   | opcode |   |
| :-- | -- | -- | -- | -- | -- | --: |
| `imm[11:5]` | `rs2` | `rs1` | `000` | `imm[4:0]` | `0100011` | `sb` |
| `imm[11:5]` | `rs2` | `rs1` | `001` | `imm[4:0]` | `0100011` | `sh` |
| `imm[11:5]` | `rs2` | `rs1` | `010` | `imm[4:0]` | `0100011` | `sw` |

:::{figure} images/hex-isa-example.png
:label: fig-hex-isa-example
:width: 100%
:alt: "TODO"

Hex to instruction conversion example.
:::

:::{figure} images/hex-encode-example-2.png
:label: fig-hex-encode-example-2
:width: 100%
:alt: "TODO"

Hex to instruction encoding extra example.
:::