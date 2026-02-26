---
title: "B-Type"
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

More coming soon!

### RISC-V Extension: 16-bit instructions

RISC-V Base ISA for RV32, RV64, RV128 all have 32-bit wide instructions. The "Base" ISA is **extended** by instruction **extensions** that do a range of items: general multiplication, different architecture support, etc.

One such extension is the **16-bit compressed extension** extension, which accommodates _variable-length_ instructions that are multiples of 16-bits in length. To proactively accommodate this and other extensions, the RISC-V Base ISA encodes **half-word branch offsets**, even when there are no 16-bit instructions in the base set.

In this course, we only focus on RISC-V processors with 32-bit instructions. Implications of this half-word branch offset:

* Half of possible branch targets will be errors
RISC-V conditional branches can only branch to $\pm 2^{10}$ instructions away from the PC.

:::{tip} Quick Check

**True/False**: If a program only has only 32-bit instructions, bit position 8 of all B-Type instructions will always be `0`.
:::

:::{note} Show Answer
**True**. In B-Type instructions, branch offsets are encoded as half-word offsets, meaning that `imm[0]` is `0`. If a program only has 32-bit instructions, then conditional branches will only ever be multiples of words, e.g., 4 bytes, and we will only ever jump by two half-words. In this case, constrain `imm[1]` and `imm[0]` to be `0`.
:::

## B-Type vs. I-Type, S-Type: Immediate Formats

Recall a core component of RISC-V design is to keep fields as consistent as possible across instruction formats. We have already seen how source/destination register fields `rs1`, `rs2`, and `rs2` are consistent across formats, allowing clearer consistency of which registers to **read** and which to **write**.

RISC-V also tries to keep bit positions of immediates consistent. The "**swirling**" of immediate bits in @fig-ISB-type-comparison actually simplifies hardware design!


:::{figure} images/ISB-type-comparison.png
:label: fig-ISB-type-comparison
:width: 100%
:alt: "TODO"

I-Type, S-Type, and B-Type instruction format comparison.
:::

Observations:

* Across I-Type, S-Type, B-Type, the instruction bit `inst[31]` is always the `imm`’s sign bit.
* The 13-bit immediate of B-type has an `imm[0] = 0`, so B-Type tries to keep `imm[10:5]`, `imm[4:1]` in the same places as in the I-Type and S-Type, e.g., instruction bits `inst[26:30]` and `inst[8:11]`.
* S-Type, B-Type instruction formats have **just two bits that change meaning**:
  * The instruction bit `inst[31]` is immediate bit `imm[11]` in S-Type and `imm[12]` in B-Type.
  * The instruction bit `inst[7]` is immediate bit `imm[0]` in S-Type and `imm[11]` in B-Type.

<!--

:::{tip} Quick Check

RV32I: For 32-bit instructions, imm[1] = imm[0] = 0.

:::

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

:::{figure} images/practice-beq.png
:label: fig-practice-beq
:width: 100%
:alt: "TODO"

Branch operation instruction example.
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


|   |   |   | funct3 |   | opcode |   |
| :-- | -- | -- | -- | -- | -- | --: |
| `imm[12\|10:5]` | `rs2` | `rs1` | `000` | `imm[4:1\|11]` | `1100011` | `beq` |
| `imm[12\|10:5]` | `rs2` | `rs1` | `001` | `imm[4:1\|11]` | `1100011` | `bne` |
| `imm[12\|10:5]` | `rs2` | `rs1` | `100` | `imm[4:1\|11]` | `1100011` | `blt` |
| `imm[12\|10:5]` | `rs2` | `rs1` | `110` | `imm[4:1\|11]` | `1100011` | `bltu` |
| `imm[12\|10:5]` | `rs2` | `rs1` | `101` | `imm[4:1\|11]` | `1100011` | `bge` |
| `imm[12\|10:5]` | `rs2` | `rs1` | `111` | `imm[4:1\|11]` | `1100011` | `bgeu` |

-->