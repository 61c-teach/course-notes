---
title: "Summary"
---

## And in Conclusion$\dots$



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