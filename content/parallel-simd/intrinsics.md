---
title: "Intel Intrinsics"
subtitle: Coming soon! Thanks for your patience.
---

(sec-intrinsics)=
## Learning Outcomes

<!-- * TODO
* TODO -->

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/MHIrM4VFzBk
:width: 100%
:title: "[CS61C FA20] Lecture 32.5 - Flynn Taxonomy, SIMD Instructions: SIMD Array Processing"
:::

::::


<!-- :::{figure} images/avx-simd.png
:label: fig-avx-simd
:width: 90%
:alt: "TODO"

AVX SIMD Data Types and Registers.
:::

:::{figure} images/intel-inst.png
:label: fig-intel-inst
:width: 90%
:alt: "TODO"

Intel Instructions and Formats.
:::

:::{table} Example SIMD Operations with Intel Intrinsics
:label: tab-simd-intel

| SIMD Pseudocode | Intel Intrinsic (SSE or AVX) | Description |
| :--- | :--- | :--- |
| `vector vec_load(int31_t *A);` | `__m128i _mm_loadu_si128(__m128i *p)` | Loads four integers at memory address A into a vector. | 
| `void vec_store(int32_t *dst, vector src);` | `void _mm_storeu_si128(__m128i *p, __m128i a)` | Stores `src` to `dst`. |
| `vector vec_setnum(int32_t num);` | n/a | Creates a vector where every element is equal to `num`. |
| `vec_setnum(0);` | `__m128i _mm_setzero_si128()` | Creates a vector with all elements set to zero. |
| `vec_setnum(*p);` | `__m256d _mm256_broadcast_sd(double const *p)` | Creates a vector with all elements set to double (from memory). |
| `vector vec_add(vector A, vector B);` | `__m128i _mm_add_epi32(__m128i a, __m128i b)` | Returns the result of adding A and B element-wise. |

:::

:::{figure} images/intel-evolution.png
:label: fig-intel-evo
:width: 90%
:alt: "TODO"

Intel x86 SIMD Evolution.
:::

:::{figure} images/avx-simd-regs.png
:label: fig-avx-simd-regs
:width: 65%
:alt: "TODO"

AVX SIMD Registers.
:::



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



## Visuals

:::{table} SIMD `dgemm` benchmark GFLOPS Comparison
:label: tab-dgemm-benchmark

| N | Python (GFLOPs) | C (scalar GFLOPs) | C + AVX (GFLOPs) |
| :--- | :--- | :--- | :--- |
| 32 | 0.0054 | 1.30 | 4.56 |
| 160 | 0.0055 | 1.30 | 5.47 |
| 480 | 0.0054 | 1.32 | 5.27 |
| 960 | 0.0053 | 0.91 | 3.64 |

:::

:::{figure} images/gflops-characteristics.png
:label: fig-gflops
:width: 65%
:alt: "TODO"

SIMD `dgemm` GFLOPs Characteristics.
:::

:::{figure} images/avx-simd.png
:label: fig-avx-simd
:width: 90%
:alt: "TODO"

AVX SIMD Data Types and Registers.
:::

:::{figure} images/intel-inst.png
:label: fig-intel-inst
:width: 90%
:alt: "TODO"

Intel Instructions and Formats.
::: -->
