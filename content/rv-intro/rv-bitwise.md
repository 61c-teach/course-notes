---
title: "RISC-V Arithmetic Instructions II: Bitwise Operations"
short_title: "Bitwise Operations"
---

(sec-rv-bitwise)=
## Learning Outcomes

* Write assembly to perform bitwise operations.
* Understand why there are only three RISC-V bitshift operations: `sll`, `srl`, and `sra` (and their immediate equivalents `slli`, `srli`, `srai`).

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/WQQlcC3btmM
:width: 100%
:title: "[CS61C FA20] Lecture 09.1 - RISC-V Decisions II: Logical Instructions"
:::

::::

We recommend reviewing the [C Bitwise Operations](#sec-c-bitwise-ops) before continuing.

We have [previously discussed](#sec-hll-vs-assembly) that in RISC-V, operations determine “type,” i.e., how register contents are treated (see [this table](#tab-hll-vs-assembly)). Next, we will see how this concept applies to RISC-V's instruction set for bitwise operations.

## Bitwise Operations

As [before](#sec-bitwise-ops-defined), **bitwise operations** are performed on n-bit operands **one bit at a time**.

The RV32I ISA provides instructions for common bitwise operations.[^green-card]. @tab-bitwise shows that most bitwise operations correspond to two instructions:

* **RISC-V: Register**. Perform the bitwise operation on two register operands `rs1` and `rs2`, and store the result in a destination register `rd`.
* **RISC-V: Immediate**. Perform the bitwise operation on one register operand `rs1` and an immediate `imm`, and store the result in a destination register `rd`.

[^green-card]: See the full set of arithmetic instructions on the [RISC-V green card](#sec-green-card).

In @tab-rv-bitwise below, hover over each footnote to jump to the corresponding section on this page.

:::{table} RISC-V bitwise arithmetic instructions.
:label: tab-rv-bitwise
:align: center

| Bitwise Operation | RISC-V: Register | RISC-V: Immediate |
| :--- | :--- | :--- |
| **AND** | `and rd rs1 rs2` | `andi rd rs1 imm` |
| **OR** | `or rd rs1 rs2` | `ori rd rs1 imm` |
| **XOR** | `xor rd rs1 rs2` | `xori rd rs1 imm` |
| **NOT**[^not] | `not rd rs1` (pseudo) | |
| **Shift left**[^sll] | `sll rd rs1 rs2` | `slli rd rs1 imm` |
| **Shift right**[^srl-sra] | `srl rd rs1 rs2` <br> `sra rd rs1 rs2` | `srli rd rs1 imm` <br> `srai rd rs1 imm` |

[^not]: See the [`not` pseudoinstruction](#sec-rv32i-not).

[^sll]: See [shift left](#sec-rv32i-sll).

[^srl-sra]: See [shift right](#sec-rv32i-srl-sra).

:::

(sec-rv32i-not)=
### The `not` pseudoinstruction

In RISC-V, bitwise NOT is a [pseudoinstruction](#sec-pseudoinstructions) and corresponds to a bitwise XOR with the immediate `-1`:

:::{table} NOT is XOR with -1.
:align: center

| Pseudoinstruction | Name | Description | Translation |
| :--- | :--- | :--- | :--- |
| `not rd rs1` | bitwise NOT | `R[rd] = ~(R[rs1])` | `xori rd rs1 -1` |
:::

Notes:

* A bitwise NOT of the value `R[rs1]` is defined as a bitwise inversion of all 32 bits of register `rs1`.
* Recall from our discussion of [XOR properties](#tab-bitwise-props) that for a single bit `x`, the expression `x XOR 1` (`x ^ 1`) **inverts** `x`.
* The immediate `-1` has 32-bit two's complement signed integer representation `0b 1111 1111 1111 1111 1111 1111 1111 1111`.

These three notes together explain @fig-rv32i-not below.

:::{figure} images/rv32i-not.png
:label: fig-rv32i-not
:width: 50%
:alt: "TODO"

Add immediate instruction in RISC-V and C with negative values.
::::

:::{note} Show explanation
:class: dropdown

* The source register `rs1` has value `0b 1111 1111 1111 1111 1111 1111 1111 0111`.
* Destination register `rd` has value `0b 0000 0000 0000 0000 0000 0000 0000 1000`.
* By definition, this operation is both NOT (a bitwise inversion) and XOR with the 32-bit two's complement representation of `-1`.

:::

:::{warning} Why no `noti` instruction?

Hypothetically, a `noti` instruction would invert the bits of an immediate and store it into a register. This is equivalent to specifying the inverted immediate to begin with, so RISC-V does not "spend" an instruction on this operation.

:::

(sec-rv32i-sll)=
### Shift left

Like all RISC-V arithmetic instructions, the left-shift operation `sll` must write all 32 bits of the destination register. Recall our discussion of the [left shift operation](#sec-left-shift): the expression `x << n` shifts the bits of `x` left by `n` bits, filling the `n` lower bits with zero. The `sll` operation therefore fills in these new bits with `0`.

:::{warning} Why no `sla` instruction?

`sll` stands for **S**hift **L**eft **L**ogical. See [this note](#sec-why-shift-left) for why shift left logical and shift left arithmetic are equivalent.

:::

(sec-rv32i-srl-sra)=
### Shift right

Recall our discussion of the [right shift operation](#sec-right-shift): the expression `x >> n` shifts the bits of `x` right by `n` bits, filling the `n` lower bits with zero or one. In C, this was determined by `x`'s **type**. In RISC-V, the **instruction** determines what the lower bits are filled in with

* `srl`, or **S**hift **R**ight **L**ogical (`srli` for immediate). "Zero-extend" and fill the upper bits with `0`. This instruction effectively interprets register `rs1`'s contents as an unsigned integer. Read more in an [earlier section](#sec-right-shift-logical).
* `sra`, or **S**hift **R**ight **A**rithmetic (`srai` for immediate). Fill in the upper bits with the sign bit of register `rs1`. This instruction effectively interprets register `rs1`'s contents as a signedinteger. Read more in an [earlier section](#sec-right-shift-arithmetic).

shift arithmetic: signed

## Other RISC-V arithmetic instructions

General multiplication is not included in the base RISC-V ISA but is specified as part of common RISC-V extensions. See the `mul` instruction on the [RISC-V green card](#tab-rv32i-extension).

The circuitry for general multiplication is significantly more complicated than the bitwise left- and right-shift operations discussed above. For similar reasons, we do not discuss division, modulo, and floating point operations.[^curious]

[^curious]: We encourage you to read the RISC-V unprivileged ISA for the [M Extension](https://docs.riscv.org/reference/isa/unpriv/m-st-ext.html) and the [F extension](https://docs.riscv.org/reference/isa/unpriv/f-st-ext.html).

## Practice

:::{tip} Practice
After the below instructions are executed, what is in register `x12`?

```{code} bash
:linenos:
li    x10 0x34FF
slli  x12 x10 0x10
srli  x12 x12 0x08
and   x12 x12 x10
```

* **A.** `0x0`
* **B.** `0x3400`
* **C.** `0x4F0`
* **D.** `0xFF00`
* **E.** `0x34FF`
* **F.** Something else

:::

:::{note} Show answer
:class: dropdown

**B.** `0x3400`.

These instructions are the RISC-V translation of the [C practice example](#sec-c-bitwise-practice) when we discussed C bitwise operations. We recommend reviewing that first.

Each line, explained:

1. Write value `0x000034FF` to register `x10`.

2. `R[x10] << 0x10` is `0x34FF0000`. Write this value to register `x12`.

3. `R[x12] >> 0x8` is `0x0034FF00` because the sign bit of `R[x12]` is initially `0`.

4. `R[x12] & R[x10]` is `0x000034FF & 0x0034FF00` is `0x00003400`. See @fig-bit-shift from the [C practice example](#sec-c-bitwise-practice).

:::
