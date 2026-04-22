---
title: "Short Examples"
subtitle: TODO
---

## Learning Outcomes

* Practice loads and stores.
* Translate array accesses in C code into assembly instructions (see Long Example).

No video. We recommend pulling up the [memory section](#tab-rv32i-memory) of the [RISC-V Green Card](#sec-green-card).

## Example 1

Consider the assembly code:

(code-data-ex1)=
```
li x11 0x93F5 
sw x11 0(x5)
lb x12 1(x5)
```

Suppose that the memory layout starts as in @fig-rv-example-x12. After executing these instructions, what is in `x12`?

:::{figure} images/examplex12.png
:label: fig-rv-example-x12
:width: 100%
:alt: "TODO"

Starting memory layout for [Example 1](#code-data-ex1).
:::

_Hint_: See the section on [pseudoinstructions](#sec-pseudoinstructions) like `li`.

:::{note} Show Answer
:class: dropdown

`R[x12]` is `0xFFFF FF93`.

:::

::::{note} Explain `li x11 0x93F5`
:class: dropdown

Load Immediate (`li rd imm`) is `addi rd x0 0x93F5`. The pseudoinstruction therefore maps to `addi x11 x0 0x93F5`, so set `R[x11]` (the value of register `x11`) to the bits `0x000093F5`.

:::{figure} images/examplex12-sol1.png
:label: fig-rv-example-x12-sol1
:width: 100%
:alt: "TODO"

Solution (1/3) for [Example 1](#code-data-ex1).
:::

::::

::::{note} Explain `sw x11 0(x5)`
:class: dropdown

Compute memory address as base register + offset, or `R[x5] + 0` = `0x100 + 0` = `0x100`. Store `R[x11]` (the value of `x11`) to memory at address `0x100`. On this (assumed) little endian architecture, `0xF5` gets stored at the lowest byte `0x100`.

:::{figure} images/examplex12-sol2.png
:label: fig-rv-example-x12-sol2
:width: 100%
:alt: "TODO"

Solution (2/3) for [Example 1](#code-data-ex1).
:::

::::

::::{note} Explain `lb x12 1(x5)`
:class: dropdown

Compute memory address as base register + offset, or `R[x5] + 1` = `0x100 + 1` = `0x101`. Load byte `0x93` from memory at address `0x101` into the lowest byte of register `x11`.

`lb` means we must sign-extend. The top bit of 0x93 is 1, so fill top 24 bits with `1`s:

```
0x93 = 0b1001 0011
--> 0b1…1 1001 0011
--> 0xFFFF FF93
```

:::{figure} images/examplex12-sol3.png
:label: fig-rv-example-x12-sol3
:width: 100%
:alt: "TODO"

Solution (3/3) for [Example 1](#code-data-ex1).
:::

**Solution**: `R[x11]` (the value in `x11`) is `0xFFFFFF93`.
::::

### Example 2

Suppose that `x` and `y` are `int *` pointers whose values are in registers `x3` and `x5`.

How do we translate the statement `*x = *y;` into assembly?

Consider the following instructions:

1. add x3 x5 zero
2. add x5 x3 zero
3. lw x3 0(x5)
4. lw x5 0(x3)
5. lw x8 0(x5)
6. sw x8 0(x3)
7. lw x5 0(x8)
8. sw x3 0(x8)

And consider the following choices:

* A. 1
* B. 2
* C. 3
* D. 4
* E. 5 → 6
* F. 6 -> 5
* G. 7 → 8
* H. Something else

:::{note} Answer (nothing here)

We leave the solution to you, for now!
:::