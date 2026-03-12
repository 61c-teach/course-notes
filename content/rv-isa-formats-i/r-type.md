---
title: "R-type Instruction Format"
short_title: "R-Type"
---

(sec-r-type)=
## Learning Outcomes

* Identify an instruction format type by the `opcode` field.
* Translate between R-type assembly instructions and machine instructions.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/MpFv2_nuXv4
:width: 100%
:title: "[CS61C FA20] Lecture 11.2 - RISC-V Instruction Formats I: R-Format Layout"
:::

::::

Like with [IEEE 754 floating point numbers](#fig-float), the 32 bits of a machine instruction are split into fields. Like floating point, each field has a **name** and occupies a given set of bit positions (and therefore has a fixed width). Unlike floating point, the field names and locations themselves depend on the **instruction type**.

As an example, an R-type instruction is shown in @fig-opcode-field. The field named `opcode` occupies the least-significant bits (bit positions 0 to 6); the `opcode` field is 7 bits wide. Also notice that the assembly instruction `opname rd rs1 rs2` shares _some_ nomenclature with instruction fields, _but not all_. For example, `rs1`, `rs2`, and `rd` are field names, but `opname` is not.

:::{figure} images/opcode-field.png
:label: fig-opcode-field
:width: 100%
:alt: "TODO"

Field names and locations depend on the instruction format.
:::


:::{warning} Instruction formats specify which fields are where!
Different instruction formats may have different fields. Sometimes, different formats may specify _different places_ for the same field name!
:::

:::{hint} Use `opcode` to determine instruction format!

Fortunately, all RISC-V [instruction formats](#tab-rv32i-types) reserve the 7 lowest bits to the `opcode` field. Each instruction format is assigned a **distinct** set of opcode values.

When translating a machine instruction to assembly, the hardware first looks at the 7-bit `opcode` **first** to identify the instruction format type. **Once the format type is identified**, the hardware then knows how to treat the rest of the instruction.
:::

## R-Type: Fields

The R-Type instruction format is the first row of the [instruction format table](#tab-rv32i-types) of the [RISC-V green card](#sec-green-card). All **register-register arithmetic instructions use R-Type** (the "R" is for Register). We now use "arithmetic" to encompass arithmetic and bitwise operations: `add`, `xor`, `sll`, etc. 
We recommend you reference the [arithmetic instructions table](#tab-rv32i-arithmetic) as you explore the R-Type instruction format below.

@fig-r-type (@fig-opcode-field with less annotation) shows the R-Type format. Notice that all register-register arithmetic instructions have follow the same assembly instruction syntax `opname rd rs1 rs2`.

:::{figure} images/r-type.png
:label: fig-r-type
:width: 100%
:alt: "TODO"

The R-Type Instruction Format.
:::

**Register operands**: The three R-Type fields named  `rs1`, `rs2`, `rd` map to their equivalent assembly instruction operands. Each field is a 5-bit unsigned integer ($0$ to $31$) corresponding to a register number (`x0-x31`). Register names (e.g., `a0`) are translated first into their register number (e.g., `x10`), then their bit pattern (e.g., `01010`).

* `rs1`: “Source” Register, first operand
* `rs2`: "Source" Register, second operand
* `rd`: "Destination" Register gets the result of the arithmetic computation.

**Other fields**: The assembly instruction operation `opname` is mapped across three fields: `

* `opcode`: All R-type instructions have the same 7-bit opcode: `0110011`.
* `funct3`, `funct7`: The arithmetic operation to perform. `funct3` field is 3 bits wide; `funct7` is 7 bits wide.

:::{warning} Why do we use 17 bits to specify the operation/opcode?
Across the entire base RV32I instruction set, there are certainly fewer instructions than the $2^32$ possible representable things in a 32-bit word, so some redundancy is unavoidable. Good esign demands good premises.

Different instruction formats **reuse the same bit positions for the same fields wherever possible**. Keeping the instruction formats as similar as possible reduces hardware complexity. The register fields `rs1`, `rs2`, and `rd` are therefore prioritized, and opcode fields like `funct3` and `funct7` occupy the remaining bits.

:::

## Assembly Instruction $\rightarrow$ Machine Instruction

Consider @fig-rtype-add-example, which translates `add x18 x19 x10` to a machine instruction.

:::{figure} images/rtype-add-example.png
:label: fig-rtype-add-example
:width: 100%
:alt: "TODO"

The R-Type instruction `add x18 x19 x10`.
:::

(sec-assembly-to-machine)=
:::{note} Translate instructions from assembly to machine code

1. **Determine instruction format type**. Use the [RISC-V green card](#sec-green-card).

1. **Determine operation field codes**. Use the [RISC-V green card](#sec-green-card) to determine the `opcode` and (if applicable) `funct3` and `funct7`.

1. **Translate registers, immediates, etc.**

1. (if needed for human readability) **Convert to hexadecimal**.

:::

1. **Determine instruction format type**. `add` is R-type because it performs arithmetic on two register operands. We use the [arithmetic instructions table](#tab-rv32i-arithmetic) on the RISC-V green card.

1. **Determine operation field codes**.

    * `opcode`: `0110011` (for all R-Type instructions).
    * `funct3`: `000` for `add`
    * `funct7`: `0000000` for `add`

1. **Translate registers, immediates, etc.**

    * `rs1`: Register `x19`. Translate $19$ to 5-bit unsigned integer representation `10011`.
    * `rs2`: Register `x10`. Translate $10$ to 5-bit unsigned integer representation `01010`.
    * `rd`: Register `x18`. Translate $18$ to 5-bit unsigned integer representation `10010`.

1. (if needed) Convert to hexadecimal.

    * We leave this as an exercise to you!

## Machine Instruction $\rightarrow$ Assembly Instruction

Steps for translating machine code into assembly:

1. If needed, convert to binary. Then, find the opcode and use that to determine the instruction format type.
1. Split into fields according to instruction format type.
1. For R-Type, determine the assembly instruction `opname` with the `funct3`, `funct7` fields.
1. For R-Type, determine register operands and (if needed) register names.

The last two steps are **R-Type**-specific. In general, you should always do the first two steps, regardless of instruction format type. Then, perform type-specific conversions to reconstruct the original assembly instruction.

:::{tip} Quick Check

Translate this word into a RISC-V instruction:
`0x01B342B3`.

In binary: `0b0000 0001 1011 0011 0100 0010 1011 0011`.

* **A.** `slt  x5  x6 x27`
* **B.** `slt x27  x5  x6`
* **C.** `slt  x5 x27  x6`
* **D.** `xor s11  t0  t1`
* **E.** `xor  t0  t1 s11`
* **F.** `xor  t0 s11  t1`
* **G.** Something else
:::

:::{note} Show Answer
:class: dropdown

**E.** `xor  t0  t1 s11`

:::

Explanation:

1. We have already converted `0x01B342B3` to binary: `0b0000 0001 1011 0011 0100 0010 1011 0011`.

    **Then, find the opcode and use that to determine the instruction format type.** The `opcode` field is always the lowest 7 bits of the instruction, regardless of format. `0110011` is the opcode for R-Type instructions.

2. **Split into fields according to instruction format type.**. For translation, it is not particularly useful to visually space out nybbles, as above. In @fig-practice-hex-xor, the 32-bit pattern above is visually split into the six fields of the R-Type instruction format.

:::{figure} images/practice-hex-xor.png
:label: fig-practice-hex-xor
:width: 100%
:alt: "TODO"

Once an instruction's type is known, the instruction bits can be mapped to fields.
:::

3. **Determine the assembly instruction `opname`**. The `funct3` field is `100`; the `funct7` field is `0000000`. We look up these fields on our [green card](#tab-rv32i-arithmetic) and discover the instruction is `xor`.

4. **Determine registers**. Use the [register convention table](#tab-calling-convention) for register names.

    * `rd`: `10010` is $5$, so register `x5`, aka `t0`.
    * `rs1`: `00110` is $6$, so register `x6`, aka `t1`
    * `rs2`: `11011` is $27$, so register `x27`, aka `s11`.

Given the above, the instruction is **E.** `xor  t0  t1 s11`.

## Design Decisions for R-Type

Consider all 10 R-Type instructions shown in @tab-r-type, which is a reformatting of the rightmost columns of the [equivalent table](#tab-rv32i-arithmetic) on the RISC-V green card.

Analyze this table. What do you notice? What do you wonder? The below discussion questions practice the following:

1. Read and interpret instruction fields
1. Develop your design intuition for architecture.

:::{table} RV32I Instructions: R-Type
:label: tab-r-type
:align: center

| Instruction | funct7 | rs2 | rs1 | funct3 | rd | opcode |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `add` | `0000000` | `rs2` | `rs1` | `000` | `rd` | `0110011` |
| `sub` | `0100000` | `rs2` | `rs1` | `000` | `rd` | `0110011` |
| `and` | `0000000` | `rs2` | `rs1` | `111` | `rd` | `0110011` |
| `or` | `0000000` | `rs2` | `rs1` | `110` | `rd` | `0110011` |
| `xor` | `0000000` | `rs2` | `rs1` | `100` | `rd` | `0110011` |
| `sll` | `0000000` | `rs2` | `rs1` | `001` | `rd` | `0110011` |
| `srl` | `0000000` | `rs2` | `rs1` | `101` | `rd` | `0110011` |
| `sra` | `0100000` | `rs2` | `rs1` | `101` | `rd` | `0110011` |
| `slt` | `0000000` | `rs2` | `rs1` | `010` | `rd` | `0110011` |
| `sltu` | `0000000` | `rs2` | `rs1` | `011` | `rd` | `0110011` |

:::


:::{tip} Discussion Question 1
R-Type: How many unique `opcode`’s?
:::

:::{note} Show Explanation
:class: dropdown
One `opcode` for all R-Types: `0110011`.
:::

:::{tip} Discussion Question 2
R-Type: How many unique `funct3`’s? unique `funct7`’s?
:::

:::{note} Show Explanation
:class: dropdown

* `funct3`: 8 unique, despite there being 10 instructions.
* `funct7`: 2 unique. The remaining two instructions vary in `funct7` fields.
:::

:::{tip} Discussion Question 3
Which instructions share `funct3` fields? What are their corresponding `funct7` fields?
:::

:::{note} Show Explanation
:class: dropdown

`funct3` field `000`: `add` and `sub`. To differentiate, look at `funct7` field. `sub` has a `1` in bit 30, whereas `add` does not.

`funct3` field `101`: `srl`, `sra`.  To differentiate, look at `funct7` field. `sra` has a `1` in bit 30, whereas `srl` does not.

:::

:::{tip} Discussion Question 4
For the instructions you found in the previous part, how _else_ are they similar? Why might this be useful?
:::

:::{note} Show Explanation

We have pre-expanded this box because it is so important.

* `add` and `sub` can share hardware. To execute `sub rd rs1 rs2` with an `add`, the hardware should negate register `rs2` value. Bit 30 is therefore a **flag**, or boolean indicator, that indicates when it is necessary to perform a two's complement **negation** of the bits of `rs2` before adding (for `sub`). If Bit 30 is off, just `add` like normal.
* `srl` and `sra` are both right-shifts and can share hardware. The difference is **sign-extension**. Bit 30 is therefore a flag that indicates when it is necessary to sign-extend and insert leading `1`'s (for `sra`). If Bit 30 is off, just zero-extend for `srl`.
:::
