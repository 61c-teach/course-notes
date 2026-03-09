---
title: "Summary"
---

## And in Conclusion$\dots$



## Textbook Readings

P&H 4.1, 4.3

## Additional References

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
