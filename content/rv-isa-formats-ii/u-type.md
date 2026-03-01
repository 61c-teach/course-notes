---
title: "U-Type"
subtitle: "lui and auipc"
---

(sec-u-type)=
## Learning Outcomes

* Explain why U-Type is needed for building wide immediates.
* Translate the pseudoinstruction `li` (Load Immediate) into machine code.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/e6WlS-QsNZc
:width: 100%
:title: "[CS61C FA20] Lecture 12.2 - RISC-V Instruction Formats II: Upper Immediates"
:::

::::

Recall that [I-Type](#sec-i-type) arithmetic instructions encode an sign extension 12-bit immediate as a two's complement integer, which is then sign-extended to a 32-bit value. While constants are frequently short and fit into the 12-bit I-Type fields, we inevitably need to encode **wide immediates** to build numberic constants larger than the I-type's 12-bit `imm`.

RISC-V achieves wide immediates as follows:

* Specify 32-bit constants using **two instructions**: an I-Type arithmetic instruction for the 12-bit **lower immediate**, i.e., bits 0 to 11; and and a different instruction for the 20-bit **upper immediate**, i.e., bits 12 to 31. (Again, **reduced** instruction set!)
* Define an instruction format, **U-Type** (the "U" is for Upper immediate), that can be used for instructions that specify upper immediates.

There are two U-Type instructions: `lui` and `auipc`. These are located in the "Other" section of the [RISC-V green card](#tab-rv32i-other).

## Load Upper Immediate (`lui`)

From the P&H textbook (Chapter 2.10), one such instruction, `lui`, is **L**oad **U**pper **I**mmediate:

> ...load a 20-bit constant into bits 12 through 31 of a register. The rightmost 12 bits are filled with zeros.

In @tab-lui, we call this upper immediate `immu` and the 32-bit immediate `imm`.

:::{table} The `lui` instruction.
:label: tab-lui
:align: center

| Instruction | Name | Description |
| :--- | :--- | :--- |
| `lui rd immu` | Load Upper Immediate | `imm = immu << 12`<br/>`R[rd] = imm` |
:::

As shown in @fig-u-type-immu, `imm = immu << 12`; this 32-bit numeric constant `imm` is then written to register `rd`.

:::{figure} images/u-type-immu.png
:label: fig-u-type-immu
:width: 50%
:alt: "TODO"

For U-Type instructions, `immu` is the top 20 bits of a 32-bit-wide numeric constant `imm` `imm`.
:::

(sec-li-lui)=
### Load Immediate Pseudoinstruction

With this new instruction, we can now return to translating the `li` pseudoinstruction, Load Immediate. When we [introduced](#sec-pseudoinstructions) load immediate, you may have noticed a footnote in @tab-mv-li:

> This description is incomplete given the range of `imm` in `addi`. See the [green-card](@tab-rv32i-pseudoinstructions) and a [later section](#sec-li-lui) for the full translation of load immediates.

In other words, when `li` must use a numeric constant wider than the 12 bits accommodated by the I-Type `addi`'s `imm` field it translates to **two** instructions: `lui` and `addi`.

| Pseudoinstruction | Name | Description | Translation |
| :--- | :--- | :--- | :--- |
| `li rd imm` | Load Immediate | `R[rd] = imm` | `lui` (if needed), `addi` |

In other words, `li` translates to `addi` when the immediate is between -2048 and 2047. For anything larger, `li` translates to **two** instructions: `lui` and `addi`.

In general, the compiler or assembler will break large constants across the `lui` and `addi` instructions, as needed. After all, there are some important **caveats** to this process. Hover over the two footnotes below before continuing.

* `lui` to set the upper 20 bits[^lui-caveat]
* `addi` to "set" the lower 12 bits[^addi-caveat]

[^lui-caveat]: And zero out lower 12 bits
[^addi-caveat]: "Set" as in, add a **sign-extended** 12-bit immediate

:::{warning} Translating `li` to real instructions

`addi` extends the sign of its 12-bit immediate. See Example 2 below. Be careful!
:::

:::{tip} Example 1
Translate `li x10 0x87654321` to real instructions.

Solution:

```bash
lui  x10 0x87654
addi x10 x10 0x321
```

:::

:::{note} Show Explanation
:class: dropdown

1. `lui` sets `x10` to `0x87654000`. Note `0x87654` is 20 bits.
2. `addi` sets `x10` to `0x87654321 = 0x87654000 + 0x00000321`, where the latter operand is the sign-extended version of the 12-bit immediate `0x321`.

:::

:::{tip} Example 2: Edge Case
Translate `li x10 0xB0BACAFE` to real instructions.

Does not work:

```bash
lui  x10 0xB0BAC
addi x10 x10 0xAFE
```

Solution:

```bash
lui  x10 0xB0BAD
addi x10 x10 0xAFE
```
:::

::::{note} Show Explanation
:class: dropdown

Let's first consider the strawman[^strawman], which **does not work**:

[^strawman]: Wikipedia: [Straw Man](https://en.wikipedia.org/wiki/Straw_man)

```bash
lui  x10 0xB0BAC
addi x10 x10 0xAFE
```

Remember, the `addi` instruction **sign-extends** the 12-bit immediate `imm`. If the sign bit of `imm` is set, then `imm` is negative, **subtracting 1** from the upper 20 bits set by the previous `lui` instruction.

1. `lui` sets `x10` to `0xB0BAC000`.
2. `addi` sets `x10` to `0xB0BAC000 + 0xFFFFAFE`, because the 12-bit immediate `0xAFE` is a two's complement negative number. `x10` is then set to `0xB0BABAFE`.

@fig-li-lui-strawman "cutely"[^pain] illustrates this "subtraction by one" using hexadecimal arithmetic and algebraic properties.

[^pain]: For some definition of "cute"; here, "cool math"

:::{figure} images/li-lui-strawman.png
:label: fig-li-lui-strawman
:width: 40%
:alt: "TODO"

When `addi`'s immediate `imm` is signed, a naive `lui` immediate `immu` will yield an incorrect numeric constant.
:::

To solve this, know that `addi` will always follow `lui` when resolving a `li` pseudoinstruction, and `addi` will always sign-extend its immediate `imm`. So if `addi`'s 12-bit `imm` field is negative, **proactively add 1** to `lui`'s 20-bit `immu` field:

```bash
lui  x10 0xB0BAD
addi x10 x10 0xAFE
```

1. `lui` sets `x10` to `0xB0BAD000`.
2. `addi` sets `x10` to `0xB0BAD000 + 0xFFFFAFE`, because the 12-bit immediate `0xAFE` is a two's complement negative number. `x10` is then set to `0xB0BACAFE`.

::::

## Add Upper Immediate to PC

Coming soon. Used for [J-Type instructions](#sec-j-type).

:::{table} The `auipc` instruction.
:label: tab-auipc
:align: center

| Instruction | Name | Description |
| :--- | :--- | :--- |
| `auipc rd immu` | Add Upper Imm to PC | `imm = immu << 12`<br/>`R[rd] = PC + imm` |
:::

## U-Type: Fields

In order to translate `lui` and `auipc` to machine code, we need an instruction format that supports 20-bit immediates.
The U-Type instruction format is only used by `lui` and `auipc` and is the one of the last rows of the [instruction format table](#tab-rv32i-types) of the [RISC-V green card](#sec-green-card).

:::{figure} images/u-type.png
:label: fig-u-type
:width: 100%
:alt: "TODO"

The U-Type Instruction Format.
:::

U-Type has only three fields (@fig-u-type):

* **Register operand**: The U-Type field `rd` is the destination register to put the immediate.

* **Opcode**: The U-Type field `opcode` specifies the operation: `auipc` or `lui` (@tab-u-type).

* **Constant operand**: The **upper immediate field** (we'll call it `immu`) specifies a 20-bit immediate value. `immu` is **left-shifted** by 12 to form the upper 20 bits of a 32-bit numeric constant `imm` (@fig-u-type-immu).

:::{table} RV32I Instructions: U-Type
:label: tab-u-type
:align: center

| Instruction | imm[31:12] ("immu") | rd | opcode |
| :-- | :-- | :-- | :-- |
| `auipc` | `imm[31:12]` | `rd` | `0010111` |
| `lui` | `imm[31:12]` | `rd` | `0110111` |
:::