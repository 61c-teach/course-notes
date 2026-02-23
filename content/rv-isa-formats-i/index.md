---
title: "Machine Language"
---

(sec-machine-instructions)=
## Learning Outcomes

* Know that machine instructions follow instruction formats.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/DsDnNqL4gCo
:width: 100%
:title: "[CS61C FA20] Lecture 11.1 - RISC-V Instruction Formats I: Intro"
:::

::::

Recall from [earlier](#sec-isa-note) that an ISA specifies [assembly instructions](#sec-assembly-language), machine instructions, and fundamental architecture features like [registers](#sec-rv32i-registers), [memory access](#sec-load-store), and [instruction execution](#sec-rv-pc).

To fully utilize the ISA, we must write [machine instructions](#sec-machine-language), which are the bit representations of assembly instructions.

:::{warning} Program binaries are ISA-dependent

Programs are distributed in binary form, i.e., as assembled machine code. Programs are each bound to a specific instruction set, and there are different instruction sets for different architectures (e.g., phone vs. PC). A RISC-V program executable will not run on an Intel machine![^backwards-compatible]

[^backwards-compatible]: That being said, many instruction sets are backwards-compatible and evolve over time. e.g., latest PCs with x86 ISA today can still run programs from Intel 8088 (1981)!

:::

## Instruction Formats

Recall from our discussion of [instruction execution](#sec-rv-pc) and the program counter that all RV32I instructions are [word sized](#sec-rv32i-pc-4).[^instruction-word] Simplification works for RISC-V: Instructions are same size as a data word (32 bits) so that they can leverage the same hardware for memory access.

How do we go about translating `add x1 x2 x3` to the 32-bit word `00000000101010011000100100110011`?

[^instruction-word]: We cover RV32I (32-bit integer instructions). The same 32-bit instructions are used for RV32, RV64, RV128.

RISC-V defines six basic **instruction formats**, where similar instructions use the same format. Each instruction format divides an instruction word into **fields**; each field tells the processor something about the instructor.

We hope you treat these two chapters like a puzzle hunt, where you learn how to decipher the rightmost columns of the [RISC-V green card](#sec-green-card) and the [Instruction Types](#tab-rv32i-types) table.

* This chapter: R-Type, I-Type, S-Type
* Next chapter: B-Type, U-Type, J-Type
