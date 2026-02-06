---
title: "RISC-V Arithmetic Instructions"
---

(sec-rv-arithmetic)=
## Learning Outcomes

* Write assembly to perform arithmetic operations.
* Write arithmetic instructions involving immediates.
* Understand how pseudoinstructions and the zero register help balance a reduced instruction set with flexibility of operations.

::::{note} 🎥 Lecture Video: `add`/`sub`
:class: dropdown

:::{iframe} https://www.youtube.com/embed/-Vv4UaG9o9k
:width: 100%
:title: "[CS61C FA20] Lecture 07.3 - RISC-V Intro: RISC-V add/sub Instructions"
:::

::::

::::{note} 🎥 Lecture Video: Immediates
:class: dropdown

:::{iframe} https://www.youtube.com/embed/vGIEgP2ZZP8
:width: 100%
:title: "[CS61C FA20] Lecture 07.4 - RISC-V Intro: RISC-V Immediates"
:::

::::

## `add` and `sub` Instructions

Generally, assembly instructions have a very rigid format. Consider **arithmetic and logic instructions** like addition (`add`), bitwise AND (`and`), etc., which operate on two registers and store the result in a third register. These instructions always follow the same rigid syntax shown in @fig-r-type:

:::{figure} images/r-type.png
:label: fig-r-type
:width: 50%
:alt: "TODO"

R-Type instructions (arithmetic and logic involving two source registers).
:::

The fields are separated by spaces[^commas], in order:

* `opname`: The operation name
* `rd`: The destination register, i.e., the operand to which we store the result of the operation.
* `rs1`: The "source1" register, i.e., the first source operand for the operation.
* `rs2`: The "source2" register, i.e., the second operand for the operation.

:::{note} Why rigid syntax?

The rigid syntax of assembly instructions are intentional. Each RV32I assembly instruction directly maps to a 32-bit machine instruction that reflect the order of the instruction fields. This helps the hardware **decode** instructions quickly because it can reliably find the source and destination registers in the same bit fields, no matter the instruction. More later!
:::

[^commas]: Stylistically, assembly instructions can include commas. In RISC-V, commas are not needed. We stick to a space-only convention in this course.

