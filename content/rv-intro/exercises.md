---
title: "Exercises"
subtitle: "Check your knowledge before section"
---

## Conceptual Review

1. **True or False**: Types are associated with declaration in C (normally), but are associated with instructions (operators) in RISC-V.

:::{note} Show Answer
:class: dropdown

True. See @tab-hll-vs-assembly.

:::

1. **True or False**: Since there are only 32 registers, we can’t write RISC-V for C expressions that contain > 32 variables.

:::{note} Show Answer
:class: dropdown

False. We have seen [a few examples](#sec-arithmetic-examples) on how to break up longer equations to smaller ones already.
:::

1. **True or False**: If `p` (stored in `x9`) were a pointer to an array of `int`s, then `p++;` would be translated to `addi x9,x9, 1`.

:::{note} Solution
:class: dropdown

False. Don’t forget that `int`s are `4` bytes wide on RV32I, so instruction would be `addi x9, x9, 4`.
:::

## Short Exercises

1. **True/False**:

:::{note} Solution
:class: dropdown
**True.** Explanation
:::
