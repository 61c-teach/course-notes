---
title: "SIMD Array Processing"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/MHIrM4VFzBk
:width: 100%
:title: "[CS61C FA20] Lecture 32.5 - Flynn Taxonomy, SIMD Instructions: SIMD Array Processing"
:::

::::


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