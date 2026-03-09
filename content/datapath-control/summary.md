---
title: "Summary"
---

## And in Conclusion$\dots$

## Textbook Readings

P&H 4.4, 4.5

## Additional References

Our single-cycle datapath is a synchronous digital system (SDS) that has the capabilities of
executing RISC-V instructions. It is divided into multiple stages of execution, where each stage is
responsible for a completing a certain task.

**IF** Instruction Fetch:
• Send address to the instruction memory (IMEM), and read IMEM at that address.
• Hardware units: PC register, +4 adder, PCSel mux, IMEM
**ID** Instruction Decode:
• Generate control signals from the instruction bits, generate the immediate, and read registers
from the RegFile.
• Hardware units: RegFile, ImmGen
**EX** Execute:
• Perform ALU operations, and do branch comparison.
• Hardware units: ASel mux, BSel mux, branch comparator, ALU
**MEM** Memory
• Read from or write to the data memory (DMEM).
• Hardware units: DMEM
**WB** Writeback
• Write back either PC + 4, the result of the ALU operation, or data from memory to the
RegFile.
• Hardware units: WBSel mux, RegFile

## Exercises
Check your knowledge!

### Conceptual Review

1. Question

:::{note} Solution
:class: dropdown

Solution

See: 

### Short Exercises

1. **True/False**: The single cycle datapath uses the outputs of all hardware units for each instruction.

:::{note} Solution
:class: dropdown
**False** All units are active in each cycle, but their output may be ignored (gated) by control signals
::: 

2. **True/False**: It is possible to execute the stages of the single cycle datapath in parallel to speed up execution of a single instruction.

:::{note} Solution
:class: dropdown
**False** Each stage depends on the value produced by the stage before it (e.g., instruction decode depends on the instruction fetched).
:::

3. **True/False**: Stores and loads are the only instructions that require input/output from DMEM.

:::{note} Solution
:class: dropdown
**True** For all other instructions, we don’t need to read the data that is read out from DMEM, and thus don’t need to wait for the output of the MEM stage.
:::

