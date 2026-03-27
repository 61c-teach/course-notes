---
title: "Structural Hazards"
subtitle: Coming soon. Watch video for now!
---

(sec-pipeline-hazards)=
## Learning Outcomes

* Identify the three types of hazards encountered in the RISC-V pipeline.
* Explain why the hardware requirements of the RISC-V pipeline do not cause structural hazards.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/71Mb1OjKwbs
:width: 100%
:title: "[CS61C FA20] Lecture 22.2 - Pipelining II: Pipeline Hazards"
:::

::::

One of the costs of pipelining is that it introduces **pipeline hazards**. A pipeline hazard, or simply **hazard**, is a situation in which a planned instruction cannot execute in the “proper” clock cycle. In other words, a hazard is when executing a combination of instructions would be impossible or would lead to incorrect program execution.

## Introduction to Hazards

There are three types of hazards:

+++ {"label": "block-def-hazard-structural"}
**Structural hazard**: The hardware in the processor cannot support the combination of instructions that we want to execute in the same clock cycle.
+++ {"label": "block-def-hazard-data"}
**Data hazard**: Instructions have data dependencies, and some instructions must wait for previous instructions to complete—otherwise outdated values would be used in computation.
+++ {"label": "block-def-hazard-control"}
**Control hazard**: The flow of execution depends on previous instructions. The wrong instructions are executed.
+++

In this unit, we describe each type of hazard and resolve hazards through various solutions in hardware, during execution time, or in the program code:

* **Stalling** is one inefficient solution to resolving any type of hazard, where we delay instructions until we can execute them without incurring hazards. Because performance suffers with stalling, we will discuss ways to avoid stalling where possible (though it is always a good last resort). See [this section](#sec-data-stall).
* Specify **hardware requirements**, i.e., on specific hardware units within the pipeline.
* **Forwarding**, also known as bypassing, is when we wire more connections in the datapath and instead use results when computed. See [this section](#sec-data-forward).
* **Code scheduling**, where we rearrange instructions at compile-time to avoid hazards.

In practice, computers use a combination of the above techniques to maximize throughput and maintain the benefits of **instruction-level parallelism** that pipelining provides.

## Structural Hazards

Structural hazards are about the **hardware**, not the instruction. From P&H 4.6:

> A structural hazard in the laundry room would occur if we used a washer-dryer combination instead of a separate washer dryer. Our carefully scheduled pipeline plans would be foiled.
> 
> The RISC-V instruction set was designed to be pipelined, making it fairly easy for designers to avoid structural hazards when designing a pipeline.

In other words, in our current five-stage processor, **structural hazards are not an issue** unless changes are made to the pipeline. The structural hazards that _could_ exist are prevented by RV32I's hardware requirements.

Suppose we had the following five instructions simultaneously executing in our five-stage pipeline as in @fig-structural-pipeline.

:::{figure} images/structural-pipeline.png
:label: fig-structural-pipeline
:width: 70%
:alt: "TODO"

The five instructions `inst1`, `inst2`, `inst3`, `inst4`, `inst5` are executing in order and occupying all five stages of our pipeline in the same clock cycle.
:::

If we changed the major hardware components of our pipeline, how might these changes result in structural hazards?

### RegFile

The [register file](#sec-element-regfile) (RegFile) used in our processor supports simultaneous read and write by two different instructions.

::::::{grid} 2

:::::{grid-item}

:::{figure} images/regfile-no-structural-hazard.png
:label: fig-regfile-no-hazard
:width: 70%
:alt: "TODO"

RISC-V RegFile design
:::
:::::

:::::{grid-item}

:::{figure} images/regfile-structural-hazard.png
:label: fig-regfile-hazard
:width: 70%
:alt: "TODO"

Alternate RegFile design
:::
:::::
::::::
<!-- grid -->

In @fig-structural-pipeline, the register file is accessed simultaneously by `inst4` in the `ID` stage (to read two registers), and `inst1` in the `WB` stage (to write to a register). The RV32I RegFile design in @fig-regfile-no-hazard means that `inst1` and `inst4` can simultaneously perform write and read, respectively, to the RegFile without causing a structural hazard.

By contrast, the alternate RegFile design in @fig-regfile-hazard can cause structural hazards. `RegWEn` specifies if the RegFile will be used for reading or writing in this cycle, and the port `rs` specifies the 5-bit-wide register value to use for either reading or writing. However, this RegFile design does not support simultaneous read/write, and therefore trying to execute `inst1` and `inst4` in the same cycle will cause a structural hazard.

### Memory

The [instruction memory](#sec-element-imem) (IMEM) and [data memory](#sec-element-dmem) (DMEM) used in our processor are separate hardware elements.

:::{figure} images/separate-mem.png
:label: fig-separate-mem
:width: 60%
:alt: "TODO"

RV32I IMEM and DMEM are two separate hardware units.
:::

In @fig-structural-pipeline, memory is accessed by `inst5` in the `IF` stage (to read an instruction from IMEM) and `inst2` in the `MEM` stage (to read data from DMEM). The separate IMEM and DMEM in @fig-separate-mem do not cause a structural hazard, because `inst5` and `inst2` can simultaneously access memory.

By contrast, if we used a single memory block called that could only support one read/write at a time (to any part of memory—instruction or data), then `inst5` and `inst2` attempting to access memory in the same cycle would cause a structural hazard.

We will discuss this later, but under the hood, IMEM and DMEM are actually caches of main memory, as shown in @fig-separate-onchip-mem. This design allows them to be much closer to the processor to keep memory access fast.

:::{figure} images/separate-onchip-mem.png
:label: fig-separate-onchip-mem
:width: 80%
:alt: "TODO"

Processor and Memory diagram of separate IMEM/DMEM in memory.
:::