---
title: "Summary"
---

## And in Conclusion$\dots$

## Textbook Readings

P&H 4.4, 4.5

## Additional References

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

