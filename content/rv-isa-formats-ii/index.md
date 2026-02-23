---
title: "RISC-V Addressing Modes"
subtitle: "PC-Relative Addressing and Absolute Addressing"
---

## Learning Outcomes

* Contrast PC-Relative Addressing with Absolute Addressing.
* Given assembly code with labels, compute PC-relative offsets for conditional branches and unconditional jumps.

We recommend reviewing RISC-V control flow before continuing.

* [One section](#sec-rv-pc) describes how by default, the **Program Counter (PC)** is incremented by 4 bytes, corresponding to the next sequential instruction.
* [Another section](#sec-branches-jumps) describes unconditional jumps (e.g., `j Label`) and conditional branches (e.g., `beq rs1 rs2 Label`).


## Addressing Modes

There are different **addressing modes**–that is, ways of using operands and/or addresses encoded in the instruction.

We have seen one addressing mode already with [loads and stores](#sec-data-transfer). These instructions use base or displacement addressing, which computes addresses as a sum of a register in the register file (`x0-31`) and a immediate constant encoded in the instruction.

RISC-V uses two addressing modes to compute _instruction_ addresses to update the PC:

* **PC-relative addressing**, which computes addresses by summing PC with a signed constant offset, e.g., `PC = PC + offset`
* **Absolute addressing**, which computes addresses from a register, e.g., `PC = R[rs1] + imm`.

### PC-Relative Addressing

In almost all cases, instructions update the PC using **PC-relative addressing**.

* Arithmetic instructions, loads, and stores: `offset` is $+4$
* Branches
* J-Type instructions (see a [later section](#sec-j-type))
* (Effectively, all instructions except `jalr`)

Why? **Position-Independent Code**. If all an entire code block, these relative offsets won’t change!

#### From Labels to PC-Relative Offsets

Recall that in assembly, unconditional jumps and conditional branches uses labels, e.g., `j Label` and `beq rs1 rs2 Label`. [Labels](#sec-labels) are not instructions and **do not actually "exist"** in machine code.

Building machine instructions therefore requires translating labels into numeric constants that can be used for addressing. All branch and jump instructions that use labels use **PC-relative addressing**.

To translate branch and jump instructions to machine code, we must compute **PC-relative offsets**, which are numeric constants.

:::{note} Example

```{code} bash
:linenos:
Loop:
    beq  x19 x10 End
    add  x18 x18 x10
    addi x19 x19  -1
    j    Loop
End:
    # target instr
```

Consider the assembly code above. In each of the following cases, what is the PC-relative offset?

1. `beq x19 x10 End`, if branch is not taken
1. `beq x19 x10 End`, if branch is taken
1. `j Loop`
:::

**1.** `beq x19 x10 End`, **if branch is not taken.** In this case, PC updates to the next sequential instruction. The PC-relative offset is **$+4$**.

**2.** `beq x19 x10 End`, **if branch is taken**. In this case, PC updates to the instruction tagged with the `End` label. Consider @fig-offsets, which assigns toy addresses to each instruction in the above assembly. Here, the `pc` updates from `beq` (at address `0x0C`) to `End`'s instruction (at address `0x1C`). This difference is `0x10`, or **+16**. This corresponds to the fourth instruction _after_ `beq`.

:::{figure} images/offsets.png
:label: fig-offsets
:width: 80%
:align: center
:alt: "TODO"

Code illustrated example with jump operation.
:::

3. `j Loop`. In this case, PC updates to the instruction tagged with the `Loop` label (here, `beq`). Still considering @fig-offsets, the `pc` updates from `j` (at address `0x18`) to `Loop`'s instruction (at address `0x0C`). This difference is **$-12$**. This corresponds to three instructions _before_ `j`.

### Absolute Addressing

By contrast, **absolute addressing** supplies a new address to overwrite the PC. This addressing mode is **position-dependent** and is brittle to code movement (as we will see later). 

Only `jalr` (an [I-Type instruction](#sec-jalr-itype)) uses absolute addressing by setting `PC = R[rs1] + imm`. Doing so often involves building a 32-bit immediate, which is possible using the [U-Type](#sec-u-type) instruction format we discuss in this chapter.