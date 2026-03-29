---
title: "Load Data Hazard"
subtitle: Coming soon. Watch video for now!
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/VWCAqieFkHI
:width: 100%
:title: "[CS61C FA20] Lecture 23.1 - Pipelining III: Load Data Hazard"
:::

::::

## Visuals

:::{figure} images/load-hazard-q.png
:label: fig-load-hazard-q
:width: 100%
:alt: "TODO"

Waterfall diagram: Which data hazards can forwarding fix?
:::

:::{figure} images/load-hazard-ans.png
:label: fig-load-hazard-ans
:width: 100%
:alt: "TODO"

Waterfall diagram: Forwarding can fix EX $\rightarrow$ EX and MEM $\rightarrow$ EX data hazards.
:::

:::{figure} images/load-hazard-prob-mem.png
:label: fig-load-hazard-mem
:width: 100%
:alt: "TODO"

Waterfall diagram: Forwarding **cannot** fix MEM $\rightarrow$ EX for `lw`.
:::

:::{figure} images/load-delay-slot.png
:label: fig-load-delay-slot
:width: 100%
:alt: "TODO"

Waterfall diagram with **load delay slot** after a load instruction.
:::

:::{figure} images/code-scheduling.png
:label: fig-simple-compilation
:width: 100%
:alt: "TODO"

Simple compilation for 7 instructions (9 clock cycles).
:::

:::{figure} images/code-scheduling-sol.png
:label: fig-code-scheduling
:width: 100%
:alt: "TODO"

Code compilation with **code scheduling** for 7 instructions (7 clock cycles).
:::


**Data hazards** are caused by data dependencies between instructions. In CS 61C, where we always
assume that instructions go through the processor in order, data hazards occur when an instruction reads a register before a previous instruction has finished writing to the same register.
Data hazards occur between different stages. Some examples are:

* **EX-ID:** This hazard exists because the output from the execute stage is not written back to the
RegFile until the writeback stage, yet it can be requested by the subsequent instruction during
the decode stage.
* **MEM-ID:** This hazard exists because the output from the memory access stage is not written
back to the RegFile until the writeback stage, but it can still be requested from the decode stage—just like in EX-ID.

To account for reads and writes to the same register, some processors write to the register
during the first half of the clock cycle and read from it during the second half. This is implemented as a **write-then-read** RegFile, where data is transferred along buses at double the rate by using both the rising and falling clock edges within a single clock cycle. With write-then-read, we can reduce the number of stalls needed for data hazards by one.