---
title: "Summary"
---

## And in Conclusion$\dots$

Our single-cycle datapath is a synchronous digital system (SDS) that has the capabilities of
executing RISC-V instructions. It is divided into multiple stages of execution, where each stage is
responsible for a completing a certain task.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/qgGy_Ra9hr0
:width: 100%
:title: "[CS61C FA20] Lecture 20.5 - Single-Cycle CPU Control: Summary"
:::

::::

The **critical path** changed based on instruction. Not all instructions use all hardware units, and therefore not all instructions are active in all five phases of execution ("stages" is the terminology we use for pipelined processors).

The **controller** pecifies how to execute instructions and it is implemented as ROM (read-only-memory) or as logic gates.

## Textbook Readings

P&H 4.4, 4.5

## Exercises

Check your knowledge!

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

