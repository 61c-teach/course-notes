---
title: "Summary"
---

## And in Conclusion$\dots$

In order to pipeline, we separate the datapath into 5 discrete stages, each completing a different
function and accessing different resources on the way to executing an entire instruction.
Recall the five stages:

* In the IF stage, we use the Program Counter to access our instruction as it
is stored in IMEM.
* Then, we separate the distinct parts we need from the instruction bits in the ID
stage and generate our immediate, the register values from the RegFile, and other control signals.
* Afterwards, using these values and signals, we complete the necessary ALU operations in the EX
stage.
* Next, anything we do in regards with DMEM (not to be confused with RegFile or IMEM) is done in the MEM stage,
* Finally, we hit the WB stage, where we write the computed value that we want back into the return register in the RegFile.

These 5 stages, divided by registers, allow operating different stages of the datapath in the same
clock period.

* Different instructions can use different stages at the same time. At each clock cycle,
the necessary inputs into a particular stage are sampled at the rising clock edge (and available
after the clk-to-q delay).
* After the stage operates on the inputs, the corresponding outputs are
fed into **pipeline registers** for the next stage.  Pipeline registers may also be required to pass
information that may not be necessary for the next immediate stage, but some future stage.

:::{embed} #fig-five-stage-summary
:::

The RISC-V ISA is designed for pipelining:

* All instructions are 32 bits wide.
    * Easy to fetch (`IF`) and decode (`ID`), each in one clock cycle.
    * Contrast with CISC (Complex) x86: 1- to 15-byte-wide instructions!
* A small set of standard instruction formats.
    * Can decode/read registers in one stage (2nd, `ID`).
* Load/store addressing conceptually:
    * Calculate address in 3rd stage (`EX`) with ALU; and 
* Access memory in one stage (4th, `MEM`).
    * Memory operands are all aligned
    * Memory access takes only one cycle.

## Textbook Readings

P&H 4.6, 4.7, 4.8

## Additional References

## Exercises
Check your knowledge!

### Short Exercises

:::{exercise}
:label: pl-01
1. **True/False**: By pipelining the CPU datapath, each single instruction will execute faster because pipelining reduces the latency per instruction (resulting in a speed-up in performance).
:::

:::{solution} pl-01
:label: pl-01-sol
:class: dropdown
**False.** Because we insert registers between each stage in the datapath, the time it takes for an instruction to finish execution through the 5 stages will be longer than the single-cycle datapath. A single instruction will take multiple clock cycles to get through all the stages, with the clock cycle based on the critical path (the stage with the longest timing).
::: 

:::{exercise}
:label: pl-02
2. **True/False**: A pipelined CPU datapath results in instructions being executed with higher throughput compared to the single-cycle CPU.
:::

:::{solution} pl-02
:label: pl-02-sol
:class: dropdown
**True.** Recall that throughput is the number of instructions processed per unit time. Pipelining results in a higher throughput because multiple instructions can be in a different stage of the datapath at the same time.
::: 
