---
title: "J-Type"
subtitle: TODO
---

(sec-j-type)=
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

Coming soon!

<!--

## Visuals



:::{figure} images/jal-isa.png
:label: fig-jal-isa
:width: 100%
:alt: "TODO"

jal instruction format.
:::

|   |   | opcode |   |
| :-- | -- | -- | --: |
| `imm[20\|10:1\|11\|19:12]` | `rd` | `1101111` | `jal` |

---
title: "A Bit About Machine Program"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO


TODO: unconditional branch "definition" -- include this later when we discuss instruction formats

You might wonder if you can just make an unconditional branch using a conditional one, like beq x0, x0, label. While that would always jump, there is a catch: the range of a branch is shorter. Because RISC-V uses 32-bit instructions, we have to fit the instruction type, the registers being compared, and the label (an immediate value) into those 32 bits. A dedicated jump instruction doesn't need to specify registers to compare, so its immediate value can be larger, allowing it to reach farther in the program.

-->