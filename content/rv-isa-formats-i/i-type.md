---
title: "I-Type"
---

(sec-i-type)=
## Learning Outcomes

* Translate between I-type assembly instructions and machine instructions.
* Reason about why load and `jalr` are I-Type instructions.
* Translate `jr` and `ret` pseudoinstructions to machine instructions.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/EtLGVuSFwkU
:width: 100%
:title: "[CS61C FA20] Lecture 11.3 - RISC-V Instruction Formats I: I-Format Layout"
:::

::::

We now turn to our next instruction format: I-Type. While the "I" is for Immediate, the I-Type instruction format is used for a variety of instructions:

* **Register-immediate** arithmetic instructions
* Load instructions
* The `jalr` instruction
* (out of scope) Environment calls and breakpoints

The I-Type instruction format is the second and third rows of the [instruction format table](#tab-rv32i-types).

## I-Type: Fields

We first discuss arithmetic instructions of the form `opname rd rs1 imm` like `addi`, `xori`, etc. The format is shown in @fig-i-type:

:::{figure} images/i-type.png
:label: fig-i-type
:width: 100%
:alt: "TODO"

The I-Type Instruction Format.
:::

I-Type Fields:

* **Register operands**: Notice that the register fields  `rs1` and `rd` are in the same positions in I-Type and [R-type](#fig-r-type); this intentional design reduces hardware complexity.
* **Constant operand**: The **immediate field**[^imm-reminder] `imm` specifies a 12-bit-wide numeric constant. The I-Type has no second source register `rs2`, so `imm` reuses those bit positions to encode a larger numeric constant across bits 15 to 31.

    The 12-bit immediate is a two's complement integer with range $-2^{11} = -2048$ to $2^{11} - 1 = 2047$. Before using this 12-bit-wide value in an operation, the hardware **sign-extends** it to a 32-bit-wide value.
* **Operation fields**: `opcode`, `funct3`

[^imm-reminder]: Again, immediates are called as such because their bit patterns are directly encoded into the machine instruction.



## Assembly Instruction $\rightarrow$ Machine Instruction

Consider @fig-itype-addi-example, which translates `addi x15 x1 -50` to a machine instruction.

:::{figure} images/itype-addi-example.png
:label: fig-itype-addi-example
:width: 100%
:alt: "TODO"

The I-Type instruction `addi x15 x1 -50`.
:::

We follow the [steps for translating assembly into machine code](#sec-assembly-to-machine) from earlier:

1. **Determine instruction format type**. `addi` is I-type because it performs arithmetic betwen a register operand and a constant operand. We use the [arithmetic instructions table](#tab-rv32i-arithmetic) on the RISC-V green card.

1. **Determine operation field codes**.

    * `opcode`: `0010011` for all register-immediate arithmetic instructions
    * `funct3`: `000` for `add`

1. **Translate registers, immediates, etc.**

    * `rs1`: Register `x1`. Translate $1$ to 5-bit unsigned integer representation `00001`.
    * `rd`: Register `x15`. Translate $15$ to 5-bit unsigned integer representation `01111`.
    * `imm`: $-50$ as 12-bit two's complement:
        * $+50$ is `0000 0011 0010`.
        * Flip bits: `1111 1100 1101`.
        * Add one to get $-50$: `1111 1100 1110`.

1. (if needed) Convert to hexadecimal.

    * We leave this as an exercise to you!

## I-Type vs. R-Type

@fig-comparison-itype-rtype compares the two instruction formats we have seen so far:

:::{figure} images/comparison-itype-rtype.png
:label: fig-comparison-itype-rtype
:width: 100%
:alt: "TODO"

I-Type instruction set comparison to R-Type instruction set.
:::

Again, good design demands good compromises. If we only had the single R-Type format and specified `imm` as a 5-bit field replacing `rs2`, then we'd only be able to represent 32 immediate values. The I-Type field therefore expands the `imm` field across the R-type's `rs2` and `funct7` fields to at least guarantee we can represent a wider range of $2^{12}$ immediate values.

The I-type design's consistency with R-type simplifies how hardware processes these two instruction formats. Constants are frequently short and can fit into the 12-bit `imm` field. For larger constants, we must use additional instructions like `lui` (load upper-immediate), which we discuss later.

Notice the 3-bit `funct3` field is not sufficient to specify the 9 register-immediate arithmetic instructions, much less any load instructions. The I-Type therefore still has a few details. Onward!

## Arithmetic Shifts ("I*-Type")

While there is no official "I*-Type" instructions, the [RV32I Unprivileged Manual](https://docs.riscv.org/reference/isa/unpriv/rv32.html#2-5-1-integer-register-immediate-instructions) says:

> Shifts by a constant are encoded as a specialization of the I-type format.

In this course we will call these "I*-Type" (where the asterisk is "mostly I-Type, save some details"). Consider @tab-istar-type and the following excerpt from the manual:

> The operand to be shifted is in rs1, and the shift amount is encoded in the lower 5 bits of the I-immediate field. The right shift type is encoded in bit 30.

:::{table} Shift-by-immediate instructions.
:label: tab-istar-type
:align: center

| Instruction | imm[11:5] | imm[4:0] | rs1 | funct3 | rd | opcode |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `slli` | `0000000` | `imm[4:0]` | `rs1` | `001` | `rd` | `0010011` |
| `srli` | `0000000` | `imm[4:0]` | `rs1` | `101` | `rd` | `0010011` |
| `srai` | `0100000` | `imm[4:0]` | `rs1` | `101` | `rd` | `0010011` |
:::

Observations:

* Arithmetic bitshift operations need only a 5-bit **unsigned** immediate, in `imm[4:0]`. The maximum bitshift is 32; anything larger will shift all data off the register, which is 32 bits wide.

* The upper seven bits[^itype-funct7] are **not** part of the immediate and used very similarly to the `funct7` field for R-Type instructions `sll`, `srl`, and `sra`.

    * Like with R-type, Bit 30 is a flag that indicates when it is necessary to sign-extend.
    * If Bit 30 is on, insert leading `1`'s (for `srai`).
    * If Bit 30 is off, just zero-extend for `srli` (and `slli`, where left-shifts are only ever logical).

[^itype-funct7]: The course [RISC-V green card](#sec-green-card) labels these upper 7 bits as "funct7"–a misnomer, because I-Types don't have a `funct7` field. As per the [RISC-V Unprivileged Manual](https://docs.riscv.org/reference/isa/unpriv/rv32.html#2-5-1-integer-register-immediate-instructions) these upper 7 bits should really be relabeled `imm[11:5]`–part of the `imm[11:0]` field, but not considered part of the numeric constant.

## Load Instructions

Remember, instruction formats are simply just formats. The operation specifies what the hardware actually does. However, keeping the same instruction format allows us to simplify and reuse certain hardware.

**Load instructions** are one such example.
Recall from an [earlier section](#sec-load-word):

> The **load word** instruction:
> 
> * **Computes a memory address** `R[rs1]+imm`
> * **Load a word** from this address in memory, `M[R[rs1] + imm][31:0]` into a **destination register**, `rd`.

Loads can therefore use I-Type instruction format (@fig-load-operation-isa):

* `imm`, `rs1`, `rd` fields
* `opcode` (as all instructions do). Loads use opcode `000 0011`.
* `funct3` specifies partial loads and signed/unsigned loads.

:::{figure} images/load-operation-isa.png
:label: fig-load-operation-isa
:width: 100%
:alt: "TODO"

Load instructions use I-Type instruction format.
:::

Observations:

* The fact that loads perform a memory access is irrelevant to how we specify the instruction. The instruction bits simply provide enough information for the hardware to decode and execute the correct instruction.
* Loads _do_ share some similarities with other I-Type instructions. Notably, loads also perform **register-immediate addition** to compute the memory address as `R[rs1] + imm`. Loads can therefore reuse any hardware needed for register-immediate arithmetic instructions.

We recommend reviewing [the earier chapter](#sec-data-transfer) for the description of each load instruction in @tab-i-type-loads.

:::{table} Load Instructions (recall there is no `lwu`).
:label: tab-i-type-loads
:align: center

| Instruction | imm[11:0] | rs1 | funct3 | rd | opcode |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `lb` | `imm[11:0]` | `rs1` | `000` | `rd` | `0000011` |
| `lbu` | `imm[11:0]` | `rs1` | `100` | `rd` | `0000011` |
| `lh` | `imm[11:0]` | `rs1` | `001` | `rd` | `0000011` |
| `lhu` | `imm[11:0]` | `rs1` | `101` | `rd` | `0000011` |
| `lw` | `imm[11:0]` | `rs1` | `010` | `rd` | `0000011` |
:::

### Load Example

:::{tip} Quick Check

Translate `lw x14 8(x2)` to a machine instruction.

:::

::::{note} Show Explanation
:class: dropdown

:::{figure} images/practice-lw.png
:label: fig-practice-lw
:width: 100%
:alt: "TODO"

The I-Type instruction `lw x14 8(x2)`.
:::

We follow the [steps for translating assembly into machine code](#sec-assembly-to-machine) from earlier:

1. **Determine instruction format type**. `lw` is I-type. We use the [memory table](#tab-rv32i-memory) on the RISC-V green card.

1. **Determine operation field codes**.

    * `opcode`: `0000011` for load instructions
    * `funct3`: `010` for load **word**

1. **Translate registers, immediates, etc.**

    * `rs1`: Base Register `x2`. Translate $1$ to 5-bit unsigned integer representation `00010`.
    * `rd`: Register `x14`. Translate $14$ to 5-bit unsigned integer representation `01110`.
    * `imm`: address offset $+8$ as 12-bit two's complement: `0000 0000 1000`.
::::

(sec-jalr-itype)=
## `jalr`: I-Type

We recommend reviewing [jump instructions](#sec-jumps) before continuing:

> **J**ump **a**nd **L**ink **R**egister (`jalr rd rs1 imm`). Link the "return address" (`PC + 4`) to a register `rd`. Then perform an unconditional jump by setting `PC` to `R[rs1] + imm`.

The `jalr` instruction can also be supported with the I-Type format (@fig-jalr-isa):

* `imm`, `rs1`, `rd` fields
* `opcode` (as all instructions do). `jalr` uses opcode `110 0111`.
* `funct3` is not particularly needed, since there is only one `jalr` instruction. However, because the I-Type format requires it, `jalr` uses `000`.

:::{figure} images/jalr-isa.png
:label: fig-jalr-isa
:width: 100%
:alt: "TODO"

jalr instruction format. The program counter is updated to the base register plus a numeric constant, e.g., `PC = R[rs1] + imm`.
:::

Observations:

* Like with loads, the fact that `jalr` accesses PC is irrelevant to how we specify the instruction. 
* Like with loads, `jalr` also performs **register-immediate addition**, `jalr` can therefore reuse register-immediate arithmetic hardware to compute the jump address `R[rs1] + imm`.

:::{warning} What about `jr` and `ret`?

Pseudoinstructions are not allocated additional `opcode` nor `funct3` specifications, because they are not real RISC-V instructions.

Pseudoinstructions `jr rs1` and `ret` are `jalr x0 rs1 0` and `jalr x0 ra 0`, respectively.
:::

## Design Decisions for I-Type

This section is intended for you to develop your intuition for I-Type instructions using what you learned in this section.

Consider the I-Type instructions[^ebreak-ecall] shown in @tab-i-type, which is a reformatting of the rightmost columns of relevant tables on the RISC-V green card.

[^ebreak-ecall]: `ecall`, `ebreak` are out of scope in our discussion, but see more details in the [RISC-V Green Card](#sec-green-card) and the [RISC-V Unprivileged Manual](https://docs.riscv.org/reference/isa/unpriv/rv32.html#ecall-ebreak).

:::{table} RV32I Instructions: (a) I-Type; (b) "I*-Type", a reprint of @tab-istar-type.
:label: tab-i-type
:align: center

| Instruction | imm[11:0] | rs1 | funct3 | rd | opcode |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `addi` | `imm[11:0]` | `rs1` | `000` | `rd` | `0010011` |
| `andi` | `imm[11:0]` | `rs1` | `111` | `rd` | `0010011` |
| `ori` | `imm[11:0]` | `rs1` | `110` | `rd` | `0010011` |
| `xori` | `imm[11:0]` | `rs1` | `100` | `rd` | `0010011` |
| `slti` | `imm[11:0]` | `rs1` | `010` | `rd` | `0010011` |
| `sltiu` | `imm[11:0]` | `rs1` | `011` | `rd` | `0010011` |
| `lb` | `imm[11:0]` | `rs1` | `000` | `rd` | `0000011` |
| `lbu` | `imm[11:0]` | `rs1` | `100` | `rd` | `0000011` |
| `lh` | `imm[11:0]` | `rs1` | `001` | `rd` | `0000011` |
| `lhu` | `imm[11:0]` | `rs1` | `101` | `rd` | `0000011` |
| `lw` | `imm[11:0]` | `rs1` | `010` | `rd` | `0000011` |
| `jalr` | `imm[11:0]` | `rs1` | `000` | `rd` | `1100111` |
| `ecall` | `000000000000` | `00000` | `000` | `00000` | `1110011` |
| `ebreak` | `000000000001` | `00000` | `000` | `00000` | `1110011` |

| Instruction | imm[11:5] | imm[4:0] | rs1 | funct3 | rd | opcode |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `slli` | `0000000` | `imm[4:0]` | `rs1` | `001` | `rd` | `0010011` |
| `srli` | `0000000` | `imm[4:0]` | `rs1` | `101` | `rd` | `0010011` |
| `srai` | `0100000` | `imm[4:0]` | `rs1` | `101` | `rd` | `0010011` |
:::

:::{tip} Discussion Question 1
I-Type: How many unique `opcode`’s?
:::

:::{note} Show Explanation
:class: dropdown
1. Arithmetic: `0010011`
1. Load: `0000011`
1. jalr: `1100111`
1. Other (`ecall`, `ebreak`): `1110011`
:::

:::{tip} Discussion Question 2
Compare the I-Type `funct3` fields to the R-Type `funct3` fields (R-Type [table](#tab-r-type) from a previous section).
:::

:::{note} Show Explanation
:class: dropdown

Same eight unique `funct3` fields as corresponding R-format operation (remember, no `subi`)

| funct3 | R-Type  | I-Type |
| :--: | :--: | :--: |
| `000` | `add` | `addi` |
| `000` | `sub` | |
| `111` | `and` | `andi` |
| `110` | `or` | `ori` |
| `100` | `xor` | `xori` |
| `001` | `sll` | `slli` |
| `101` | `srl` | `srli` |
| `101` | `sra` | `srai` |
| `010` | `slt` | `slti` |
| `011` | `sltu` | `sltiu` |

:::

:::{tip} Discussion Question 3
In [@tab-i-type(b)](#tab-istar-type), what are "I*-Type" instructions, i.e., what kind of arithmetic operations are specified? Why do we only need 5 bits for `imm`? What are the upper 7 bits used for? What similarities are there to R-type?
:::

See explanation [above].

:::{tip} Discussion Question 4
Why does load also use I-Type instruction format?
What about `jalr`?
:::

First question: see explanation [above]. Second question: See a later section.
