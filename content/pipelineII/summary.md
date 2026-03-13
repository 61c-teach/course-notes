---
title: "Summary"
---

## And in Conclusion$\dots$

**Hazards**
One of the costs of pipelining is that it introduces pipeline hazards. Hazards, generally, are issues
with something in the CPU’s instruction pipeline that could cause the next instruction to execute
incorrectly.

The 5-stage pipelined CPU introduces three types: structural hazards (insufficient hardware),
data hazards (using outdated values in computation), and control hazards (executing the wrong
instructions).

**Structural hazards** occur when more than one instruction needs to use the same datapath resource
at the same time. In the standard 5-stage RISC-V pipeline, there aren’t structural hazards,
unless changes are made to the pipeline. The structural hazards that could exist are prevented by
RV32I’s hardware requirements.

There are two main causes of structural hazards:
**• Register File:** The register file is accessed both during ID, when it is read to decode the
instruction and fetch the corresponding register values; and during WB, when it is written to
in the rd register.
    ‣ We resolve this by having separate read and write ports. However, this only works if the read/
written registers are different.

**• Main Memory:** Main memory is accessed for both instructions and data. If memory could only
support one read/write at a time, then instruction A (in the IF stage) attempting to fetch from
memory would conflict with instruction B attempting to read or write to the data portion of
memory.
    ‣ Having separate instruction memory (IMEM) and data memory (DMEM) solves this hazard.
Something to remember about structural hazards is that they can always be resolved by adding
more hardware.

**Data hazards** are caused by data dependencies between instructions. In CS 61C, where we always
assume that instructions go through the processor in order, data hazards occur when an instruction reads a register before a previous instruction has finished writing to the same register.
Data hazards occur between different stages. Some examples are:
**• EX-ID:** This hazard exists because the output from the execute stage is not written back to the
RegFile until the writeback stage, yet it can be requested by the subsequent instruction during
the decode stage.
**• MEM-ID:** This hazard exists because the output from the memory access stage is not written
back to the RegFile until the writeback stage, but it can still be requested from the decode stage
—just like in EX-ID.
To account for reads and writes to the same register, processors usually write to the register
during the first half of the clock cycle and read from it during the second half. This is an implementation of the idea of double pumping, where data is transferred along buses at double the rate by using both the rising and falling clock edges within a single clock cycle. With double pumping, we can reduce the number of stalls needed for data hazards by one.

**Detecting Data Hazards**
Say we have the `rs1`, `rs2`, `RegWEn`, and `rd` signals for two instructions (instruction *n* and instruction *n* + 1) and we wish to determine if a data hazard exists across the instructions. We can simply check to see if the `rd` for instruction *n* matches either `rs1` or `rs2` of instruction *n* + 1, indicating that such a hazard exists. We could then use our hazard detection to determine which forwarding paths/number of stalls (if any) are necessary to take to ensure proper instruction execution.

In pseudo-code, part of this could look something like the following:

```pseudo-code
if (rs1(n + 1) == rd(n) && RegWen(n) == 1) {
    set ASel for (n + 1) to forward ALU output from n
}
if (rs2(n + 1) == rd(n) && RegWen(n) == 1) {
    set BSel for (n + 1) to forward ALU output from n
}

## Textbook Readings

P&H 4.8, 4.10

## Additional References

 ## Exercises
Check your knowledge!

### Conceptual Review

1. Question

:::{note} Solution
:class: dropdown

Solution

See: [Lecture 2 Slide 13](https://docs.google.com/presentation/d/1dmCk2fZz-P8VedzAXnVmJiYPKszVka5NKmTuLJ6hqZc/edit?slide=id.g2af3b38b3e2_1_154#slide=id.g2af3b38b3e2_1_154)
:::

### Short Exercises

1. **True/False**: Having two ‘read’ ports as well as a ‘write’ port to the Register File solves the hazard of two
instructions that read and write to the same register simultaneously.

:::{note} Solution
:class: dropdown
**False.** The addition of independent ports to the RegFile allows for multiple instructions to
access the RegFile at the same time (such as one instruction reading values of two operands,
while another instruction is writing to a return register). However, this does not work if two
instructions are reading and writing to the same register at the same time. Some solutions to this
data hazard could be to stall the latter instruction or to forward the read value from a previous
instruction, bypassing the RegFile completely.
::: 

2. **True/False**: Without forwarding or double-pumping, data hazards will usually result in 3 stalls.

:::{note} Solution
:class: dropdown
**True.** The next instruction must wait for the previous instruction to finish EX, MEM, and WB,
before it can begin its EX
::: 

3. **True/False**: All data hazards can be resolved with forwarding.

:::{note} Solution
:class: dropdown
**False.** Hazards following lw cannot be fully resolved with forwarding because the output is not
known until after the MEM stage. We still need a stall in addition to forwarding from the MEM/
WB pipeline register to the EX stage.
::: 