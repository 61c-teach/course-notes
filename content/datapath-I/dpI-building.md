---
title: "Stages and Components"
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



<iframe src='https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/ff68145d7c105b9f383e16a85cb1c9b5da5846b3/content/resources/datapath-add.pptx' width='100%' height='600px' frameborder='0'>


From one view, designing a CPU is like designing a state machine.

* State elements: registers and memory
* Combinational Logic Blocks: ALU, other combinational logic, etc.

Our goal is to design a **single-cycle processor**. The processor will **execute one instruction each cycle**, starting from fetching the instruction all the way to updating the PC for the next clock cycle.

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

:::{tip} Solution: Design a 5-stage processor

Instead, we will break up the process into **five stages**, then connect the stages to create the whole datapath. For each instruction, we will determine whether additional logic needs to be incorporated into each stage.

The benefit of this approach is two-fold:

1. Smaller stages are easier to design
1. Modularity means that we can optimize one stage without touching the others.

:::

## 5 Stages of Execution
To implement a single-cycle processor, we design our processor to have five stages:

1. **Instruction Fetch (`IF`)**: Fetch the instruction from [memory](#sec-element-imem) and increment the [program counter](#sec-element-pc).
1. **Instruction Decode (`ID`)**: Determine the operation from the bits of the instruction and read registers from the [register file](#sec-element-regfile).
1. **Execute (`EX`)**: Use the [Arithmetic Logic Unit (ALU)](#sec-alu) to perform the operation.
1. **Memory Access (`MEM`)**: Load data from [memory](#sec-element-dmem), or store data[^mem-stage] to memory.
1. **Write Back (`WB`)**: Write back[^wb-stage] to the [register file](#sec-element-regfile).

All stages of one RV32I instruction will execute within the same cycle[^mem-stage][^wb-stage]: Instruction Fetch (`IF`) starts on the first rising edge of a clock, and Write Back (`WB`) finishes[^wb-stage] the final result on the next rising edge.

[^mem-stage]: It is more accurate to say that during `MEM`, we setup the data to store back to `DMEM` by ensuring that the input to `DMEM` is stable before the next rising edge of the clock. Then, on the rising edge, `MEM` stores the correct value to memory. See more: [DMEM](#sec-element-dmem)

[^wb-stage]: It is more accurate to say that during `WB`, we set up the value to write back to the Register File by ensuring that the input D of register `rd` is stable at setup time, before the next rising edge of the clock. Then, on the rising edge, the register `rd` takes this value, then after a clk-to-q delay, has the correct value on its output Q. See more: [RegFile](#sec-element-regfile)

## CPU State Elements

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

:::{warning} Read operations in RegFile
For read operations, the RegFile behaves like a combinational logic block.
:::

(sec-element-dmem)=
### `DMEM`: Data Memory

:::{figure} images/asdf.png
:label: fig-dmem-block
:width: 100%
:alt: "TODO"

The Data Memory block `DMEM`. Read operations behave like combinational logic, whereas write operations occur on the rising clock edge.
:::

:::{warning} Read operations in Memory
For read operations, memory blocks (DMEM and IMEM) behave like combinational logic blocks.
:::

(sec-element-imem)=
### `IMEM`: Instruction Memory

:::{figure} images/asdf.png
:label: fig-element-imem
:width: 100%
:alt: "TODO"

In our CPU, the Instruction Memory block `IMEM` is read-only and behaves like combinational logic.
:::

:::{warning} IMEM is not clocked

In our CPU, we assume IMEM is read-only and is **not clocked**. It therefore _always_ behaves like a combinational logic block. This is a necessary abstraction to ensure our single-cycle datapath executes all stages of an instruction within one cycle. Take EECS 151 for a more detailed approach.

:::
