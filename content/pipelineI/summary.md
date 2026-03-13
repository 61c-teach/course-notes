---
title: "Summary"
---

## And in Conclusion$\dots$
**Pipelining**
In order to pipeline, we separate the datapath into 5 discrete stages, each completing a different
function and accessing different resources on the way to executing an entire instruction.
Recall the five stages: In the IF stage, we use the Program Counter to access our instruction as it
is stored in IMEM. Then, we separate the distinct parts we need from the instruction bits in the ID
stage and generate our immediate, the register values from the RegFile, and other control signals.
Afterwards, using these values and signals, we complete the necessary ALU operations in the EX
stage. Next, anything we do in regards with DMEM (not to be confused with RegFile or IMEM)
is done in the MEM stage, before we hit the WB stage, where we write the computed value that
we want back into the return register in the RegFile.

These 5 stages, divided by registers, allow operating different stages of the datapath in the same
clock period. Different instructions can use different stages at the same time. At each clock cycle,
the necessary inputs into a particular stage are sampled at the rising clock edge (and available
after the clk-to-q delay). After the stage operates on the inputs, the corresponding outputs are
fed into pipeline registers for the next stage. Note, pipeline registers may also be required to pass
information that may not be necessary for the next immediate stage, but some future stage.

**5 Stage Datapath Diagram Picture**


## Textbook Readings

P&H 4.6, 4.7, 4.8

## Additional References

<<<<<<< HEAD
### Short Exercises

1. **True/False**: By pipelining the CPU datapath, each single instruction will execute faster because pipelining
reduces the latency per instruction (resulting in a speed-up in performance).

:::{note} Solution
:class: dropdown
**False** Because we insert registers between each stage in the datapath, the time it takes for an
instruction to finish execution through the 5 stages will be longer than the single-cycle datapath.
A single instruction will take multiple clock cycles to get through all the stages, with the clock
cycle based on the critical path (the stage with the longest timing).
::: 

2. **True/False**: A pipelined CPU datapath results in instructions being executed with higher throughput compared to the single-cycle CPU.

:::{note} Solution
:class: dropdown
**True** Recall that throughput is the number of instructions processed per unit time. Pipelining
results in a higher throughput because multiple instructions can be in a different stage of the
datapath at the same time.
::: 

=======
<!-- ## Exercises
Check your knowledge!

### Conceptual Review

1. Question

:::{note} Solution
:class: dropdown

Solution

See: [Lecture 2 Slide 13](https://docs.google.com/presentation/d/1dmCk2fZz-P8VedzAXnVmJiYPKszVka5NKmTuLJ6hqZc/edit?slide=id.g2af3b38b3e2_1_154#slide=id.g2af3b38b3e2_1_154)
:::

### Short Exercises

1. **True/False**: 

:::{note} Solution
:class: dropdown
**True.** Explanation
::: -->
>>>>>>> ac3cdbeb69f24079e84007d800444dbbc095e6b7
