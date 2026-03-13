---
title: "R-Type Datapath, ALU"
subtitle: "add, sub"
---

(sec-datapath-r-type)=
## Learning Outcomes

* Coming soon! We provide the animations for now.

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

## Tracing the `add` Datapath

<iframe src='https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-add.pptx' width='100%' height='600px' frameborder='0'>

## Arithmetic Logic Unit (ALU)

In the [previous chapter](#sec-alu) we implemented a basic four-operation ALU. In the full RISC-V implementation, our ALU (@fig-element-alu) must support all operations for R-Type instructions:

:::{figure} images/element-alu.png
:label: fig-element-alu
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

### Course Project Details

Below, we detail the ALU operations that must be implemented for the **course project**'s datapath. We encourage revisiting this section after reading a few more example datapath traces.

:::{table} Operations for ALU Block for the course project
:label: tab-alu-operations

| ALUSel Value <br/>(for Project) | Operation | ALU Function |
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

Observations/reminders:

* When performing shifts, only the lower 5 bits of `B` are needed, because only shifts of up to 32 are supported.
* The comparator component might be useful for implementing instructions that involve comparing inputs. See the [branch implementation](#sec-datapath-b-type) later in this chapter.
* A multiplexer (MUX) might be useful when deciding between operation outputs (recall our [basic 4-operation ALU](#sec-alu)). Consider first processing the input for **all** operations first, and then outputting the one of your choice.

:::{warning} @tab-alu-signals is not specified in the RISC-V ISA

Note that the implementation of functional units are **intentionally unspecified** in the ISA. In general, you cannot/should not expect all RISC-V architectures to follow any of the specifications in @tab-alu-signals, including but not limited to:

* The specified `ALUSel` values
* The operation names
* Supporting general multiplication (not in the Base RV32I ISA)
* bsel, which is needed for our course's RV32I datapath.

:::

(sec-general-multiplication)
### General Multiplication

An ALU that implements the `mul`, `mulh`, and `mulhu` instructions can support parts of the [RISC-V "M" extension](#https://docs.riscv.org/reference/isa/unpriv/m-st-ext.html).

| Instruction | Name | Description | Type | Opcode | Funct3 | Funct7 |
| :--- | :--- | :--- | :---: | :------ | :--- | :--- |
| `mul rd rs1 rs2` | MULtiply | `R[rd] = (R[rs1] * R[rs2])[31:0]` | R | `011 0011` | `000` | `000 0001` |
| `mulh rd rs1 rs2` | MULtiply Higher Bits | `R[rd] = (R[rs1] * R[rs2])[63:32]` (Signed) | R | `011 0011` | `0001` | `000 0001` |
| `mulhu rd rs1 rs2` | MULtiply Higher Bits (Unsigned) |  `R[rd] = (R[rs1] * R[rs2])[63:32]` (Unigned)  | R | `011 0011` | `011` | `000 0001` |

The result of multiplying 2 32-bit numbers can be up to 64 bits of information, but we're limited to 32-bit data lines, so `mulh` and `mulhu` are used to get the upper 32 bits of the product. The `Multiplier` component has a `Carry Out` output (with the description "the upper bits of the product") which might be particularly useful for certain multiply operations.


