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

Coming soon!

<!--

## Visuals

:::{figure} images/store-operation-isa.png
:label: fig-store-operation-isa
:width: 100%
:alt: "TODO"

Store operation (S-Type) instruction set.
:::

:::{figure} images/practice-sw.png
:label: fig-practice-sw
:width: 100%
:alt: "TODO"

Store operation instruction set example.
:::

:::{figure} images/practice-sw-imm.png
:label: fig-practice-sw-imm
:width: 35%
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

:::{figure} images/hex-encode-example-2.png
:label: fig-hex-encode-example-2
:width: 100%
:alt: "TODO"

(remove) Hex to instruction encoding extra example.
:::

### TODO: put this somewhere

:::{warning} Why do we use 17 bits to specify the operation?

Remmber there are only 10 R-Type instructions! Across the entire base RV32I instruction set, there are certainly fewer instructions than the $2^32$ possible representable things in a 32-bit word, so some redundancy is unavoidable.

More importantly, we will see that to simplify architecture design, different instruction formats **reuse the same bit positions for the same fields wherever possible**. The register fields `rs1`, `rs2`, and `rd` are therefore prioritized, and fields like `funct3` and `funct7` occupy the remaining bits.

:::

-->