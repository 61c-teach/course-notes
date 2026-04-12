---
title: "SIMD Architectures"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

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

:::{figure} images/simd-ext.png
:label: fig-simd-ext
:width: 65%
:alt: "TODO"

First SIMD Extensions: MIT Lincoln Labs TX-2, 1957.
:::

:::{figure} images/simd-vector-regs.png
:label: fig-simd-vec-regs
:width: 90%
:alt: "TODO"

SIMD Specialized *vector* registers.
:::

Consider @fig-simd-ops. Generally speaking, most of the speedup comes not from doing four math operations at a time, but instead from doing a **large memory load/store** at a time. Recall that memory operations take 3-200x more time than arithmetic operations. SIMD instructions use specialized **"vector" registers** which store 128, 256, or even 512 bits (e.g., @fig-simd-vec-regs).

## SIMD Instructions


:::{figure} images/simd-ops.png
:label: fig-simd-ops
:width: 100%
:alt: "TODO"

SIMD Operations: Fetch one instruction, perform multiple instructions.
:::

SIMD instructions act as extensions to a base instruction set, with different systems supporting different SIMD instructions.

Caveats: Each instruction needs its own circuitry, so we're limited to the set of instructions that came with the CPU. Large vectors require significant amounts of circuitry, so they are expensive to implement, and often have higher cycles/instruction than standard instructions

RISC-V doesn't have a standard vector library, so we're using x86's vector operators on hive machines.
In practice, this doesn't matter too much since arithmetic syntax works similarly to RISC-V, though other operations don't exist:

* There's still only one PC, so we can't vectorize branch or jump instructions.
* Since we only have limited instructions available, we can't do different math operations to vector components, and we can only easily load consecutive blocks of memory to a vector.

Again, most programs spend the majority of their time loading/storing instead of doing math, because loads and stores can take hundreds of cycles to resolve.

## Intel Intrinsics

In @tab-intrinsics-types, each type corresponds directly to a type of SIMD register (note that x86 has different sets of registers for floats, doubles, and integers).
Used similarly to variables, but directly are associated with available registers, so you can't just initialize a bunch of them (or an array of them)

:::{table} Intel Intrinsic Data Types.
:label: tab-intrinsics-types
| Type | Description |
| :--- | :--- | 
| `__m256` | 256 bit register for storing floats |
| `__m256d` | 256 bit register for storing doubles |
| `__m256i` | 256 bit register for storing 32-bit integers |
| `__m128`, `__m128d`, `__m128i` | 128 bit registers |
:::

## Intrinsics Instructions and Format

Generally of the format:
_<register size>_<instruction>_<component_type>
Ex. _mm256_add_epi32 adds two 256-bit vectors, treating the vectors as arrays of 32-bit integers.
Ex. _mm_load_ps loads 4 consecutive floats into a 128-bit register from the given memory address. The memory address must be aligned to a 16-byte boundary (loadu allows for nonaligned addresses, but is slower)
More instructions: https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html 
Looks like C functions, but programming with them feels more like assembly

## Common mistakes with SIMD instructions

* Trying to directly access a 32-bit chunk of a SIMD vector (such as through typecasting)
  * Need to do an explicit load/store, since registers are different from memory
* Trying to _mm_load or _mm_store with unaligned addresses
  * Use loadu or storeu if you must, or try to get your addresses aligned
* For mallocs, aligned_alloc gives you an aligned address
  * For local variables, you can set an attribute.
* Forgetting the tail case
  * If your data isn't an array whose length is a multiple of your vector size, you need to handle the last iterations of your dataset one-by-one instead of 4 at a time.
* Using too many vectors (or creating a large array of vectors)
  * Ends up throttling your code because the compiler ends up trying load/store SIMD vectors to the stack a bunch of times.
