---
title: "Structural Hazards"
---

(sec-structural-hazards)=
## Learning Outcomes

* Explain why the hardware requirements of the RISC-V pipeline do not cause structural hazards.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/71Mb1OjKwbs
:width: 100%
:title: "[CS61C FA20] Lecture 22.2 - Pipelining II: Pipeline Hazards"
:::

::::

From earlier:

:::{embed} #block-def-hazard-structural
:::

From P&H 4.6:

> A structural hazard in the laundry room would occur if we used a washer-dryer combination instead of a separate washer dryer. Our carefully scheduled pipeline plans would be foiled.
> 
> The RISC-V instruction set was designed to be pipelined, making it fairly easy for designers to avoid structural hazards when designing a pipeline.

In other words, in our current five-stage processor, **structural hazards are not an issue** unless changes are made to the pipeline. The structural hazards that _could_ exist are prevented by RV32I's hardware requirements.

Suppose we had the following five instructions simultaneously executing in our five-stage pipeline as in @fig-structural-pipeline.

:::{figure} images/structural-pipeline.png
:label: fig-structural-pipeline
:width: 70%
:alt: "Pipeline occupancy diagram with symbols for each of the five pipeline stages. Labels under the stages show five distinct instructions simultaneously in each of the IF, ID, EX, MEM, and WB stages. Instruction 1 is in the write-back stage, at the same time that instruction 2 is in the MEM stage, instruction 3 is in the EX stage, instruction 4 is in the ID stage, and instruction 5 is in the IF stage."

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
:alt: "Register file rectangular symbol showing wdata, rd, rs1, and rs2 inputs, control signal RegWEn, and outputs rdata1 and rdata2. This depicts the separate read and write access pattern avoiding structural conflicts."

RISC-V RegFile design
:::
:::::

:::::{grid-item}

:::{figure} images/regfile-structural-hazard.png
:label: fig-regfile-hazard
:width: 70%
:alt: "Alternate register-file block symbol with only wdata and rs inputs, the same RegWEn control signal, and one rdata output. This organization causes a read-write resource conflict if trying to read and write from the RegFile in the same cycle."

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
:alt: "On the left, a rectangular symbol for the IMEM with address input and instruction output. On the right, a rectangular symbol for the separate DMEM with address and wdata input, MemRW control signal, and rdata output. This separate memory design avoids instruction-data memory hazards."

RV32I IMEM and DMEM are two separate hardware units.
:::

In @fig-structural-pipeline, memory is accessed by `inst5` in the `IF` stage (to read an instruction from IMEM) and `inst2` in the `MEM` stage (to read data from DMEM). The separate IMEM and DMEM in @fig-separate-mem do not cause a structural hazard, because `inst5` and `inst2` can simultaneously access memory.

By contrast, if we used a single memory block called that could only support one read/write at a time (to any part of memory—instruction or data), then `inst5` and `inst2` attempting to access memory in the same cycle would cause a structural hazard.

We will discuss this later, but under the hood, IMEM and DMEM are actually caches of main memory, as shown in @fig-separate-onchip-mem. This design allows them to be much closer to the processor to keep memory access fast.

:::{figure} images/separate-onchip-mem.png
:label: fig-separate-onchip-mem
:width: 80%
:alt: "Processor-memory diagram showing distinct on-chip instruction and data memories connected separately to the processor datapath."

Processor and Memory diagram of separate IMEM/DMEM in memory.
:::
