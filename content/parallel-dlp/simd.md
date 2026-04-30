---
title: "SIMD Architectures"
---

(sec-simd)=
## Learning Outcomes

* Explain how element-wise vector addition and element-wise vector multiplication are SIMD operations.
* Understand that SIMD ISAs are extensions of base integer/floating-point ISAs.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/pSkO2Fi9Q0o
:width: 100%
:title: "[CS61C FA20] Lecture 32.4 - Flynn Taxonomy, SIMD Instructions: SIMD Architectures"
:::

::::

In this section we discuss **SIMD instructions** (Single-Instruction, Multiple Data), sometimes known as **vector instructions**. While we will not build a SIMD architecture, we will see how a programmer can use a SIMD architecture to improve performance.

## Data-Level Parallelism

SIMD architectures exploit **Data-Level Parallelism** (DLP) with simultaneous operation on multiple data streams. Instead of doing math on one number at a time, SIMD instructions instead do math on several numbers at a time, in a single clock cycle.

**SIMD Addition**: @fig-simd-add compares SIMD addition to scalar addition. On the scalar side, we fetch one `add` instruction and apply it to one pair of operands, `A` and `B`. On the SIMD side, we do a **vector add**: we stil fetch one `add` instruction, but now we perform vector addition, element by element, for both of the vectors `A` and `B`. For the eight-element **vectors** in @fig-simd-add, vector addition therefore performs *one* addition ("single instruction") on *eight* pairs of operands ("multiple data") .

:::{figure} images/simd-add.png
:label: fig-simd-add
:width: 90%
:alt: "Side-by-side comparison of SIMD versus scalar addition. Left: eight parallel lanes drawn as paired segments so one add instruction updates eight independent sums at once. Right: a single add operates on one A and one B operand producing one result. Labels and lane groupings make clear that SIMD amortizes decode and issue cost across many data elements while scalar issues one result per instruction."

(left) SIMD addition; (right) Scalar addition.
:::

**SIMD multiplication**: A common vector operation is to multiply some coefficient vector `c` by some data vector `x`, element-wise. While this can be accomplished in scalar mode with loops (@fig-simd-mul), vector multiplication would again load in one multiplication and apply it to multiple pairs of operands within vectors.

:::{figure} images/simd-mul.png
:label: fig-simd-mul
:width: 90%
:alt: "Upper portion: short code snippets in Python, C, and Snap! illustrating vectorized multiply idioms. Lower portion: schematic with four side-by-side operand lanes feeding element-wise multiplies that merge into one four-wide result register block. The juxtaposition highlights that one vectorized multiply maps to multiple scalar products executed together."

(left) SIMD multiplication; (right) Scalar multiplication.
:::

:::{note} SIMD performance improvement

* Instead of fetching and decoding the same instruction multiple times, we fetch and decode the instruction just once.
* Vector operations (e.g., element-wise addition, element-wise multiplication) are independent between different data streams. In @fig-simd-mul, the outcome of multiplying one pair of operands will not impact the outcome of multiplying another pair of operands within the same vector.
* Pipelining/concurrency in memory access due to spatial locality. We can load in one block of data from the memory hierarchy, operate on the block in parallel, and then store the block back to memory hierarchy all at once.

:::

## SIMD Architecture History

Vector architectures and SIMD architectures[^vector-vs-simd] have existed for a long time. The first noted SIMD machine was the TX-2 at MIT Lincoln Lab in 1957. The TX-2 had the ability to run full 36-bit-wide data, split it into two 17-bit operands, or split it into four nine-bit operands.[^bits]

