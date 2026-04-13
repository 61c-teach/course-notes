---
title: "SIMD Architectures"
subtitle: Coming soon! Thanks for your patience.
---

<!-- ## Learning Outcomes

* TODO
* TODO -->

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/pSkO2Fi9Q0o
:width: 100%
:title: "[CS61C FA20] Lecture 32.4 - Flynn Taxonomy, SIMD Instructions: SIMD Architectures"
:::

::::

In this section we discuss **SIMD instructions** (Single-Instruction, Multiple Data), sometimes known as **vector instructions**. Instead of doing math on one number at a time, SIMD instructions instead do math on several numbers at a time, in a single clock cycle.

:::{figure} images/simd-arch.png
:label: fig-SIMD-arch
:width: 90%
:alt: "TODO"

SIMD: Single Instruction, Multiple Data Architecture.
:::

:::{figure} images/simd-vector-regs.png
:label: fig-simd-vec-regs
:width: 90%
:alt: "TODO"

SIMD Specialized *vector* registers.
:::

Consider @fig-simd-ops. Generally speaking, most of the speedup comes not from doing four math operations at a time, but instead from doing a **large memory load/store** at a time. Recall that memory operations take 3-200x more time than arithmetic operations. SIMD instructions use specialized **"vector" registers** which store 128, 256, or even 512 bits (e.g., @fig-simd-vec-regs).

:::{figure} images/simd-ops.png
:label: fig-simd-ops
:width: 100%
:alt: "TODO"

SIMD Operations: Fetch one instruction, perform multiple instructions.
:::

<!-- :::{figure} images/simd-ext.png
:label: fig-simd-ext
:width: 65%
:alt: "TODO"

First SIMD Extensions: MIT Lincoln Labs TX-2, 1957.
:::

SIMD instructions act as extensions to a base instruction set, with different systems supporting different SIMD instructions.

Caveats: Each instruction needs its own circuitry, so we're limited to the set of instructions that came with the CPU. Large vectors require significant amounts of circuitry, so they are expensive to implement, and often have higher cycles/instruction than standard instructions

RISC-V doesn't have a standard vector library, so we're using x86's vector operators on hive machines.
In practice, this doesn't matter too much since arithmetic syntax works similarly to RISC-V, though other operations don't exist:

* There's still only one PC, so we can't vectorize branch or jump instructions.
* Since we only have limited instructions available, we can't do different math operations to vector components, and we can only easily load consecutive blocks of memory to a vector.

Again, most programs spend the majority of their time loading/storing instead of doing math, because loads and stores can take hundreds of cycles to resolve. -->