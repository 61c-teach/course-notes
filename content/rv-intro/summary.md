---
title: "Summary"
---

## And in Conclusion$\dots$

### RISC-V Instructions

RISC-V is an assembly language composed of simple instructions that each perform a single task such as addition of two numbers or storing data to memory. Below is a comparison between RISCV code and its equivalent C code:

```
//x in s0, &y in s1

addi s0, x0, 5  // int x = 5;
sw s0, 0(s1)    // y[0] = x;
mul t0, s0, s0
sw t0, 4(s1)    // y[1] = x * x;
```

For your reference the tables below show some of the basic arithmetic/bitwise instructions which can also be found on the [61C reference card](https://cs61c.org/sp26/pdfs/resources/reference-card.pdf).

The below are abbreviations that will be used in the table:
* `rs1`: Argument register 1
* `rs2`: Argument register 2
* `rd`: Destination register
* `imm`: Immediate value (integer literal constant)
* `R[register]`: Value contained in register
* `inst`: One of the instructions in the table

:::{figure} #tab-add-sub
Basic Arithmetic Instructions (reprint of @tab-add-sub from [this section](#sec-rv-arithmetic)).
:::

:::{figure} #tab-rv-bitwise
Basic Bitwise Instructions (reprint of @tab-rv-bitwise from [this section](#sec-rv-bitwise)).
:::

A RISC-V "immediate" is any numeric constant. For example, `addi t0, t0, 20, sw a4, -8(sp)`, and `lw a1, 0x44(t2)` have immediates `20`, `-8`, and `0x44` respectively. Note that there is a limit to the size (number of bits) of an immediate in any given instruction (depends on what type of instruction, more on this soon!). You may also see that there is an “i” at the end of certain instructions, such as `addi`, `slli`, etc. This means that `rs2` becomes an “immediate” or an integer instead of a register. There are immediates in instructions which use an offset such as `sw` and `lw`. When coding in RISC-V, always use the [61C reference card](https://cs61c.org/sp26/pdfs/resources/reference-card.pdf) for the details of each instruction (the reference card is your friend)!

## Textbook Readings

P&H 2.1-2.3

## Additional References

See the RISC-V manual links on our [RISC-V green card page](#sec-green-card).