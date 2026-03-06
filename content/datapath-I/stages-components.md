---
title: "phases and Components"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/8Dv725H2-Os
:width: 100%
:title: "[CS61C FA20] Lecture 18.2 - Single-Cycle CPU Datapath I: Building a RISC-V Processor"
:::

::::

(sec-single-cycle)=
## Single-Cycle Processor

From one perspective, a CPU is a state machine.

* [State elements](sec-elements): registers and memory
* Combinational Logic Blocks: [ALU](#sec-alu), other combinational logic, etc.

Our goal is to design a **single-cycle processor** that **executes one instruction each cycle**, starting from fetching the instruction all the way to updating the PC for the next instruction.

* During each clock cycle, the current outputs of the state elements _drive the inputs_ to combinational logic, whose outputs settle at the inputs to the state elements before the next rising clock edge.
* Then, at the **rising clock edge**, all the state elements are _updated_ with the combinational logic outputs, and execution moves to the next clock cycle.

## The Processor as a State Machine

Theoretically, to design our CPU we could implement something like @fig-monolithic-datapath. We could make a "finite" state machine that considers every instruction as a separate state, then specifies combinational logic for transitioning to every other possible instruction.

:::{figure} images/asdf.png
:label: fig-monolithic-datapath
:width: 100%
:alt: "TODO"

A strawman, bulky approach to implementing our datapath
:::

:::{warning} Problem: A single "monolithic" block would be bulky and inefficient

While we could theoretically build a separate "bubble" of combinational logic for every single instruction and use multiplexers to select between them, that is not practical because many instructions share the same data path.
:::

## 5 Steps in a Clock Cycle

Instead, we will break up the process into **five steps**, then connect the steps to create the whole processor circuit. For each instruction, we will determine whether additional logic needs to be incorporated into each phase.

The benefit of this approach is two-fold:

1. Smaller steps are easier to design
1. Modularity means that we can optimize one step without touching the others.

Here are the five steps in a single-cycle processor.

1. **Instruction Fetch (`IF`)**: Fetch the instruction from [memory](#sec-element-imem) and increment the [program counter](#sec-element-pc).
1. **Instruction Decode (`ID`)**: Determine the operation from the bits of the instruction and read registers from the [register file](#sec-element-regfile).
1. **Execute (`EX`)**: Use the [Arithmetic Logic Unit (ALU)](#sec-alu) to perform the operation.
1. **Memory Access (`MEM`)**: Load data from [memory](#sec-element-dmem), or store data[^mem-phase] to memory.
1. **Write Back (`WB`)**: Write back[^wb-phase] to the [register file](#sec-element-regfile).

All phases of one RV32I instruction will execute within the same cycle[^mem-phase][^wb-phase]: Instruction Fetch (`IF`) starts on the first rising edge of a clock, and Write Back (`WB`) finishes[^wb-phase] the final result on the next rising edge. Not all steps are needed for every instruction; we will see this very quickly with our [R-Type instructions](#sec-datapath-r-type).

[^mem-phase]: It is more accurate to say that during `MEM`, we setup the data to store back to `DMEM` by ensuring that the input to `DMEM` is stable before the next rising edge of the clock. Then, on the rising edge, `MEM` stores the correct value to memory. See more: [DMEM](#sec-element-dmem)

[^wb-phase]: It is more accurate to say that during `WB`, we set up the value to write back to the Register File by ensuring that the input D of register `rd` is stable at setup time, before the next rising edge of the clock. Then, on the rising edge, the register `rd` takes this value, then after a clk-to-q delay, has the correct value on its output Q. See more: [RegFile](#sec-element-regfile)

:::{warning} 5 Phases? 5 Stages?

You will see the literature refer to a "5-stage RISC-V pipeline." This refers to when we take up to five clock cycles to execute an instruction, one cycle for each of the 5 steps written above. We will discuss pipelined architecture later.

For now for our current single-cycle datapath approach and our later pipelined approach, we will use the term **phase** to refer to the five steps to executing an instruction. We will reserve the term **stage** for our later pipelined implementation.
:::

(sec-elements)=
## CPU State Elements

To implement this 

(sec-element-pc)=
### Program Counter

:::{figure} images/asdf.png
:label: fig-element-pc
:width: 100%
:alt: "TODO"

The Program Counter, `PC`, is a single 32-bit register in the CPU.
:::

(sec-element-regfile)=
### `RegFile`: Register File

:::{figure} images/asdf.png
:label: fig-element-regfile
:width: 100%
:alt: "TODO"

The Register File, `RegFile`, is symbolically written as `Reg[]` and houses registers `x0` to `x31`.
:::

For _read_ operations, the RegFile behaves like a combinational logic block. Reading registers therefore behaves like a combinational logic and are _not_ timed to the rising clock edge. This is a necessary assumption to ensure our single-cycle datapath executes all phases of an instruction within one cycle.

For _write_ operations, 


(sec-element-dmem)=
### `DMEM`: Data Memory

:::{figure} images/asdf.png
:label: fig-dmem-block
:width: 100%
:alt: "TODO"

The Data Memory block `DMEM`. Read operations behave like combinational logic, whereas write operations occur on the rising clock edge.
:::

Reading and writing to `DMEM`
For memory read operations, memory blocks (DMEM and IMEM) behave like combinational logic blocks.

(sec-element-imem)=
### `IMEM`: Instruction Memory

:::{figure} images/asdf.png
:label: fig-element-imem
:width: 100%
:alt: "TODO"

In our CPU, the Instruction Memory block `IMEM` is read-only and behaves like combinational logic.
:::

:::{warning} IMEM is not clocked!

In our CPU, we assume IMEM is a read-only state element and is **not clocked**. It therefore _always_ behaves like a combinational logic block.

:::
