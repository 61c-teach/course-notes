---
title: "Summary"
---

## And in Conclusion$\dots$

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/1WTP44UAtp4
:width: 100%
:title: "[CS61C FA20] Lecture 19.7 - Single-Cycle CPU Datapath II: Summary"
:::

::::


Our **single-cycle datapath** is a synchronous digital system that has the capabilities of
executing RISC-V instructions in **one cycle each**. It is divided into multiple stages of execution, where each stage is responsible for a completing a certain task.

1. **IF** Instruction Fetch:
    * Send address to the instruction memory (IMEM), and read IMEM at that address.
    * Hardware units: PC register, +4 adder, PCSel mux, IMEM
1. **ID** Instruction Decode:
    * Generate control signals from the instruction bits, generate the immediate, and read registers from the RegFile.
    * Hardware units: RegFile, ImmGen
1. **EX** Execute:
    * Perform ALU operations, and do branch comparison.
    * Hardware units: ASel mux, BSel mux, branch comparator, ALU
1. **MEM** Memory
    * Read from or write to the data memory (DMEM).
    * Hardware units: DMEM
1. **WB** Writeback
    * Write back either PC + 4, the result of the ALU operation, or data from memory to the RegFile.
    * Hardware units: WBSel mux, RegFile

## Textbook Readings

P&H 4.1, 4.3, 4.4

### Short Exercises

1. **True/False**: If the logic delay of reading from IMEM is reduced, then any (non-empty) program using the
single cycle datapath will speed up

:::{note} Solution
:class: dropdown
**True** Since every instruction must read from IMEM during the instruction fetch stage, making
the IMEM faster will speed up every single instruction.
::: 

2. **True/False**: It is possible to feed both the immediate generator’s output and the value in rs2 to the ALU in a
single instruction.

:::{note} Solution
:class: dropdown
**False** You may only use either the immediate generator or the value in register rs2. Notice in
our datapath, there is a mux with a signal (BSel) that decides whether we use the output of the
immediate generator or the value in rs2.
:::