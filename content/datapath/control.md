---
title: "Control Logic Design"
---

(sec-datapath-control)=
## Learning Outcomes

* Given an instruction, identify control signals.
* Explain how a ROM can be used in control logic to translate instruction bits ("address input") into control signals ("word output").
* Implement control logic with ROM and combinational logic blocks.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/VZHbfvhIEq8
:width: 100%
:title: "[CS61C FA20] Lecture 20.4 - Single-Cycle CPU Control: Control Logic Design"
:::

::::

In this section we discuss how to implement the **controller**, i.e., the control logic block. Here are two figures from previous sections to jog your memory.

:::{figure} #fig-five-step-single-cycle-control

As the datapath computes values, the control logic selects the necessary values needed to execute the instruction (@fig-five-step-single-cycle-control from [our chapter introduction](#sec-single-cycle)).
:::

## Review Control Signals

Before continuing, review the following video, which practices identifying and setting the control signals that set the datapath operation for two different instructions: `sw` and `beq`.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/wM85LGWD54U
:width: 100%
:title: "[CS61C FA20] Lecture 20.2 - Single-Cycle CPU Control: Datapath Control"
:::
::::

Then, confirm the control signals for the subset of instructions shown in @tab-control-truth-table.

:::{table} A partially filled out truth table for RV32I Control Logic, based on the input instruction `inst`. An asterisk (*) means "don't care." Work out the full table in Project 3!
:label: tab-control-truth-table

| Instruction | PCSel | ImmSel | BrUn | ASel | BSel | ALUSel | MemRW | RegWEn | WBSel |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `add` | +4 | * | * | Reg | Reg | Add | Read | 1 | ALU |
| `sub` | +4 | * | * | Reg | Reg | Sub | Read | 1 | ALU |
| `addi` | +4 | I | * | Reg | Imm | Add | Read | 1 | ALU |
| `lw` | +4 | I | * | Reg | Imm | Add | Read | 1 | Mem |
| `sw` | +4 | S | * | Reg | Imm | Add | Write | 0 | * |
| `beq` | (@tab-branch-truth-table) | B | * | PC | Imm | Add | Read | 0 | * |
| `bne` | (@tab-branch-truth-table) | B | * | PC | Imm | Add | Read | 0 | * |
| `blt` | (@tab-branch-truth-table) | B | 0 | PC | Imm | Add | Read | 0 | * |
| `bltu` | (@tab-branch-truth-table) | B | 1 | PC | Imm | Add | Read | 0 | * |
| `jalr` | ALU | I | * | Reg | Imm | Add | Read | 1 | PC+4 |
| `jal` | ALU | J | * | PC | Imm | Add | Read | 1 | PC+4 |
| `auipc` | +4 | U | * | PC | Imm | Add | Read | 1 | ALU |

:::

Remember that branches conditionally update PC based on the output of the [branch comparator block](#sec-datapath-branch-comparator). The block's output signals `BrEq` and `BrLT` are fed into the control logic, which then sets `PCSel` selector that wires into the `PCSel` mux. See the partial truth table below (@tab-branch-truth-table).

:::{table} A partially filled out truth table that determines PCSel for branch instructions.
:label: tab-branch-truth-table

| Instruction | Branch? | BrEq | BrLT | PCSel |
| :--- | :--: | :--: | :--: | :--: |
| `beq` | not taken | 0 | * | +4 |
| `beq` | taken | 1 | * | ALU |
| `bne` | not taken | 1 | * | +4 |
| `bne` | taken | 0 | * | ALU |
| `blt` | taken | * | 1 | ALU |
| `bltu` | taken | * | 1 | ALU |
:::

## Control Logic / Controller

The **control logic subcircuit** (i.e., the **controller**) takes the instruction bits (and `BrEq`, `BrLT`) and outputs all the control signals needed to execute that instruction. The control signals are listed in @tab-controller-signals.

:::{table} Signals for control logic. Course project signal names, if different, are in parentheses.
:label: tab-controller-signals

| Name | Bit Width | Purpose |
| :--- | :--- | :--- |
| `PCSel` | 1 | Selects the ALU input for all B-type instructions where the branch is taken (according to the branch comparator output) and all jumps. Selects the PC+4 input for all other instructions. |
| `ImmSel` | 3 | Selects the instruction format so the immediate generator can extract the immediate correctly. See @tab-immgen-operations in the [Immediate Generator section](#sec-datapath-immgen) |
| `RegWEn` | 1 | 1 if the instruction writes to a register, and 0 otherwise. |
| `BrUn` | 1 | 1 if the branch instruction is unsigned, and 0 if the branch instruction is signed. Don't care for all other instructions. |
| `ASel` | 1 | Selects whether to send the data in `rdata1` (`RegReadData1`) or the PC to the ALU. |
| `BSel` | 1 | Selects whether to send the data in `rdata2` (`RegReadData2`) or the immediate to the ALU. |
| `ALUSel` | 4 | Selects the correct operation for the ALU. See @tab-alu-operations in the [ALU section](#sec-datapath-alu). |
| `MemRW` | 1 | 1 if the instruction writes to memory, and 0 otherwise. |
| `WBSel` | 2 | Selects whether to write the memory read from DMEM, the ALU output, or PC+4 to `rd`. |

:::

In general, there are two approaches to implementing control logic:

1. **Read-Only Memory (ROM)**:  A ROM reads out words at a given input address. Because the ROM is read-only, it is populated with the needed ones and zeros at design time.

    The regular structure of a ROM means it can easily designed and reprogrammed to fix errors (e.g., during prototyping) or when adding instructions (like extensions for compressed instructions). ROMs are also popular when designing control logic manually, like in this course.

1. **Combinational Logic** using AND, OR, and NOT gates. In real chip design, control is typically designed with logic gates because it is more compact and much faster than ROM alternatives. Today, chip designers use logic synthesis tools to convert truth tables to networks of gates. See this approach [below](#sec-control-cl).

## ROM Approach

In this course, we implement the controller design in @fig-control-design, which has two subcircuits:

1. **Read-Only Memory (ROM)**: The ROM takes in a 9-bit address constructed from the instruction bits, then outputs a 14-bit "word" that can be decoded into the needed control signals.

2. The **Take branch?** combinational logic block takes in the Branch Comparator outputs and outputs the `PCSel` control signal.

:::{figure} images/control-design.png
:label: fig-control-design

Suggested control design has two parts.

:::

:::{tip} Instruction Bits

Why do we only need the 9 instruction bits `inst[30, 14:12, 6:2]`?

:::

:::{note} Show Answer
:class: dropdown

By reducing the address input, we can reduce the size of our ROM.

In RV32I, the instruction type is defined by the fields `opcode`, `funct3`, and `funct7`, where the latter two are present based on instruction format type. This would imply a 17-bit-wide address to our ROM.

However, upon closer inspection, we realize that several of these bit fields are redundant, resulting in a "9-bit ISA" for RV32I:

* `inst[6:2]`: The five unique bits of the 7-bit wide `opcode` field. In RV32I, only the upper five bits of `opcode` are unique. The lower two bits `inst[1:0]` are fixed in RV32I because they are reserved for extensions (e.g., compressed instructions).
* `inst[14:12]` The three unique bits of the `funct3` field.
* `inst[30]`: The only unique bit of the 7-bit wide `funct7` field. This singular bit differentiates `add` from `sub` and `sll` from `srl` (for more details, see [this section](#sec-funct7-explanation)).

In other words, in RV32I, the instruction type is encoded using only **9 bits**.
:::

:::{tip} Decoder

What does the decoder do?

:::

:::{note} Show Answer
:class: dropdown

The decoder takes the 14-bit output word from the ROM and splits it into the control signals in @tab-controller-signals, *with the exception* of `PCSel`.
:::

:::{tip} The `PCSel` control signal

Why do we need a "Part 2"? Why is `PCSel` not directly encoded in the ROM?
:::

:::{note} Show Answer
:class: dropdown

The `PCSel` control signal cannot be encoded in the ROM since it depends on `BrEq` and `BrLT` for B-Type/branch instructions. These signals are computed with the branch comparator (from the datapath), which depends on outputs of datapath elements driven by control signals from the ROM unit.
To complete the control logic, implement the "Take branch?" block as combinational logic to drive the `PCSel` output.
:::

:::{tip} Stable waveforms

How can we ensure that `PCSel` is stable?
:::

:::{note} Show Answer
:class: dropdown

Because the two "parts" of control logic use different data signals that are stable at different parts of the clock cycle, it is possible that early in the cycle, `PCSel` may hold an incorrect value before `BrEq` and `BrLT` are computed using the stable inputs `R[rs1]` and `R[rs2]` of the [branch comparator](#fig-branch-branch-comparator). Close to the end of the cycle, `BrEq` and `BrLT` will be stable, thereby setting `PCSel` to the correct value.

The clock cycle must be (at least) long enough to accommodate:

* `ID`: Reading register values `R[rs1]` and `R[rs2]`
* `EX`: Computing `PC + imm` with the ALU
* Control: Setting up `BrUn` (and all other `inst`-based signals)
* `EX`: Comparison using the branch comparator
* Control: Setting up `PCSel` based on `BrEq` and `BrLT`

:::

(sec-control-cl)=
## Combinational Logic Approach

Because the ROM effectively performs a lookup on a giant [truth table](#tab-control-truth-table), we can alternatively implement our control logic subcircuit entirely using AND, OR, and NOT gates. We can use our trusty [Sum of Products](#sec-sum-product) approach to write the canonical form, then reduce the expression using Boolean Algebra Laws.

**Example 1**: Suppose we wanted to implement a signal that is high if we have an R-Type instruction. The opcode for all R-Type instructions is `0110011` (instruction bits `inst[7:0]`), so our corresponding boolean expression is:

```{math}
\text{R-Type} = (\overline{\texttt{inst}[6]} \cdot \texttt{inst}[5] \cdot \texttt{inst}[4] \cdot \overline{\texttt{inst}[3]} \cdot \overline{\texttt{inst}[2]})
```

**Example 2**: Suppose we wanted to implement the `BrUn` signal. The `BrUn` signal is high if we have a B-Type instruction AND if that instruction's `funct3` indicates an unsigned compare.

:::{table} B-Type `opcode` and `funct3` fields derived from the [RISC-V green card](#tab-rv32i-control).
:label: tab-b-type-opcode-funct3

| `Instruction` | Opcode <br/>(`inst[6:0]`) | Funct3<br/>(`inst[14:12]`) |
| :--- | :--- | :--- |
| `beq rs1 rs2 label` | `110 0011` | `000` |
| `bne rs1 rs2 label` | `110 0011` | `001` |
| `blt rs1 rs2 label` | `110 0011` | `100` |
| `bltu rs1 rs2 label` | `110 0011` | `110` |
| `bge rs1 rs2 label` | `110 0011` | `101` |
| `bgeu rs1 rs2 label` | `110 0011` | `111` |

:::

Considering the fields of the relevant instructions above, we can write an expression for `BrUn`:

```{math}
\begin{aligned}
\texttt{BrUn} &= (\text{B-Type}) \cdot (\text{Unsigned Compare}) \\
&= (\texttt{inst}[6] \cdot \texttt{inst}[5] \cdot \overline{\texttt{inst}[4]} \cdot \overline{\texttt{inst}[3]} \cdot \overline{\texttt{inst}[2]}) \cdot (\texttt{inst}[13])
\end{aligned}
```