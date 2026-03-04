---
title: "Summary"
---

## And in Conclusion$\dots$

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/Ntp8UOhJleU
:width: 100%
:title: "[CS61C FA20] Lecture 12.4 - RISC-V Instruction Formats II: Summary"
:::

::::

### Instruction Translation

Recall that every instruction in RISC-V can be represented as a 32-bit binary value, which encodes
the type of instruction, as well as any registers/immediates included in the instruction. To convert
a RISC-V instruction to binary, and vice-versa, you can use the steps below. The 61C reference
sheet will be very useful for conversions!

**RISC-V ⇒ Binary**
1. Identify the instruction type (R, I, I*, S, B, U, or J)
2. Find the corresponding instruction format
3. Convert the registers and immediate value, if applicable, into binary
4. Arrange the binary bits according to the instruction format, including the opcode bits (and possibly funct3/funct7 bits)

**Binary ⇒ RISC-V**
1. Identify the instruction using the opcode (and possibly funct3/funct7) bits
2. Divide the binary representation into sections based on the instruction format
3. Translate the registers + immediate value
4. Put the final instruction together based on instruction type/format

Below is an example of a series of RISC-V instructions with their corresponding binary translations.

| `example.S` | `example.bin` |
| :--- | :--- |
| `main:`<br/>`addi sp,sp,-4`<br/>`sw ra,0(sp)`<br/>`addi s0,sp,4`<br/>`mv a0,a5`<br/>`call printf`<br/>`...` | `...`<br>`11111111110000010000000100010011`<br>`00000000000100010010000000100011`<br>`00000000010000010000010000010011`<br>`00000000000000000000010100010011`<br/>`00000000010001000000000011101111`<br/>`...` |

## Textbook Readings

P&H 2.5, 2.10

## Additional References

