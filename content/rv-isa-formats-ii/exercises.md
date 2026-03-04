---
title: "Exercises"
subtitle: "Check your knowledge before section"
---

## Conceptual Review

1. **True or False**: In RISC-V, the opcode field of an instruction determines its type (R-Type,S-Type, etc.).

:::{note} Solution
:class: dropdown

**True.** The opcode field of an instruction uniquely identifies the instruction type and allows us to
identify the instruction format we’re working with. The opcode is located in the lowest 7 bits
of the machine instruction (bits 0-6).
:::

2. **True or False**: In RISC-V, the instruction li x5 0x44331416 will always be encoded in 32 bits when translated into binary.
:::{note} Solution
:class: dropdown

**False.** This is a bit of a trick question. It is true that every regular instruction in RISC-V will always be encoded in 32-bits. However, `li` is actually a pseudo-instruction! Recall that pseudo-instructionscan translate into one or more RISC-V instructions. In this case, li will be translated into an `addi` and `lui` instruction. Therefore, `li x5 0x44331416` will actually be encoded in 64-bits, as it represents two RISC-V instructions.
:::

3. **True or False**: We can use a branch instruction to move the PC by one byte.
:::{note} Solution
:class: dropdown

**False.** Branch instruction offsets have an implicit zero as the least significant bit, so we can only move the PC in offsets divisible by 2 (refer back to [this section](#sec-j-type) for an explanation why this is!). The full offset for a branch instruction will be the 13-bit offset `{imm[12:1], 0}`, where we take the immediate bits from our instruction’s binary encoding and add the implicit zero.
:::

## Short Exercises

1. Convert the following RISC-V registers into their binary representation:
* `s0`
* `sp`
* `x9`
* `t4`

:::{note} Solution
:class: dropdown
Note that since we have 32 different registers in RISC-V, we need 5 bits to encode them.
Looking at the 61C reference sheet, we can see that `s0` refers to the `x8` register. To get the final answer, we convert 8 into binary: `0b01000`. Following the same procedure as above, we get the rest of the answers...
* `s0`: `x9` = `0b01000`
* `sp`: `x2` = `0b00010`
* `x9`: `x9` = `0b01001`
* `t4`: `x29` = `0b11101`
:::
