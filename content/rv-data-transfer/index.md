---
title: "Load from, Store to"
---

## Learning Outcomes

* Remember the adage: Load _from_ memory, Store _to_ memory.
* Explain why an ISA needs to define instructions for accessing memory.

::::{note} 🎥 Lecture Video - Load from, Store to
:class: dropdown

:::{iframe} https://www.youtube.com/embed/wXGhuhLKkqg
:width: 100%
:title: "[CS61C FA20] Lecture 08.1 - RISC-V lw, sw, Decisions I: Storing in Memory"
:::

Until 7:33[^egg-test]. Beyond that, there is a useful review of endianness, which we have covered in an [earlier section](#sec-endianness).

[^egg-test]: This lecture video starts with an amusing egg test. I personally believe it will help you grasp the concepts of the P&H textbook, but I haven't tried it out yet.

::::

Because registers are scarce, it is important to be cautious and reuse them as temporary storage. Generally, it is the job of an optimizing compiler to minimize register footprint. However, when we work with larger amounts of data, we have to "spill" out of the registers and over to memory.

RISC-V defines instructions for accessing memory. 
Recall our basic computer layout (@fig-von-neumann). The processor communicates with memory by issuing **addresses** to read or write data:

* **Load from** memory: Reading data from the memory into the processor.
* **Store to** memory: Writing data from the processor to the memory.

:::{warning} Which "direction" for memory access?

As computer architects, our world is processor-centric–because that's where all the action happens. So the direction of this operation is with respct to the operation: load _from_, store _to_.

It is important to practice using the correct terminology; doing so will help you better internalize core concepts!
:::

## RISC-V is Load-Store

RISC-V is known as a [load-store architecture](https://en.wikipedia.org/wiki/Load%E2%80%93store_architecture)[^load-store]—referring to how it defines memory access and operations on data (@fig-rv-load-store).

:::{figure} images/load-store.png
:label: fig-rv-load-store
:width: 100%
:alt: "TODO"

Load and store between register and memory.
:::

RISC-V only permits operations on data in **registers**. Any operations on data from memory must involve multiple instructions:

1. **Load** in the data from memory into registers
2. **Execute** the operation on registers in the processor.
3. (if needed) **Store** the data back to memory.

[^load-store]: Other models exist, often in CISC land. The x86 ISA permits arithmetic operations where one operand is in memory and the other is in a register.

RISC-V defines a set of `load` and `store` instructions for moving data between memory and registers. Let's check these instructions out!