The full set of instructions that follow the format in @fig-r-type are located on the [RISC-V green card](#sec-green-card-arithmetic). For now, we focus on two instructions in @tab-add-sub:

:::{table} The `add` and `sub` instructions.
:label: tab-add-sub
:align: center

| Instruction | Name | Description[^verilog] |
| :-- | :-- | :-- |
| `add  rd rs1 rs2` | ADD | `R[rd] = R[rs1] + R[rs2]` |
| `sub rd rs1 rs2` | SUBtract | `R[rd] = R[rs1] - R[rs2]` |

[^verilog]: We won't expect you to know Verilog in this course, but the syntax is useful. `R[rs1]` means the data in register `rs1`.

:::

The addition command in assembly is simply `add`, which is easy to remember. The RV32I instruction

```
add x1, x2, x3
```

is equivalent to the C statement `a = b + c;` for 32-bit integers[^signed-unsigned] `a`, `b`, and `c`, where each variable corresponds to a value stored in a register. In @fig-rv32i-add, the variable `a` is in register `x1`, variable `b` is in register `x2`, and variable `c` is in `x3`.

[^signed-unsigned]: You will see later that signed and unsigned addition and subtraction are implemented with the same hardware circuit.

:::{figure} images/rv32i-add.png
:label: fig-rv32i-add
:width: 50%
:alt: "TODO"

Addition instruction `add` in RISC-V and C.
:::

Subtraction works _almost_ the same way, using the operation sub. If you want to subtract the values in `x4` and `x5` and store the result in `x3`, you would write the below, which is equivalent to the C integer arithmetic statement `d = e - f;` (@fig-rv32i-sub).

```
sub x3, x4, x5
```

:::{figure} images/rv32i-sub.png
:label: fig-rv32i-sub
:width: 50%
:alt: "TODO"

Subtraction instruction `sub` in RISC-V and C.
:::

:::{hint} Operand order matters

One key difference to keep in mind is that addition is commutative, so it doesn't matter which order you place your source operands for `add`. However, subtraction is not commutative, so order matters. The `sub` instruction will always subtract value of the second source operand from the first.

:::

(sec-arithmetic-examples)=
### RISC Arithmetic: Examples

As mentioned [earlier](#tab-hll-vs-assembly), a single line of C may translate into several lines of RISC-V. Consider the C integer arithmetic statement:

```c
a = b + c + d - e;
```

Suppose that variables `a`, `b`, `c`, `d`, and `e` mapped to registers `x10`, `x1`, `x2`, `x3`, and `x4`, respectively. We can use `x10` as a running sum to compute the correct value of `a` after three instructions:

```
add x10  x1 x2   # a_temp = b + c
add x10 x10 x3   # a_temp = a_temp + d
sub x10 x10 x4   # a = a_temp - e
```

::::{tip} Quick check

Your turn! Assume the below mapping of C variables to RISC-V registers in @fig-example-2 for the below C integer arithmetic statement:

```c
f = (g + h) - (i + j);
```

:::{figure} images/example-2.png
:label: fig-example-2
:width: 50%
:alt: "TODO"

Mapping of C variables to RISC-V registers.
:::

Which of the below translations work? Why?

```
# Approach A
add  x5 x20 x21
add  x6 x22 x23
sub x19  x5  x6
```

```
# Approach B
add x19 x20 x21
sub x19 x19 x22
sub x19 x19 x23
```

::::

:::{note} Show Answer
:class: dropdown

Both solutions are valid. Tradeoffs:

* Approach A uses **temporary registers** `x5` and `x6` and more directly follows the C order of operations. However, any existing data in registers `x5` and `x6` will now be overwritten.

* Approach B leverages **algebra** to avoid any temporary registers. For more complicated algebra (e.g., distributing a multiply), we may need more clever compilers.

:::

## Immediates

**Immediates** are numerical constants in RISC-V. Immediates are called as such because their bit patterns are directly encoded into the machine instruction—thus their values are "immediately" available to the computer.

Immediates appear often in code; hence, they have separate instructions (@fig-i-type-arithmetic).

:::{figure} images/i-type-arithmetic.png
:label: fig-i-type-arithmetic
:width: 50%
:alt: "TODO"

Arithmetic and Logical I-Type instructions involving one source register and one immediate.
:::

Like [before](#fig-r-type), fields are separated by spaces[^commas], in order:

* `opname`: The operation name
* `rd`: The destination register, i.e., the operand to which we store the result of the operation.
* `rs1`: The "source1" register, i.e., the first source operand for the operation.
* `imm`: The immediate (numeric constant).

The full set of instructions that follow the format in @fig-i-type-arithmetic are located on the [RISC-V green card](#sec-green-card-arithmetic). 

### `addi` instruction

Let's discuss the **Add Immediate** instruction (@tab-addi).

:::{table} The `addi` instruction.
:label: tab-addi
:align: center

| Instruction | Name | Description[^verilog] |
| :-- | :-- | :-- |
| `addi rd rs1 imm` | ADD Immediate | `R[rd] = R[rs1] + imm` |

:::

The RV32I instruction

```
addi x3, x4, 10
```

is equivalent to the C statement `f = g + 10;`, where `f` and `g` are 32-bit integers (@fig-rv32i-addi).

:::{figure} images/rv32i-addi.png
:label: fig-rv32i-addi
:width: 50%
:alt: "TODO"

Add immediate instruction in RISC-V and C.
:::

:::{note} Similar formats

The format of `addi` and `add` are very similar and differ only in the last operand (register vs. immediate).
[^signed-unsigned] This similarity is intentional; when we implement both of these instructions, we want to reuse as much of the hardware as possible.

:::


::::{warning} No `subi` instruction!

Recall the "R" in RISC is **Reduced**. If an operation can be decomposed into equivalent or simpler operations, don’t include it in the ISA.

RISC-V Immediates are **signed**. There is therefore **no "subtract immediate" instruction**–there is just `addi`. The instruction

```
addi x3 x4 -10
```

is equivalent to the C statement `f = g - 10;` where `f` and `g` are 32-bit integers (@fig-rv32i-subi).

:::{figure} images/rv32i-subi.png
:label: fig-rv32i-subi
:width: 50%
:alt: "TODO"

Add immediate instruction in RISC-V and C with negative values.
::::

## Using `x0` to reduce our instruction set

We have [previously discussed](#sec-x0) the zero register `x0`. Hardwiring register `x0` to the value zero proves extremely useful for reusing `add` and `addi` for very common C operations.
Two toy examples are shown in  @fig-rv32i-x0-mv and @fig-rv32i-x0-li:

:::{figure} images/rv32i-x0-mv.png
:label: fig-rv32i-x0-mv
:width: 50%
:alt: "TODO"

To assign the C integer variable `f` to the value of another integer variable `g`, we _could_ use `add` with `x0` as a source operand (though we don't in practice[^mv]).
:::


:::{figure} images/rv32i-x0-li.png
:label: fig-rv32i-x0-li
:width: 50%
:alt: "TODO"

To assign the variable `f` to a numeric constant, use `addi` with `x0` as the source register operand.
:::

(sec-pseudoinstructions)=
## Pseudoinstructions

We have just seen several cases where common C statements translate into other instructions in our reduced instruction set architecture. While this is fine and dandy for designing architecture, compilers (and you, as a human assembly instruction-writer) will find it useful to use **pseudoinstructions**. 

**Pseudoinstructions** are convenient instructions in RISC-V. Pseudoinstructions help compilers more directly translate higher-level language code into assembly instructions (really!), but by themselves they are not real instructions.

Consider two examples below (and see the full set in the [RISC-V green card](#tab-rv32i-pseudoinstructions)).

:::{table} The subset pseudoinstructions.
:label: tab-mv-li
:align: center

| Pseudoinstruction | Name | Description | Translation |
| :--- | :--- | :--- | :--- |
| `mv rd rs1` | MoVe | `R[rd] = R[rs1]` | `addi rd rs1 0`[^mv] |
| `li rd imm` | Load Immediate | `R[rd] = imm` | `addi rd x0 imm`[^lui] |
| `nop` | No OPeration | do nothing[^nop] | `addi x0 x0 0` |

[^mv]: Why `addi` with immediate `0` and not `add` with `x0` (as in @fig-rv32i-x0-mv)? See the [ASM manual on GitHub](https://github.com/riscv-non-isa/riscv-asm-manual/blob/main/src/asm-manual.adoc#pseudoinstructions).
[^lui]: This description is incomplete given the range of `imm` in `addi`. See the [green-card](@tab-rv32i-pseudoinstructions) and future sections for the full translation of load immediates.
[^nop]: We will see later how a "no-op" instruction can improve hardware performance (really).
:::

When assembling to machine instructions, the assembler replaces pseudoinstructions with their real instruction counterpart.


