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


::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/qgGy_Ra9hr0
:width: 100%
:title: "[CS61C FA20] Lecture 20.5 - Single-Cycle CPU Control: Summary"
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

The **critical path** changes based on instruction. Not all instructions use all hardware units, and therefore not all instructions are active in all five phases of execution ("stages" is the terminology we use for pipelined processors).

The **controller** (e.g., control logic subcircuit) specifies how to execute instructions and it is implemented as ROM (read-only-memory) or as logic gates.

## Textbook Readings

P&H 4.1, 4.3, 4.4, 4.5

## Exercises

:::{exercise}
:label: dp-01
1. **True/False**: If the logic delay of reading from IMEM is reduced, then any (non-empty) program using the single cycle datapath will speed up.
:::

:::{solution} dp-01
:label: dp-01-sol
:class: dropdown
**True** Since every instruction must read from IMEM during the instruction fetch stage, making the IMEM faster will speed up every single instruction.
:::

:::{exercise}
:label: dp-02
2. **True/False**: It is possible to feed both the immediate generator’s output and the value in rs2 to the ALU in a single instruction.
:::

:::{solution} dp-02
:label: dp-02-sol
:class: dropdown
**False** You may only use either the immediate generator or the value in register rs2. Notice in our datapath, there is a mux with a signal (BSel) that decides whether we use the output of the immediate generator or the value in rs2.
:::

:::{exercise}
:label: dp-03
3. **True/False**: The single cycle datapath uses the outputs of all hardware units for each instruction.
:::

:::{solution} dp-03
:label: dp-03-sol
:class: dropdown
**False** All units are active in each cycle, but their output may be ignored (gated) by control signals.
::: 

:::{exercise}
:label: dp-04
4. **True/False**: It is possible to execute the stages of the single cycle datapath in parallel to speed up execution of a single instruction.
:::

:::{solution} dp-04
:label: dp-04-sol
:class: dropdown
**False** Each stage depends on the value produced by the stage before it (e.g., instruction decode depends on the instruction fetched).
:::

```{exercise}
:label: dp-05
5. **True/False**: Stores and loads are the only instructions that require input/output from DMEM.
```

:::{solution} dp-05
:label: dp-05-sol
:class: dropdown
**True** For all other instructions, we don’t need to read the data that is read out from DMEM, and thus don’t need to wait for the output of the MEM stage.
:::
