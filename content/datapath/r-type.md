---
title: "R-Type Datapath, ALU"
---

(sec-datapath-r-type)=
## Learning Outcomes

* Implement a datapath that supports R-Type instructions.
* Compare the datapath elements and logic needed to support `add` and `sub` instructions.
* Reason about the high-level design of an ALU element that supports RV32I instructions.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/f1cZGi4mZqo
:width: 100%
:title: "[CS61C FA20] Lecture 18.3 - Single-Cycle CPU Datapath I: R-Type Add Datapath"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/fVjZzX46SU4
:width: 100%
:title: "[CS61C FA20] Lecture 18.4 - Single-Cycle CPU Datapath I: Sub Datapath"
:::

::::

## Building a processor that `add`s

To start off, let's build the simplest processor we can: a processor that can process only one instruction: `add`. Programs will just be a series of `add`s:

```bash
add x18 x18 x10
add x18 x18 x18
add ...
```

:::{hint} Review the `add` instruction

* [The `add` instruction](#sec-rv-arithmetic)
* [R-Type instruction formats](#sec-r-type)
* [The Program Counter](#sec-rv-pc)
:::

In order to support `add` in our datapath, we consider the  two state elements changed by this instruction's operations:

* RegFile: We **read** two registers `rs1` and `rs2` and write one register `rd`. The value to write is the **sum** between the two read register values, `R[rs1] + R[rs2]`.
* PC: We **read** from and **write** to the PC register. The value to write is `PC + 4`.

Other state elements:

* IMEM: The processor must **read** the RV32I instruction from the read-only IMEM during the `IF` (Instruction Fetch) phase.
* DMEM: The processor does not additionally access memory via a load or store. The `add` instruction does not participate in the `MEM` phase of [the five step process](#sec-five-steps).

:::{warning} Goal: Iteratively Build Processor
In these notes, we will iteratively build the processor, meaning we will introduce important combinational logic blocks as the processor supports more instructions. Some animations will therefore not include the entire datapath. For exercises involving the full datapath, see the end of this chapter.
:::

:::{figure} images/add-no-dmem.png
:label: fig-add-no-dmem
For now, we disconnect DMEM since it is unused for `add` (@fig-add-no-dmem). We will add it back when we discuss [loads and stores](#sec-datapath-load-store).
:::

(sec-datapath-add)=
## Tracing the `add` Datapath

Given the above analysis, we can now connect wires between key elements of our processor.

::::{figure}
:label: anim-datapath-add
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-add.pptx
:width: 100%
:title: "Tracing the `add` Datapath"
:::
The `add` datapath. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
::::

1. **Instruction Fetch**:
    * On the rising clock edge, the `pc` wire updates to the instruction to execute in this cycle. It feeds into IMEM which, after some delay, updates the `inst` output signal.
    * Increment the PC to the next instruction. The `pc` wire also feeds into a small adder that adds `4`. The output to this small adder is wired to the input of the `PC` register, set up and ready to update on the next rising clock edge.

1. **Instruction Decode**: We only have one instruction, so decoding is simply decoding the specific bits to identify the registers. We use the green card and our [R-Type format](#tab-rv32i-types) to introduce a splitter on the `inst` signal to "index" into the RegFile as follows:
    * Wire `inst[7:11]` (bits 7 through 11, inclusive) to the `rd` input of RegFile.
    * Wire `inst[15:19]` to the `rs1` input of RegFile.
    * Wire `inst[20:24]` to the `rs2` input of RegFile.

    After some delay, the RegFile updates the `rdata1` and `rdata2` signals to the values of `R[rs1]` and `R[rs2]`, where `rs1` and `rs2` are determined from the instruction `inst`.

1. **Execute**: Our ALU (see [below](#sec-datapath-alu)) should perform the Addition operation. For now, we just mark this block as an Adder. Feed in the two RegFile output signals into the `A` and `B` inputs of the "ALU." After some delay, the 

1. **Memory**: (We don't access memory, so skip this.)

1. **Write Back**: Connect the output signal of the ALU to the `wdata` input signal of the RegFile. Set the RegFile control signal `RegWEn` to `1` to indicate that `wdata` should be written to `R[rd]` on the next rising clock edge.

    Around the next rising clock edge, `wdata`, `RegWEn`, and `rd` should be held stable through setup and hold time of RegFile.


## Building a processor that `add`s and `sub`s

Next, let's improve our processor by supporting two instructions: `add` and `sub`. Example program:

```bash
add x18 x18 x10
sub x18 x18 x18
sub ...
add ...
```

Let's again consider the state elements changed by this instruction's operations:

* RegFile: We still **read** two registers `rs1` and `rs2` and write one register `rd`. But now the value to write is the **difference** between the two read register values, `R[rs1] - R[rs2]`.
* PC: We **read** from and **write** to the PC register. The value to write is `pc + 4`.

`sub` is almost the same as `add`, except now the ALU subtracts. We implement the support for both `add` and `sub` by assuming more complexity in the Control Logic "block" (@fig-sub-datapath).

:::{figure} images/sub-datapath.png
:label: fig-sub-datapath
To implement `sub` and `add`, we update control logic.
:::

:::{note} Show explanation

* Control logic takes as input all 32 bits of the instruction `inst`.
* Outputs the `RegWEn` signal, connected to RegFile. Set as `1` to ensure we write `wdata` to `R[rd]`.
* Outputs `ALUSel` control signal, connected to ALU, which selects the ALU operation to output. Output an "add" or "sub" signal, depending on the instruction.
:::

How do we determine `add` or `sub`? Recall our discussion of [Design Decisions for R-Type](#tab-r-type): `add` and `sub` have the same `opcode` and `funct3` fields, but different `funct7` fields. Importantly, the `inst[30]` bit is `1` for `sub` and `0` for `add`.

## Building an R-Type processor

We can extend our reasoning above to build a processor that implements all [R-Type instructions](#tab-r-type):

* Build an ALU that supports all R-Type arithmetic and logic operations on operands `R[rs1]` and `R[rs2]`.
* Build a Control Logic block that use the instruction bits `inst` to select the appropriate ALU operations and set `ALUSel` accordingly.

(sec-datapath-alu)=
## Arithmetic Logic Unit (ALU)

We encourage revisiting this section after reading a few more example datapath traces.

In the [previous chapter](#sec-alu) we implemented a basic four-operation ALU. As shown in @fig-element-alu and @tab-alu-signals, the RISC-V ALU takes the same input and output, but the control signal `ALUSel` is much wider to accommodate the functionality needed for the full RISC-V datapath.

:::{figure} images/element-alu.png
:label: fig-element-alu
:width: 40%
ALU Block.

:::

:::{table} Signals for ALU Block
:label: tab-alu-signals
:align: center

| Name | Direction | Bit Width | Description |
| :-- | :-- | :-- | :-- |
| `A` | Input | 32  | Data to use for Input A in the ALU operation |
| `B` | Input | 32  | Data to use for Input B in the ALU operation |
| `ALUSel` | Input | 4 | Selects which operation the ALU should perform (see @tab-alu-operations) |
| `ALUResult` | Output | 32 | Result of the ALU operation |

:::

In the full RISC-V implementation, our ALU (@fig-element-alu) must perform arithmetic for many signals:

* Register-register arithmetic and logical operations for R-Type instructions
* Register-immediate arithmetic and logical operations for [I-Type](#sec-datapath-i-type) instructions
* Base + Immediate address computation for [loads and stores](#sec-datapath-load-store)
* PC-relative address computation (See datapath for [Branches](#sec-datapath-b-type) and [Jumps](#sec-datapath-jump))
* Upper immediate computation (see datapath for [U-Type](#sec-datapath-u-type))

### Course Project Details

Below, we detail the ALU operations that must be implemented for the **course project**'s datapath.

:::{warning} Course Project vs. RISC-V ISA

Note that the implementation of functional units like the ALU are **intentionally unspecified** in the ISA. In general, you cannot/should not expect all RISC-V architectures to follow any of the specifications in @tab-alu-signals, including but not limited to:

* The specified `ALUSel` values (e.g., that add has `ALUSel=0`)
* Support for general multiplication (not in the Base RV32I ISA)
* `bsel`, which is needed for our datapath's support for [U-Type](#sec-datapath-u-type).
:::

:::{table} Operations for ALU Block for the course project
:label: tab-alu-operations

| `ALUSel` Value <br/>(for Project) | Operation | ALU Function |
| :-- | :-- | :-- |
| 0  |  add   | `ALUResult = A + B` |
| 1  | sll    | `ALUResult = A << B[4:0]`|
| 2  | slt    | `ALUResult = (A < B (signed)) ? 1 : 0` |
| 3  | Unused | - |
| 4  | xor    | `ALUResult = A ^ B` |
| 5  | srl    | `ALUResult = (unsigned) A >> B[4:0]` |
| 6  | or     | `ALUResult = A \| B` |
| 7  | and    | `ALUResult = A & B` |
| 8  | mul    | `ALUResult = (signed) (A * B)[31:0]` |
| 9  | mulh   | `ALUResult = (signed) (A * B)[63:32]` |
| 10 | Unused | - |
| 11 | mulhu  | `ALUResult = (A * B)[63:32]` |
| 12 | sub    | `ALUResult = A - B` |
| 13 | sra    | `ALUResult = (signed) A >> B[4:0]` |
| 14 | Unused | - |
| 15 | bsel   | `ALUResult = B` |
::::

Observations/reminders:

* When performing shifts, only the lower 5 bits of `B` are needed, because only shifts of up to 32 are supported.
* The comparator component might be useful for implementing instructions that involve comparing inputs. See the [branch implementation](#sec-datapath-b-type) later in this chapter.
* A multiplexer (MUX) might be useful when deciding between operation outputs (recall our [basic 4-operation ALU](#sec-alu)). Consider first processing the input for **all** operations first, and then outputting the one of your choice.
* See general multiplication notes below.

(sec-general-multiplication)=
### General Multiplication

An ALU that implements the `mul`, `mulh`, and `mulhu` instructions can support parts of the [RISC-V "M" extension](https://docs.riscv.org/reference/isa/unpriv/m-st-ext.html).

| Instruction | Name | Description | Type | Opcode | Funct3 | Funct7 |
| :--- | :--- | :--- | :---: | :------ | :--- | :--- |
| `mul rd rs1 rs2` | MULtiply | `R[rd] = (R[rs1] * R[rs2])[31:0]` | R | `011 0011` | `000` | `000 0001` |
| `mulh rd rs1 rs2` | MULtiply Higher Bits | `R[rd] = (R[rs1] * R[rs2])[63:32]` (Signed) | R | `011 0011` | `0001` | `000 0001` |
| `mulhu rd rs1 rs2` | MULtiply Higher Bits (Unsigned) |  `R[rd] = (R[rs1] * R[rs2])[63:32]` (Unigned)  | R | `011 0011` | `011` | `000 0001` |

The result of multiplying 2 32-bit numbers can be up to 64 bits of information, but we're limited to 32-bit data lines, so `mulh` and `mulhu` are used to get the upper 32 bits of the product. The `Multiplier` component has a `Carry Out` output (with the description "the upper bits of the product") which might be particularly useful for certain multiply operations.