[^vector-vs-simd]: SIMD architectures and vector architectures are different, but the distinction is beyond the scope of this course. For those curious, most modern vector architectures support a "reduce-add" operation, which sums the elements of a vector together to a scalar result. SIMD architectures do not support such scalar result operations. From [Wikipedia](https://en.wikipedia.org/wiki/Vector_processor): "Pure (fixed-width, no predication) SIMD is often mistakenly claimed to be 'vector' (because SIMD processes data which happens to be vectors)."

[^bits]: Remember, standardized bytes/words wasn't around back then.

:::::{grid} 2
::::{grid-item}
:::{figure} images/simd-ext.png
:label: fig-simd-ext
:width: 100%
:alt: "Composite slide with a horizontal timeline of early SIMD-related systems (including MIT Lincoln Lab TX-2 milestones) beside a small table summarizing register widths or intrinsic register families coexisting with those systems. Timeline ticks and table headers are legible enough to convey chronological progression next to hardware capabilities."

First SIMD Extensions: MIT Lincoln Labs TX-2, 1957.
:::
::::

::::{grid-item}
:::{figure} images/simd-tx2.png
:label: fig-simd-tx2
:width: 100%
:alt: "Black-and-white photograph of the TX-2 memory-bank hardware at MIT Lincoln Laboratory: rows of cabinet frames, wiring bundles, and indicator hardware typical of late-1950s machines. The image grounds the historical discussion of early partitioned arithmetic in real physical equipment."

Memory Bank of the TX-2 Computer. MIT Lincoln Lab. [source](https://www.billbuxton.com/Lincoln.html)
:::
::::
:::::

(sec-simd-intel)=
## Intel SIMD Architectures

SIMD architectures saw wide commercial use when they were introduced on Intel computers in the late 1990s.[^intel] At the time, more consumers were running more multimedia applications on PCs[^pc]. These audio and video applications necessitated media applications, which typically involves one-dimensional vectors or two-dimensional matrices.

As a result, SIMD architectures were implemented that performed operations like those in @fig-simd-ops. These operations would have two source operands in wide registers, apply the operation to these wide registers, then write the result to a destination wide register.

[^pc]: Personal Computers, not program counters.

[^intel]: See: Intel [Advanced Digtal Media Boost](https://intelmicrotech.blogspot.com/2009/11/intel-advanced-digital-media-boost.html) from 2009.

:::{figure} images/simd-ops.png
:label: fig-simd-ops
:width: 100%
:alt: "Block diagram of a SIMD arithmetic instruction with four parallel lanes. Two source SIMD registers are labeled X3 through X0 and Y3 through Y0; each lane feeds a dedicated operator bubble (add, multiply, or other OP) drawn beneath the sources. A destination SIMD register on the right collects lane outputs X3 OP Y3 through X0 OP Y0, emphasizing identical opcode semantics across lanes."

SIMD operands: two source SIMD register operands, one destination SIMD register. If the source registers pack four values of equal width, then the destination register similarly packs four values of the same width.
:::

(sec-simd-intel-isa)=
### Intel SIMD ISAs

Intel SIMD instruction set architectures (ISAs) are **extensions** to the base Intel x86/x87 architecture. The naming of Intel SIMD extensions has changed with functionality. Every few years, there are new instructions, wider registers, and more parallelism.

@fig-intel-evolution shows different Intel SIMD ISAs over time.

* MMX (Multimedia Extension) was the first SIMD extension on 64-bit registers in Intel's Pentium 2 Processor (1997).
* SSE (Streaming SIMD Extension) uses 128-bit registers and first appeared in Pentium 3 and 4 (1999-2000).
* AVX (Advanced Vector Extension) uses 256-bit registers and first appeared in 2011.
* AVX-512 uses 512-bit registers and is found in the most recent Intel processors.

:::{figure} images/intel-evolution.png
:label: fig-intel-evolution
:width: 90%
:alt: "Horizontal timeline of Intel SIMD ISA generations from MMX (1997, 64-bit multimedia registers) through SSE family (128-bit XMM), AVX and AVX2 (256-bit YMM), toward AVX-512 (512-bit ZMM) on recent cores. Tick marks or callouts note wider vectors and added instruction groups while emphasizing that newer CPUs retain decoding for older SIMD opcodes for backward compatibility."

Intel x86 SIMD Evolution: SIMD extensions on top of x86 and x87 ([floating point](https://en.wikipedia.org/wiki/X87)).
:::

All Intel processors are backwards compatible, so even older SIMD extensions like MMX are still around with us. We will see how this complicates documentation for [Intel intrinsics](#sec-intrinsics).