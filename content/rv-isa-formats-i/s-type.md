---
title: "S-Type"
---

(sec-s-type)=
## Learning Outcomes

* Translate between S-type assembly instructions and machine instructions.
* Reason about why store instructions, `sb`, `sh`, and `sw`, have their own instruction format.
* Reason about why the `imm` immediate field is split into two bitranges in S-Type format.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/JmxA8jF-LME
:width: 100%
:title: "[CS61C FA20] Lecture 11.5 - RISC-V Instruction Formats I: S-Format"
:::

::::

Our next instruction format is S-Type, the format used for **S**tore instructions `sb`, `sh`, and `sw`. While load instructions fit nicely into the [I-Type](sec-i-type) format, store instructions use registers differently than the instructions we've seen so far. We need a special instruction format to translate store instructions into machine code.

Recall from an [earlier section](#store-word):

> The **store word** instruction:
>
> * **Computes a memory address** `R[rs1]+imm`
> * **Store a word** from register `rs2`, `R[rs2][31:0]`, to this address in memory, `M[R[rs1] + imm][31:0]`.

[Stores](tab-rv32i-memory) therefore need the following fields:

* `rs1`: "base" register which stores the base memory address
* `rs2`: "source" register which stores the data to be stored in memory
* `imm`: 2's complement "offset" to add to the "base" register to form the memory address to use in store (store address = R\[base register\]) + (immediate offset)
* `opcode` (as all instructions do). Stores use opcode `0100011`.
* `funct3` specifies partial stores.

Store instructions have two operand registers, like in [R-type](sec-r-type) instructions, but do not have a destination regsiter `rd`. Instead, S-type instructions have an immediate value, like in [I-type](sec-i-type) instructions. Therefore, we use a new instruction format: S-type for "Store"-type.

## S-Type: Fields

The S-Type instruction format is the fourth row of the [Instruction format table](#tab-rv32i-types) of the [RISC-V green card](#sec-green-card).

The format for these `storeop rs2 imm(rs1)` instructions is shown in @fig-s-type:

:::{figure} images/s-type.png
:label: fig-s-type
:width: 100%
:alt: "TODO"

The S-Type Instruction Format.
:::

**Register operands**: Notice that the register fields `rs1` and `rs2` are in the same positions in S-Type and R-type; this intentional design reduces hardware complexity.

**Constant operand**: Similar to I-Type, the **immediate field** `imm` specifies a 12-bit-wide immediate value. However, in S-type, the immediate field is split into two different bit positions. The lower 5 bits of the immediate `imm[4:0]` are in bits `[11:7]` and the upper 7 bits `imm[31:25]` are in bits `[31:25]` in the machine code instruction.

The 12-bit immediate is still a two's complement integer with range $-2^{11} = -2048$ to $2^{11} - 1 = 2047$, like in I-type. The difference is that we now have to either split up the bits or put them together to recover the immediate, depending on if we are translating to machine code or to assembly code.

## Assembly Instruction $\rightarrow$ Machine Instruction

Consider the translation of `sw x14 36(x2)` to the machine instruction shown in @fig-practice-sw.

:::{figure} images/practice-sw.png
:label: fig-practice-sw
:width: 100%
:alt: "TODO"

The S-Type instruction `sw x14 36(x2)`.
:::

We follow the [steps for translating assembly into machine code](#sec-assembly-to-machine) from earlier:

1. **Determine operation field codes**.

    * `opcode`: `0100011` for all S-Type instructions
    * `funct3`: `010` for `sw`

1. **Translate registers and immediates.**

    * `rs1`: Register `x2`. Translate $2$ to 5-bit unsigned integer representation `0b00010`.
    * `rs2`: Register `x14`. Translate $14$ to 5-bit unsigned integer representation `0b01110`.
    * `imm`: $36$ as a 12-bit two's complement, split into 7 upper-bits and 5 lower-bits:
        * $+36$ is `0b0000 0010 0100`.
        * Split offset bits into upper and lower bit positions as shown in @fig-practice-sw-imm: upper-bits `imm[11:5] = 0b0000001`, lower-bits `imm[4:0] = 0b00100`

1. (if needed) Convert to hexadecimal.

    * We leave this as an exercise to you!

:::{figure} images/practice-sw-imm.png
:label: fig-practice-sw-imm
:width: 35%
:alt: "TODO"

Immediate (offset) value for the S-Type instruction `sw x14 36(x2)`.
:::

## S-Type vs. I-Type vs. R-Type

@fig-R-I-S-type-comparison compares the three instruction formats we have seen so far:

:::{figure} images/R-I-S-type-comparison.png
:label: fig-R-I-S-type-comparison
:width: 100%
:alt: "TODO"

S-Type instruction set comparison to I-type and R-Type instruction sets.
:::

Again, like in I-Type, S-Type instructions expand the `imm` field across the R-Type's `funct7` field. However, in contrast to I-Type, store instructions use a second source operand register `rs2` and need to use bits `[24:20]` to encode which register to use to access the data to be stored to memory.

However, if we only had the 7-bit field replacing `funct7`, then we'd only be able to represent 128 immediate values. Since S-Type instructions do not write to a destination register `rd`, we have another 5-bit field to use to represent a 12-bit `imm` field. The immediate in store instructions represents an offset to be added to a base address. These offset constants are frequently short and can fit into the 12-bit `imm` field.

:::{note} Why split up the immediate field in S-Type?

RISC-V ISA design prioritizes keeping **register** fields in the same place in the machine code so that these values are easy to find when processing the instruction. We keep the bit positions used for source registers `rs1` and `rs2` (registers we are reading from) and destination register `rd` (register we are writing to) constant.

The processor knows:

* If we are reading the value of a register, the source register `rs1` will be in bits `[19:15]`.
* If we have a second source register to read from, `rs2` will be in bits `[24:20]` in the instruction.
* If we are writing a value to a destination register, `rd` will be in bits `[11:7]`.

Immediate values are less critical and can be moved around in the machine code. Since S-Type instructions do not use the `rd` field, we can use these bits to extend the space we have to represent `imm`, but split into two bit positions `[31:25]` and `[11:7]`.

:::

The consistency between the three instruction type formats allows for simple hardware design!

## Reference for S-Type Instructions

This section is intended as a reference for S-Type instructions based on what you learned in this section.

Consider the S-Type instructions shown in @tab-s-type from the RISC-V green card.

:::{table} RV32I Instructions: S-Type
:label: tab-s-type
:align: center

| Instruction | imm[11:15] | rs2 | rs1 | funct3 | imm[4:0] | opcode |
| :-- | -- | -- | -- | -- | -- | --: |
| `sb` | `imm[11:5]` | `rs2` | `rs1` | `000` | `imm[4:0]` | `0100011` |
| `sh` | `imm[11:5]` | `rs2` | `rs1` | `001` | `imm[4:0]` | `0100011` |
| `sw` | `imm[11:5]` | `rs2` | `rs1` | `010` | `imm[4:0]` | `0100011` |
:::

Recall that store instructions write to memory with only specified bytes. We do not need sign/logical extension.

:::{note} `funct3` Field

Notice that the `funct3` field in S-Type instructions exactly matches those of the load instruction using I-Type format.

* Store/load **byte** (8-bits): `sb` and `lb` both have a `funct3` field of `000`.
* Store/load **half word** (16-bits): `sh` and `lh` both have a `funct3` field of `001`.
* Store/load **word** (32-bits): `sw` and `lw` both have a `funct3` field of `010`
:::


<!--

### TODO: put this somewhere

:::{warning} Why do we use 17 bits to specify the operation?

Remember there are only 10 R-Type, 17 I/I*-Type, and 3 S-Type instructions! Across the entire base RV32I instruction set, there are certainly fewer instructions than the $2^32$ possible representable things in a 32-bit word, so some redundancy is unavoidable.

More importantly, we will see that to simplify architecture design, different instruction formats **reuse the same bit positions for the same fields wherever possible**. The register fields `rs1`, `rs2`, and `rd` are therefore prioritized, and fields like `funct3` and `funct7` occupy the remaining bits.

:::

-->