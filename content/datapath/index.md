---
title: "Introduction"
subtitle: "Datapath vs. Control; 5 Steps to a RISC-V Instruction"
---

(sec-single-cycle)=
## Learning Outcomes

* Identify the five steps to executing a RISC-V instruction.
* Explain that the processor datapath describes the flow of data between state elements of the processor.
* Explain that the processor control describes the signals needed to ensure the datapath operations correctly execute the instructions.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/YAMqWaTZy8k
:width: 100%
:title: "[CS61C FA20] Lecture 18.1 - Single-Cycle CPU Datapath I: RISC-V Processor Design"
:::

::::

In this chapter, we will design a RISC-V processor and connect the software and hardware parts of our CS 61C story. In the [below figure](#fig-great-idea-1), this chapter designs the hardware that can actually execute RISC-V code. 

:::{figure} #fig-great-idea-1
:width: 100%
:enumerated: false
:alt: "TODO"

Great Idea #1: Abstraction.
:::

There are **many** such variations of RISC-V processor hardware; we will discuss one such processor this chapter, and a second one soon. There are many other designs of RISC-V chips on the market[^sifive]. Ultimately, _all RISC-V processors must correctly execute RISC-V instructions_. Let's see how!

[^sifive]: See [SiFive](https://www.sifive.com/boards/hifive-premier-p550) for some additional examples.

:::{hint} Hardware descriptions are inherently parallel

Before we continue, remember that we emphasize parallelism in this course. Even at the hardware level, all gates operate in parallel, and state elements are all synchronized to the same clock. This means that these functional units are all operating in parallel!

:::

:::{figure} ../great-ideas/images/new-school-machine-structures.png
:width: 100%
:enumerated: false
:alt: "TODO"
:label: #fig-great-idea-new-school

"New-School" Machine Structures leverage parallelism in both software and hardware.
:::

If we execute a single instruction on a single clock cycle, combinational logic blocks might be operating on garbage until they get the right values from state elements, and we will often need to wait until the end of the clock cycle before we can guarantee stable values for the next instruction. In the next chapter, we will discuss pipelining, which lets us execute multiple instructions in parallel.

## Datapath vs. Control

To build a processor, recall the basic computer layout below. The processor on the left of the figure is the active part of the computer that does all the work. It accesses memory to read/write data, it executes instructions, and it makes decisions on which instruction to execute next.

:::{figure} #fig-von-neumann
:width: 100%
:alt: "TODO"
:enumerated: false

Basic computer layout from a [previous chapter](#sec-architecture-elements).
:::

Inside the processor, there are two main components:

* **Datapath** ("the brawn"): The portion of the processor that contains the hardware necessary to perform operations required by the processor. The RISC-V datapath describes the flow of data between core elements of the RISC-V processor.
* **Control** ("the brain"): The portion of the processor (also in hardware) that tells the datapath what needs to be done. The control describes the signals needed to ensure the elements of the datapath correctly execute a RISC-V instruction.

:::{warning} Datapath vs. Control

Control and Datapath are two _abstractions_ that together comprise the CPU. Under the hood, both are designed with combinational logic and state elements.
:::

One analogy comes from the operation of the [International Space Station](https://en.wikipedia.org/wiki/International_Space_Station) (ISS). The space station is like the datapath that has all the hardware needed to perform operations in space. Mission control is on the Earth and, given some data from the space station, sends directions back to the ISS. Both the space station and mission control have computers (e.g., combinational logic) and state, and both are needed to ensure correct operation of the International Space Station as a system.

:::::{grid} 2
::::{grid-item}
:::{figure} images/space-iss.jpg
:enumerated: false
:width: 50%
The RISC-V datapath is like a space station.
:::
::::

::::{grid-item}
:::{figure} images/space-mission-control.jpg
:width: 50%
:enumerated: false
The RISC-V control logic is like mission control.
:::
::::
:::::

## Single-Cycle Processor

A CPU is a complex digital logic system that updates state using combinational logic. It has two types of elements (discussed in the [next section](#sec-state-elements)):

* [State elements](#sec-state-elements) that contain state, e.g., registers, memory, etc.
* Combinational Logic Blocks that operate on data values, e.g., [ALU](#sec-alu), [muxes](#sec-mux), combinational logic, etc.

Our goal for this chapter is to design a **single-cycle processor** that **executes one instruction each cycle**, starting from fetching the instruction all the way to updating the PC for the next instruction.

* During each clock cycle, the current outputs of the state elements _drive the inputs_ to combinational logic, whose outputs settle at the inputs to the state elements before the next rising clock edge.
* Then, at the **rising clock edge**, all the state elements are _updated_ with the combinational logic outputs, and execution moves to the next clock cycle.

### The Processor as a State Machine?

Theoretically, to design our CPU we could implement something like @fig-monolithic-datapath. We could make a "finite" state machine that considers every instruction as a separate state, then specifies combinational logic for transitioning to every other possible instruction.

:::{figure} images/monolithic-datapath.png
:label: fig-monolithic-datapath
:width: 50%
:alt: "TODO"

A strawman, bulky approach to implementing our datapath. We discuss the state elements listed in the figure in the [next section](#sec-state-elements).
:::

:::{warning} Problem: A single "monolithic" block would be bulky and inefficient

While we could theoretically build a separate "bubble" of combinational logic for every single instruction and use multiplexers to select between them, that is not practical because many instructions share the same data path.
:::

(sec-five-steps)=
## 5 Steps to a RISC-V Instruction

Instead of the complicated FSM approach above, we will break up the process into **five steps**, then connect the steps to create the whole processor circuit. For each instruction, we will determine whether additional logic needs to be incorporated into each phase.

The benefit of this approach is two-fold:

1. Smaller steps are easier to design
1. Modularity means that we can optimize one step without touching the others.

Here are the five steps to executing a RISC-V instruction.

1. **Instruction Fetch (`IF`)**: Fetch the instruction from [memory](#sec-element-imem) and increment the [program counter](#sec-element-pc).
1. **Instruction Decode (`ID`)**: Determine the operation from the bits of the instruction and read registers from the [register file](#sec-element-regfile).
1. **Execute (`EX`)**: Use the [Arithmetic Logic Unit (ALU)](#sec-alu) to perform the operation.
1. **Memory Access (`MEM`)**: Load data from [memory](#sec-element-dmem), or store data[^mem-phase] to memory.
1. **Write Back (`WB`)**: Write back[^wb-phase] to the [register file](#sec-element-regfile).

All phases of one RV32I instruction will execute within the same cycle[^mem-phase][^wb-phase]: Instruction Fetch (`IF`) starts on the first rising edge of a clock, and Write Back (`WB`) finishes[^wb-phase] the final result on the next rising edge.

:::{warning} Not all steps are needed for every instruction!

For example, our [R-Type instructions](#sec-datapath-r-type), does not need memory access, and [stores](#sec-datapath-load-store) do not need to write back to the register file. Nevertheless, across the different RISC-V instruction formats, the actions are largely the same, regardless of the exact instruction. From P&H 4.1:

> The simplicity and regularity of the RISC-V instruction set simplify the implementation by making the execution of many of the instruction classes similar.

:::

[^mem-phase]: It is more accurate to say that during `MEM`, we setup the data to store back to `DMEM` by ensuring that the input to `DMEM` is stable before the next rising edge of the clock. Then, on the rising edge, `MEM` stores the correct value to memory. See more: [DMEM](#sec-element-dmem)

[^wb-phase]: It is more accurate to say that during `WB`, we set up the value to write back to the Register File by ensuring that the input D of register `rd` is stable at setup time, before the next rising edge of the clock. Then, on the rising edge, the register `rd` takes this value, then after a clk-to-q delay, has the correct value on its output Q. See more: [RegFile](#sec-element-regfile)

In the next section, we introduce the key elements of a RISC-V **datapath**. For now, we share @fig-five-step-single-cycle-datapath and let you guess at the meaning of each hardware block.

:::{figure} images/five-step-single-cycle-datapath.png
:label: fig-five-step-single-cycle-datapath

Five steps of a single-cycle datapath. See [this section](#sec-state-elements) for descriptions of each hardware block.
:::

We emphasize the layer of abstraction between datapath and control with @fig-five-step-single-cycle-control below. The The control logic selects "needed" datapath lines based on the instruction. The control logic specifies if data needs to be written to memory or registers, which arithmetic or logical operation to execute, selectors for MUXes, etc.

:::{figure} images/five-step-single-cycle-control.png
:label: fig-five-step-single-cycle-control

As the datapath computes values, the control logic selects the necessary values needed to execute the instruction.
:::

:::{warning} 5 Phases? 5 Stages?

For now for our current single-cycle datapath approach, we will use the term **phase** to refer to each of the five steps to execute an instruction within a single clock cycle.

You will see the literature refer to a "5-stage RISC-V pipeline." In our class, we reserve the term **stage** to refer to a step in a **pipelined architecture**, where an instruction takes up to five clock cycles to execute, one cycle per step. We discuss this later.

:::

Finally, it should be noted that this single-cycle approach is not practical, since the clock cycle must stretch to accommodate the longest instruction that takes all five steps. After designing the single-cycle datapath, we will look at faster implementations that leverage **pipelining**.
