---
title: "Summary"
---

## And in Conclusion$\dots$

One of the costs of pipelining is that it introduces pipeline hazards. **Hazards**, generally, are issues with something in the CPU’s instruction pipeline that could cause the next instruction to execute
incorrectly.

We discuss three types of hazards:

* Structural hazards (insufficient hardware)
* Data hazards (using outdated values in computation)
* Control hazards (executing the wrong
instructions).

## Textbook Readings

P&H 4.8, 4.10

## Additional References

## Exercises

### Short Exercises

1. **True/False**: Having two ‘read’ ports as well as a ‘write’ port to the Register File solves the hazard of two instructions that read and write to the same register simultaneously.

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

1. **True/False**: Stalling is the only way to resolve control hazards

:::{note} Solution
:class: dropdown
**False.** There are other more advanced techniques such as branch prediction, which predicts which
path the branch will take and flushes the pipeline if the prediction is wrong.
::: 